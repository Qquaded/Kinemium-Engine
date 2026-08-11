#if defined(_WIN32)
#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#endif
#include "kine_filament_shim.h"

struct rlTexture {
    unsigned int id;
    int width;
    int height;
    int mipmaps;
    int format;
};
typedef struct rlTexture Texture2D; 

typedef struct RenderTexture RenderTexture2D;
struct RenderTexture {
    unsigned int id;
    struct rlTexture texture;
    struct rlTexture depth;
};
#include "kine_default_package.h"

#include <filament/Engine.h>
#include <filament/Renderer.h>
#include <filament/Scene.h>
#include <filament/View.h>
#include <filament/Camera.h>
#include <filament/SwapChain.h>
#include <filament/Texture.h>
#include <filament/RenderTarget.h>
#include <filament/Viewport.h>
#include <filament/Material.h>
#include <filament/MaterialInstance.h>
#include <filament/RenderableManager.h>
#include <filament/TransformManager.h>
#include <filament/LightManager.h>
#include <filament/VertexBuffer.h>
#include <filament/IndexBuffer.h>
#include <filament/InstanceBuffer.h>
#include <filament/TextureSampler.h>
#include <filament/Color.h>
#include <filament/Skybox.h>
#include <filament/IndirectLight.h>
#include <utils/EntityManager.h>
#include <utils/Entity.h>
#include <math/vec2.h>
#include <math/vec3.h>
#include <math/vec4.h>
#include <math/mat4.h>
#include "kine_neon_package.h"
#include "kine_glass_package.h"
#include "kine_water_package.h"
#include "kine_decal_package.h"

#include "rlgl.h"
#include <geometry/SurfaceOrientation.h>
using namespace filament::geometry;

#include <algorithm>
#include <functional>
#include <unordered_map>
#include <unordered_set>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#if defined(_WIN32)
    #define WIN32_LEAN_AND_MEAN
    #include <windows.h>
    #include <GL/gl.h>
    static void* kine_get_current_gl_context() { return (void*)wglGetCurrentContext(); }
#elif defined(__APPLE__)
    // Apple's OpenGL headers are deprecated as of 10.14+ but still ship and work;
    // silence the barrage of warnings rather than fight the toolchain.
    #define GL_SILENCE_DEPRECATION
    #include <OpenGL/OpenGL.h>
    #include <OpenGL/gl.h>
    static void* kine_get_current_gl_context() { return (void*)CGLGetCurrentContext(); }
#else
    #include <GL/glx.h>
    #include <GL/gl.h>
    static void* kine_get_current_gl_context() { return (void*)glXGetCurrentContext(); }
#endif

// MSVC's bundled GL/gl.h only declares GL 1.1. These are core since GL 1.2/1.3
// but the constant values are part of the stable GL spec, safe to hardcode.
#ifndef GL_CLAMP_TO_EDGE
#define GL_CLAMP_TO_EDGE 0x812F
#endif
#ifndef GL_TEXTURE0
#define GL_TEXTURE0 0x84C0
#endif

// GL_RGBA / GL_UNSIGNED_BYTE are in GL 1.1 on all platforms.
// glReadPixels is also GL 1.0, but on Windows MSVC's gl.h only has the
// prototype if _WIN32 is defined and we include it correctly -- which we do
// above.  No extra declaration needed.
// glBindFramebuffer / GL_FRAMEBUFFER are OpenGL 3.0 core.
#ifndef GL_FRAMEBUFFER
#define GL_FRAMEBUFFER 0x8D40
#endif
#ifndef GL_COLOR_ATTACHMENT0
#define GL_COLOR_ATTACHMENT0 0x8CE0
#endif

// APIENTRY is only ever defined for us by <windows.h>. On Linux/macOS the GL
// calling convention is just the platform default, so make it a no-op there
// instead of hardcoding a Windows-only calling convention into these typedefs.
#ifndef APIENTRY
#define APIENTRY
#endif

typedef void    (APIENTRY* PFNGLBINDFRAMEBUFFERPROC)(GLenum, GLuint);
typedef void    (APIENTRY* PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC)(GLenum, GLenum, GLenum, GLint*);
typedef void    (APIENTRY* PFNGLGENFRAMEBUFFERSPROC)(GLsizei, GLuint*);
typedef void    (APIENTRY* PFNGLDELETEFRAMEBUFFERSPROC)(GLsizei, const GLuint*);
typedef void    (APIENTRY* PFNGLFRAMEBUFFERTEXTURE2DPROC)(GLenum, GLenum, GLenum, GLuint, GLint);

#define GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME 0x8CD1

static PFNGLBINDFRAMEBUFFERPROC          kine_glBindFramebuffer    = nullptr;
static PFNGLGENFRAMEBUFFERSPROC          kine_glGenFramebuffers    = nullptr;
static PFNGLDELETEFRAMEBUFFERSPROC       kine_glDeleteFramebuffers = nullptr;
static PFNGLFRAMEBUFFERTEXTURE2DPROC     kine_glFramebufferTexture2D = nullptr;

static void kine_init_gl_ext() {
    static bool done = false;
    if (done) return;
    done = true;
#if defined(_WIN32)
    kine_glBindFramebuffer     = (PFNGLBINDFRAMEBUFFERPROC)wglGetProcAddress("glBindFramebuffer");
    kine_glGenFramebuffers     = (PFNGLGENFRAMEBUFFERSPROC)wglGetProcAddress("glGenFramebuffers");
    kine_glDeleteFramebuffers  = (PFNGLDELETEFRAMEBUFFERSPROC)wglGetProcAddress("glDeleteFramebuffers");
    kine_glFramebufferTexture2D = (PFNGLFRAMEBUFFERTEXTURE2DPROC)wglGetProcAddress("glFramebufferTexture2D");
#elif defined(__APPLE__)
    // Apple's OpenGL framework has always linked these directly (core since
    // GL 3.0, and macOS's GL implementation tops out at 4.1 core) -- no
    // runtime lookup needed or even possible via a "wgl/glX"-style API.
    kine_glBindFramebuffer      = &glBindFramebuffer;
    kine_glGenFramebuffers      = &glGenFramebuffers;
    kine_glDeleteFramebuffers   = &glDeleteFramebuffers;
    kine_glFramebufferTexture2D = &glFramebufferTexture2D;
#else
    kine_glBindFramebuffer      = (PFNGLBINDFRAMEBUFFERPROC)glXGetProcAddress((const GLubyte*)"glBindFramebuffer");
    kine_glGenFramebuffers      = (PFNGLGENFRAMEBUFFERSPROC)glXGetProcAddress((const GLubyte*)"glGenFramebuffers");
    kine_glDeleteFramebuffers   = (PFNGLDELETEFRAMEBUFFERSPROC)glXGetProcAddress((const GLubyte*)"glDeleteFramebuffers");
    kine_glFramebufferTexture2D = (PFNGLFRAMEBUFFERTEXTURE2DPROC)glXGetProcAddress((const GLubyte*)"glFramebufferTexture2D");
#endif
}

using namespace filament;
using namespace utils;

// ---------------------------------------------------------------------------
// Minimal embedded lit material (unlit flat color + optional texture).
// Built with: matc -a opengl -p mobile -o default_lit.filamat default_lit.mat
// We embed it as a raw byte array generated from the uberarchive shaders.
// For now we use a very simple unlit material that takes baseColor + texture.
// ---------------------------------------------------------------------------

// Material data provided by kine_default_package.h
// ---------------------------------------------------------------------------
// Vertex layout for procedural meshes: position (float3) + normal (float3) + uv (float2)
// ---------------------------------------------------------------------------
struct KineVertex {
    float px, py, pz;
    float nx, ny, nz;
    float u,  v;
};

struct vector3 { float x, y, z; };

struct KineMesh {
    VertexBuffer* vb       = nullptr;
    IndexBuffer*  ib       = nullptr;
    uint32_t      indexCount = 0;
    std::vector<KineVertex>  vertices;
    std::vector<uint16_t>    indices;
};

struct KineTexHandle {
    Texture* tex = nullptr;
};

// ---------------------------------------------------------------------------
// Automatic instanced batching.
//
// Kine_Filament_DrawMeshEx no longer builds a Filament Entity per call. It
// just records the world transform under a key describing "everything about
// this draw that isn't the transform" (mesh + material kind + color/params +
// shadow/culling flags). Calls that share a key are, by definition, the same
// mesh drawn with the same material settings, so they can legally share one
// MaterialInstance and be issued as a single GPU-instanced draw call.
//
// kine_build_batches() (called from Kine_Filament_RenderFrame, before
// rendering) turns each accumulated batch into one RenderableManager entity
// using RenderableManager::Builder::instances(count, InstanceBuffer*), which
// applies each instance's local transform on the GPU without requiring any
// changes to the (precompiled) materials -- it only needs the material's
// vertex domain to be the default VERTEX_DOMAIN_OBJECT. Batches bigger than
// Engine::getMaxAutomaticInstances() are split into multiple chunks/draw
// calls. Everything built this way is torn down again right after the frame
// renders, same lifetime as the old per-call entities had.
// ---------------------------------------------------------------------------

struct KineBatchKey {
    KineMesh* mesh          = nullptr;
    int       materialKind  = 0;
    float     r = 0, g = 0, b = 0;
    float     param1 = 0, param2 = 0, param3 = 0;
    float     transmission  = 0;
    bool      castShadow    = false;
    bool      receiveShadow = false;
    bool      culling       = true;

    KineTexHandle* texture;

    bool operator==(const KineBatchKey& o) const noexcept
    {
        return mesh == o.mesh && materialKind == o.materialKind &&
               r == o.r && g == o.g && b == o.b &&
               param1 == o.param1 && param2 == o.param2 && param3 == o.param3 &&
               transmission == o.transmission &&
               castShadow == o.castShadow && receiveShadow == o.receiveShadow &&
               culling == o.culling && texture == o.texture;
    }
};

struct KineBatchKeyHash {
    size_t operator()(const KineBatchKey& k) const noexcept
    {
        size_t h = std::hash<void*>()(k.mesh);
        auto mix = [&h](size_t v) { h ^= v + 0x9e3779b97f4a7c15ULL + (h << 6) + (h >> 2); };
        mix(std::hash<int>()(k.materialKind));
        mix(std::hash<float>()(k.r));
        mix(std::hash<float>()(k.g));
        mix(std::hash<float>()(k.b));
        mix(std::hash<float>()(k.param1));
        mix(std::hash<float>()(k.param2));
        mix(std::hash<float>()(k.param3));
        mix(std::hash<float>()(k.transmission));
        mix(std::hash<bool>()(k.castShadow));
        mix(std::hash<bool>()(k.receiveShadow));
        mix(std::hash<bool>()(k.culling));
        mix(std::hash<void*>()(k.texture));
        return h;
    }
};

// One queued instance: the transform matrix as filament wants it, plus the
// raw translation pulled straight from the caller's matrix (independent of
// whatever column layout the mat4f above ends up with) so bounds computation
// doesn't need to know or care about that layout.
struct KineBatchInstance {
    math::mat4f  transform;
    math::float3 translation;
};

// A renderable actually built (and added to the scene) for the current
// frame. Torn down again right after the frame is rendered.
struct KineBuiltBatch {
    Entity            entity;
    MaterialInstance* matInst        = nullptr;
    InstanceBuffer*   instanceBuffer = nullptr;
};

struct KineFilamentContext {
    Engine*          engine       = nullptr;
    SwapChain*       swapChain    = nullptr;
    Renderer*        renderer     = nullptr;
    Scene*           scene        = nullptr;
    View*            view         = nullptr;
    Camera*          camera       = nullptr;
    Entity           cameraEntity;
    math::double3    cameraEye{0,0,0};
    math::double3    cameraTarget{0,0,-1};
    math::double3    cameraUp{0,1,0};
    Texture*         colorTarget      = nullptr;
    Texture*         depthTarget      = nullptr;
    RenderTarget*    renderTarget     = nullptr;
    unsigned int     colorTextureId   = 0;
    unsigned int     readFboId        = 0;
    int              width  = 0;
    int              height = 0;
    Texture* whiteTex = nullptr;

    Material*        defaultMaterial = nullptr;
    Entity           sunLight;

    Material* neonMaterial  = nullptr;
    Material* glassMaterial = nullptr;
    Material* waterMaterial = nullptr;
    Material* decalMaterial = nullptr;
    float     time = 0.0f;   // accumulate once per frame for animation

    // Raylib's GL context, captured at Create() time so we can hand control
    // back after we've made Filament's own shared context current.
    //   Windows : raylibCtx = HGLRC,          raylibDC = HDC
    //   macOS   : raylibCtx = CGLContextObj   (no separate "DC" concept)
    //   Linux   : raylibCtx = GLXContext,     raylibDisplay = Display*,
    //             raylibDrawable = GLXDrawable
    void*         raylibCtx      = nullptr;
    void*         raylibDC       = nullptr;
    void*         raylibDisplay  = nullptr;
    unsigned long raylibDrawable = 0;

    Skybox*        skybox        = nullptr;
    Texture*       skyTexture    = nullptr;
    IndirectLight* indirectLight = nullptr;
    void* filamentCtx = nullptr;
    math::float4 skyColor = {0.53f, 0.81f, 0.92f, 1.0f};

    // Draw calls queued this frame via Kine_Filament_DrawMeshEx, grouped by
    // batch key, plus whatever got built from them for the current
    // RenderFrame call. See the "Automatic instanced batching" comment above.
    std::unordered_map<KineBatchKey, std::vector<KineBatchInstance>, KineBatchKeyHash> pendingBatches;
    std::vector<KineBuiltBatch> builtBatches;
};

// Material kinds are in header

// ---------------------------------------------------------------------------
// Platform GL-context save/restore helpers.
//
// Create() needs to: (1) remember raylib's current context, (2) drop it so
// Filament's Engine::create() can set up its own shared context cleanly, and
// (3) hand control back to raylib once Filament is initialized. Destroy()
// needs to (1) again on the way out so Filament's teardown calls land on the
// right context.
// ---------------------------------------------------------------------------

static void kine_capture_raylib_context(KineFilamentContext* ctx)
{
#if defined(_WIN32)
    ctx->raylibCtx = (void*)wglGetCurrentContext();
    ctx->raylibDC  = (void*)wglGetCurrentDC();
#elif defined(__APPLE__)
    ctx->raylibCtx = (void*)CGLGetCurrentContext();
#else
    ctx->raylibCtx      = (void*)glXGetCurrentContext();
    ctx->raylibDisplay  = (void*)glXGetCurrentDisplay();
    ctx->raylibDrawable = (unsigned long)glXGetCurrentDrawable();
#endif
}

static void kine_release_current_gl_context()
{
#if defined(_WIN32)
    wglMakeCurrent(nullptr, nullptr);
#elif defined(__APPLE__)
    CGLSetCurrentContext(nullptr);
#else
    Display* dpy = glXGetCurrentDisplay();
    if (dpy) glXMakeCurrent(dpy, None, nullptr);
#endif
}

static void kine_restore_raylib_context(KineFilamentContext* ctx)
{
    if (!ctx || !ctx->raylibCtx) return;
#if defined(_WIN32)
    wglMakeCurrent((HDC)ctx->raylibDC, (HGLRC)ctx->raylibCtx);
#elif defined(__APPLE__)
    CGLSetCurrentContext((CGLContextObj)ctx->raylibCtx);
#else
    if (ctx->raylibDisplay)
        glXMakeCurrent((Display*)ctx->raylibDisplay,
                        (GLXDrawable)ctx->raylibDrawable,
                        (GLXContext)ctx->raylibCtx);
#endif
}

// ---------------------------------------------------------------------------
// Embedded minimal unlit+texture material bytes.
// Generated offline with:
//   matc -a opengl -o kine_default.filamat kine_default.mat
// and then xxd -i into this array.
// Since we can't run matc at build time here, we use the uberarchive's
// "defaultMaterial" entry by reading it at runtime from the SDK.
// ---------------------------------------------------------------------------

namespace {

// ---------------------------------------------------------------------------
// Procedural mesh generators
// ---------------------------------------------------------------------------

static unsigned int createGLColorTexture(int width, int height)
{
    GLuint id = 0;
    glGenTextures(1, &id);
    if (id == 0) return 0;
    glBindTexture(GL_TEXTURE_2D, id);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    return (unsigned int)id;
}

bool rebuildRenderTarget(KineFilamentContext* ctx, int width, int height)
{
    if (ctx->renderTarget) { ctx->engine->destroy(ctx->renderTarget); ctx->renderTarget = nullptr; }
    if (ctx->colorTarget)  { ctx->engine->destroy(ctx->colorTarget);  ctx->colorTarget  = nullptr; }
    if (ctx->depthTarget)  { ctx->engine->destroy(ctx->depthTarget);  ctx->depthTarget  = nullptr; } 
    if (ctx->colorTextureId) {
        GLuint old = (GLuint)ctx->colorTextureId;
        glDeleteTextures(1, &old);
        ctx->colorTextureId = 0;
    }

    unsigned int glId = createGLColorTexture(width, height);
    if (glId == 0) return false;

    ctx->colorTarget = Texture::Builder()
        .width(uint32_t(width)).height(uint32_t(height)).levels(1)
        .usage(Texture::Usage::COLOR_ATTACHMENT | Texture::Usage::SAMPLEABLE)
        .format(Texture::InternalFormat::RGBA8)
        .import(glId)
        .build(*ctx->engine);
    if (!ctx->colorTarget) return false;

    ctx->depthTarget = Texture::Builder()
        .width(uint32_t(width)).height(uint32_t(height)).levels(1)
        .usage(Texture::Usage::DEPTH_ATTACHMENT | Texture::Usage::SAMPLEABLE)
        .format(Texture::InternalFormat::DEPTH24)
        .build(*ctx->engine);
    if (!ctx->depthTarget) return false;

    ctx->renderTarget = RenderTarget::Builder()
        .texture(RenderTarget::AttachmentPoint::COLOR, ctx->colorTarget)
        .texture(RenderTarget::AttachmentPoint::DEPTH, ctx->depthTarget) 
        .build(*ctx->engine);
    if (!ctx->renderTarget) return false;

    ctx->view->setRenderTarget(ctx->renderTarget);
    ctx->view->setViewport({0, 0, uint32_t(width), uint32_t(height)});
    ctx->colorTextureId = glId;
    ctx->width  = width;
    ctx->height = height;
    return true;
}

static KineMesh* buildCube()
{
    auto* m = new KineMesh();

    // 6 faces x 4 vertices = 24, 6 faces x 2 tris x 3 verts = 36 indices
    const float n = 0.5f;
    struct Face { float nx,ny,nz; float ax,ay,az; float bx,by,bz; };
    Face faces[6] = {
        { 0, 0,  1,  1, 0, 0,  0, 1, 0}, // +Z
        { 0, 0, -1, -1, 0, 0,  0, 1, 0}, // -Z
        { 1, 0,  0,  0, 1, 0,  0, 0, 1}, // +X
        {-1, 0,  0,  0, 1, 0,  0, 0,-1}, // -X
        { 0, 1,  0,  1, 0, 0,  0, 0,-1}, // +Y
        { 0,-1,  0,  1, 0, 0,  0, 0, 1}, // -Y
    };

    for (int f = 0; f < 6; f++) {
        uint16_t base = (uint16_t)(m->vertices.size());
        float nx = faces[f].nx, ny = faces[f].ny, nz = faces[f].nz;
        float ax = faces[f].ax, ay = faces[f].ay, az = faces[f].az;
        float bx = faces[f].bx, by = faces[f].by, bz = faces[f].bz;
        // center of this face
        float cx = nx*n, cy = ny*n, cz = nz*n;
        // 4 corners
        float signs[4][2] = {{-1,-1},{1,-1},{1,1},{-1,1}};
        for (auto& s : signs) {
            KineVertex v;
            v.px = cx + s[0]*ax*n + s[1]*bx*n;
            v.py = cy + s[0]*ay*n + s[1]*by*n;
            v.pz = cz + s[0]*az*n + s[1]*bz*n;
            v.nx = nx; v.ny = ny; v.nz = nz;
            v.u = (s[0]+1)*0.5f; v.v = (s[1]+1)*0.5f;
            m->vertices.push_back(v);
        }
        m->indices.push_back(base+0); m->indices.push_back(base+1); m->indices.push_back(base+2);
        m->indices.push_back(base+0); m->indices.push_back(base+2); m->indices.push_back(base+3);
    }
    m->indexCount = (uint32_t)m->indices.size();
    return m;
}

static KineMesh* buildSphere(int slices = 16, int stacks = 12)
{
    auto* m = new KineMesh();
    for (int j = 0; j <= stacks; j++) {
        float phi = (float)M_PI * j / stacks;
        for (int i = 0; i <= slices; i++) {
            float theta = 2.0f * (float)M_PI * i / slices;
            KineVertex v;
            v.nx = sinf(phi) * cosf(theta);
            v.ny = cosf(phi);
            v.nz = sinf(phi) * sinf(theta);
            v.px = v.nx * 0.5f;
            v.py = v.ny * 0.5f;
            v.pz = v.nz * 0.5f;
            v.u = (float)i / slices;
            v.v = (float)j / stacks;
            m->vertices.push_back(v);
        }
    }
    for (int j = 0; j < stacks; j++) {
        for (int i = 0; i < slices; i++) {
            uint16_t a = (uint16_t)(j*(slices+1)+i);
            uint16_t b = (uint16_t)(a+slices+1);
            m->indices.push_back(a);   m->indices.push_back(b);   m->indices.push_back(a+1);
            m->indices.push_back(b);   m->indices.push_back(b+1); m->indices.push_back(a+1);
        }
    }
    m->indexCount = (uint32_t)m->indices.size();
    return m;
}

static KineMesh* buildPyramid()
{
    auto* m = new KineMesh();
    // 4 triangular sides + 1 square base = 16 verts, 6 tris
    const float h = 0.5f, b = 0.5f;
    float apex[3] = {0, h, 0};
    float base4[4][3] = {{-b,0,-b},{b,0,-b},{b,0,b},{-b,0,b}};
    // Side faces
    for (int i = 0; i < 4; i++) {
        float* p0 = base4[i];
        float* p1 = base4[(i+1)%4];
        // Normal = cross(p1-p0, apex-p0)
        float ax = p1[0]-p0[0], ay = p1[1]-p0[1], az = p1[2]-p0[2];
        float bx = apex[0]-p0[0], by2 = apex[1]-p0[1], bz = apex[2]-p0[2];
        float nx = ay*bz - az*by2, ny = az*bx - ax*bz, nz = ax*by2 - ay*bx;
        float len = sqrtf(nx*nx+ny*ny+nz*nz)+1e-9f;
        nx/=len; ny/=len; nz/=len;
        uint16_t base = (uint16_t)m->vertices.size();
        m->vertices.push_back({apex[0], apex[1], apex[2], nx, ny, nz, 0.5f, 1.0f});
        m->vertices.push_back({p0[0],   p0[1],   p0[2],   nx, ny, nz, 0.0f, 0.0f});
        m->vertices.push_back({p1[0],   p1[1],   p1[2],   nx, ny, nz, 1.0f, 0.0f});
        m->indices.push_back(base); m->indices.push_back(base+1); m->indices.push_back(base+2);
    }
    // Base (square, two tris)
    uint16_t base = (uint16_t)m->vertices.size();
    for (auto& p : base4) {
        float u = (p[0]/b+1)*0.5f, v2 = (p[2]/b+1)*0.5f;
        m->vertices.push_back({p[0], p[1], p[2], 0,-1,0, u, v2});
    }
    m->indices.push_back(base); m->indices.push_back(base+2); m->indices.push_back(base+1);
    m->indices.push_back(base); m->indices.push_back(base+3); m->indices.push_back(base+2);
    m->indexCount = (uint32_t)m->indices.size();
    return m;
}

static void uploadMesh(KineMesh* m, Engine* engine)
{
    size_t vsize = m->vertices.size() * sizeof(KineVertex);
    size_t isize = m->indices.size()  * sizeof(uint16_t);

    // --- compute packed tangent frames from the normals we already have ---
    std::vector<math::float3> normals(m->vertices.size());
    for (size_t i = 0; i < m->vertices.size(); ++i)
        normals[i] = { m->vertices[i].nx, m->vertices[i].ny, m->vertices[i].nz };

    std::vector<math::short4> quats(m->vertices.size());
    auto orientation = SurfaceOrientation::Builder()
        .vertexCount((uint32_t)m->vertices.size())
        .normals(normals.data())
        .build();
    orientation->getQuats(quats.data(), (uint32_t)m->vertices.size());

    delete orientation;

    m->vb = VertexBuffer::Builder()
        .vertexCount((uint32_t)m->vertices.size())
        .bufferCount(2)   // buffer 0 = interleaved pos/uv, buffer 1 = tangents
        .attribute(VertexAttribute::POSITION, 0, VertexBuffer::AttributeType::FLOAT3, offsetof(KineVertex, px), sizeof(KineVertex))
        .attribute(VertexAttribute::UV0,      0, VertexBuffer::AttributeType::FLOAT2, offsetof(KineVertex, u),  sizeof(KineVertex))
        .attribute(VertexAttribute::TANGENTS, 1, VertexBuffer::AttributeType::SHORT4, 0, sizeof(math::short4))
        .normalized(VertexAttribute::TANGENTS)
        .build(*engine);

    // buffer 0: interleaved position/normal/uv, as before
    void* vcopy = malloc(vsize);
    memcpy(vcopy, m->vertices.data(), vsize);
    m->vb->setBufferAt(*engine, 0,
        VertexBuffer::BufferDescriptor(vcopy, vsize,
            [](void* buf, size_t, void*){ free(buf); }, nullptr));

    // buffer 1: packed tangent-frame quaternions
    size_t qsize = quats.size() * sizeof(math::short4);
    void* qcopy = malloc(qsize);
    memcpy(qcopy, quats.data(), qsize);
    m->vb->setBufferAt(*engine, 1,
        VertexBuffer::BufferDescriptor(qcopy, qsize,
            [](void* buf, size_t, void*){ free(buf); }, nullptr));

    m->ib = IndexBuffer::Builder()
        .indexCount(m->indexCount)
        .bufferType(IndexBuffer::IndexType::USHORT)
        .build(*engine);

    void* icopy = malloc(isize);
    memcpy(icopy, m->indices.data(), isize);
    m->ib->setBuffer(*engine,
        IndexBuffer::BufferDescriptor(icopy, isize,
            [](void* buf, size_t, void*){ free(buf); }, nullptr));
}

bool rebuildRenderTarget(KineFilamentContext* ctx, unsigned int textureId, int width, int height)
{
    if (ctx->renderTarget) { ctx->engine->destroy(ctx->renderTarget); ctx->renderTarget = nullptr; }
    if (ctx->colorTarget)  { ctx->engine->destroy(ctx->colorTarget);  ctx->colorTarget  = nullptr; }

    ctx->colorTarget = Texture::Builder()
        .width(uint32_t(width))
        .height(uint32_t(height))
        .levels(1)
        .usage(Texture::Usage::COLOR_ATTACHMENT | Texture::Usage::SAMPLEABLE)
        .format(Texture::InternalFormat::RGBA8)
        .import(textureId)
        .build(*ctx->engine);

    if (!ctx->colorTarget) return false;

    ctx->renderTarget = RenderTarget::Builder()
        .texture(RenderTarget::AttachmentPoint::COLOR, ctx->colorTarget)
        .build(*ctx->engine);

    if (!ctx->renderTarget) return false;

    ctx->view->setRenderTarget(ctx->renderTarget);
    ctx->view->setViewport({0, 0, uint32_t(width), uint32_t(height)});

    ctx->width  = width;
    ctx->height = height;
    return true;
}

// ---------------------------------------------------------------------------
// Applies a batch's shared color/params to a freshly-created MaterialInstance.
// Every draw call folded into a given batch was queued with an identical
// KineBatchKey, so it's correct for all of that batch's GPU instances to
// share one MaterialInstance built this way.
// ---------------------------------------------------------------------------
static void kine_apply_material_params(MaterialInstance* mi, const KineBatchKey& key, float time, Texture* whiteTex)
{
    if (key.materialKind == KINE_MAT_GLASS) {
        mi->setParameter("baseColor", RgbType::LINEAR, math::float3{key.r, key.g, key.b});
        mi->setParameter("roughness",    key.param1);
        mi->setParameter("ior",          key.param2);
        mi->setParameter("thickness",    key.param3);
        mi->setParameter("transmission", key.transmission);
    } else if (key.materialKind == KINE_MAT_NEON) {
        mi->setParameter("emissiveColor", RgbType::LINEAR, math::float3{key.r, key.g, key.b});
        mi->setParameter("intensity",     key.param1);
    } else if (key.materialKind == KINE_MAT_WATER) {
        mi->setParameter("baseColor", RgbType::LINEAR, math::float3{key.r, key.g, key.b});
        mi->setParameter("roughness",   key.param1);       // ~0.05-0.15 for calm water
        mi->setParameter("ior",         key.param2);       // 1.33
        mi->setParameter("thickness",   key.param3);
        mi->setParameter("transmission", key.transmission);
        mi->setParameter("time",        time);
        mi->setParameter("waveScale",   4.0f);
        mi->setParameter("waveSpeed",   1.0f);
        mi->setParameter("foamAmount",  0.3f);
    } else {
        mi->setParameter("baseColor", RgbaType::LINEAR, math::float4{key.r, key.g, key.b, 1.0f});
        mi->setParameter("roughness", key.param1);
        mi->setParameter("metallic",  key.param2);
        if (key.texture && key.texture->tex) {
            mi->setParameter("hasTexture", 1.0f);
            mi->setParameter("baseColorMap", key.texture->tex, TextureSampler{});
        } else {
            mi->setParameter("hasTexture", 0.0f);
            mi->setParameter("baseColorMap", whiteTex, TextureSampler{});
        }
    }
}

// ---------------------------------------------------------------------------
// Filament culls an instanced renderable's instances against a single shared
// bounding box (there's no per-instance box), so we build one that spans
// every instance's position in this batch/chunk. The margin is a generous
// fixed pad covering our procedural meshes' own extent plus typical scaling;
// if you scale instances up dramatically beyond that, either widen kMargin
// below or pass culling=false for that draw call.
// ---------------------------------------------------------------------------
static Box kine_compute_batch_bounds(const KineBatchInstance* instances, size_t count)
{
    constexpr float kMargin = 3.0f;

    math::float3 lo = instances[0].translation;
    math::float3 hi = instances[0].translation;
    for (size_t i = 1; i < count; i++) {
        const math::float3& p = instances[i].translation;
        lo.x = std::min(lo.x, p.x); hi.x = std::max(hi.x, p.x);
        lo.y = std::min(lo.y, p.y); hi.y = std::max(hi.y, p.y);
        lo.z = std::min(lo.z, p.z); hi.z = std::max(hi.z, p.z);
    }

    math::float3 center{ (lo.x + hi.x) * 0.5f, (lo.y + hi.y) * 0.5f, (lo.z + hi.z) * 0.5f };
    math::float3 half{
        (hi.x - lo.x) * 0.5f + kMargin,
        (hi.y - lo.y) * 0.5f + kMargin,
        (hi.z - lo.z) * 0.5f + kMargin
    };
    return Box{ center, half };
}

// ---------------------------------------------------------------------------
// Turns every batch accumulated this frame (via Kine_Filament_DrawMeshEx)
// into one GPU-instanced RenderableManager entity apiece, splitting into
// multiple chunks/draw calls if a batch exceeds the engine's automatic
// instancing limit. Called from Kine_Filament_RenderFrame, right before
// rendering.
// ---------------------------------------------------------------------------
static void kine_build_batches(KineFilamentContext* ctx)
{
    size_t maxInstances = ctx->engine->getMaxAutomaticInstances();
    if (maxInstances == 0) maxInstances = 1;

    // Sort batch keys by material kind to minimize material switches
    // during rendering.
    std::vector<std::pair<KineBatchKey, std::vector<KineBatchInstance>*>> sortedBatches;
    sortedBatches.reserve(ctx->pendingBatches.size());
    for (auto& kv : ctx->pendingBatches) {
        if (!kv.second.empty() && kv.first.mesh) {
            sortedBatches.push_back({kv.first, &kv.second});
        }
    }
    std::sort(sortedBatches.begin(), sortedBatches.end(),
        [](const auto& a, const auto& b) {
            return a.first.materialKind < b.first.materialKind;
        });

    for (auto& [key, instances] : sortedBatches) {
        KineMesh* m = key.mesh;
        if (!m->vb || !m->ib) continue;

        Material* base = ctx->defaultMaterial;
        if (key.materialKind == KINE_MAT_GLASS) base = ctx->glassMaterial;
        if (key.materialKind == KINE_MAT_NEON)  base = ctx->neonMaterial;
        if (key.materialKind == KINE_MAT_WATER) base = ctx->waterMaterial;
        if (!base) continue;

        // One MaterialInstance per batch — shared across all chunks.
        MaterialInstance* mi = base->createInstance();
        kine_apply_material_params(mi, key, ctx->time, ctx->whiteTex);

        size_t offset = 0;
        while (offset < instances->size()) {
            size_t count = std::min(maxInstances, instances->size() - offset);
            KineBatchInstance* chunk = instances->data() + offset;

            std::vector<math::mat4f> transforms(count);
            for (size_t i = 0; i < count; i++) transforms[i] = chunk[i].transform;

            InstanceBuffer* instanceBuffer = InstanceBuffer::Builder(count).build(*ctx->engine);
            instanceBuffer->setLocalTransforms(transforms.data(), count, 0);

            Entity entity = EntityManager::get().create();
            RenderableManager::Builder(1)
                .boundingBox(kine_compute_batch_bounds(chunk, count))
                .material(0, mi)
                .geometry(0, RenderableManager::PrimitiveType::TRIANGLES, m->vb, m->ib, 0, m->indexCount)
                .culling(key.culling)
                .receiveShadows(key.receiveShadow)
                .castShadows(key.castShadow)
                .instances(count, instanceBuffer)
                .build(*ctx->engine, entity);

            ctx->scene->addEntity(entity);
            ctx->builtBatches.push_back({entity, mi, instanceBuffer});

            offset += count;
        }
    }
}

// Tears down everything kine_build_batches built for the frame that just
// rendered. The next round of Kine_Filament_DrawMeshEx calls (before the
// next RenderFrame) starts from a clean pendingBatches map.
static void kine_destroy_built_batches(KineFilamentContext* ctx)
{
    for (auto& b : ctx->builtBatches) {
        ctx->scene->remove(b.entity);
        ctx->engine->destroy(b.entity);
        if (b.instanceBuffer) ctx->engine->destroy(b.instanceBuffer);
        EntityManager::get().destroy(b.entity);
    }

    std::unordered_set<MaterialInstance*> destroyedMIs;
    for (auto& b : ctx->builtBatches) {
        if (b.matInst && destroyedMIs.insert(b.matInst).second) {
            ctx->engine->destroy(b.matInst);
        }
    }

    ctx->builtBatches.clear();
}

}

static Material* buildDefaultMaterial(Engine* engine)
{
    return Material::Builder()
        .package(KINE_DEFAULT_PACKAGE_KINE_DEFAULT_DATA, KINE_DEFAULT_PACKAGE_KINE_DEFAULT_SIZE)
        .build(*engine);
}

static Material* buildWaterMaterial(Engine* engine) {
    return Material::Builder()
        .package(KINE_WATER_PACKAGE_KINE_WATER_DATA, KINE_WATER_PACKAGE_KINE_WATER_SIZE)
        .build(*engine);
}

static Material* buildNeonMaterial(Engine* engine) {
    return Material::Builder()
        .package(KINE_NEON_PACKAGE_KINE_NEON_DATA, KINE_NEON_PACKAGE_KINE_NEON_SIZE)
        .build(*engine);
}

static Material* buildGlassMaterial(Engine* engine) {
    return Material::Builder()
        .package(KINE_GLASS_PACKAGE_KINE_GLASS_DATA, KINE_GLASS_PACKAGE_KINE_GLASS_SIZE)
        .build(*engine);
}

static Material* buildDecalMaterial(Engine* engine) {
    return Material::Builder()
        .package(KINE_DECAL_PACKAGE_KINE_DECAL_DATA, KINE_DECAL_PACKAGE_KINE_DECAL_SIZE)
        .build(*engine);
}

extern "C" {

KINE_API KineFilamentContext* Kine_Filament_Create(int width, int height)
{
    // He makes me speak Chinese.
    // WHAT DO YOU WANT FROM PANDA EXPRESS
    // John P Jing! John P Jing!
    setvbuf(stderr, nullptr, _IONBF, 0);
    if (width <= 0 || height <= 0) return nullptr;

    void* sharedGLContext = kine_get_current_gl_context();
    if (!sharedGLContext) return nullptr;

    auto* ctx = new KineFilamentContext();
    kine_capture_raylib_context(ctx);

    kine_release_current_gl_context();

    ctx->engine = Engine::create(backend::Backend::OPENGL, nullptr, sharedGLContext);
    if (!ctx->engine) { delete ctx; return nullptr; }

    kine_restore_raylib_context(ctx);

    kine_init_gl_ext();

    ctx->swapChain = ctx->engine->createSwapChain(width, height);
    ctx->renderer  = ctx->engine->createRenderer();
    ctx->scene     = ctx->engine->createScene();
    ctx->view      = ctx->engine->createView();

    ctx->cameraEntity = EntityManager::get().create();
    ctx->camera = ctx->engine->createCamera(ctx->cameraEntity);
    ctx->camera->setProjection(60.0, double(width) / double(height), 1.0, 500.0);

    ctx->view->setScene(ctx->scene);
    ctx->view->setCamera(ctx->camera);
    ctx->view->setPostProcessingEnabled(false);

    Renderer::ClearOptions clearOptions;
    clearOptions.clearColor = ctx->skyColor;
    clearOptions.clear = true;
    ctx->renderer->setClearOptions(clearOptions);

    ctx->defaultMaterial = buildDefaultMaterial(ctx->engine);
    ctx->neonMaterial  = buildNeonMaterial(ctx->engine);
    ctx->glassMaterial = buildGlassMaterial(ctx->engine);
    ctx->waterMaterial = buildWaterMaterial(ctx->engine);
    ctx->decalMaterial = buildDecalMaterial(ctx->engine);

    static const uint8_t whitePixel[4] = {255, 255, 255, 255};
    ctx->whiteTex = Texture::Builder()
        .width(1).height(1).levels(1)
        .format(Texture::InternalFormat::RGBA8)
        .build(*ctx->engine);

    Texture::PixelBufferDescriptor pb(
        whitePixel, 4, Texture::Format::RGBA, Texture::Type::UBYTE);
    ctx->whiteTex->setImage(*ctx->engine, 0, std::move(pb));

    ctx->sunLight = EntityManager::get().create();
    LightManager::Builder(LightManager::Type::SUN)
        .color(Color::toLinear<ACCURATE>({1.0f, 0.98f, 0.95f}))
        .intensity(100000.0f)
        .direction({0.5f, -1.0f, 0.8f})
        .sunAngularRadius(1.9f)
        .castShadows(true)
        .build(*ctx->engine, ctx->sunLight);
    ctx->scene->addEntity(ctx->sunLight);

    fprintf(stderr, "[Kine] calling rebuildRenderTarget\n");
    if (!rebuildRenderTarget(ctx, width, height)) {
        fprintf(stderr, "[Kine] rebuildRenderTarget failed\n");
        Kine_Filament_Destroy(ctx);
        return nullptr;
    }

    kine_restore_raylib_context(ctx);

    fprintf(stderr, "[Kine] Create succeeded, colorTextureId=%u\n", ctx->colorTextureId);
    return ctx;
}

KINE_API unsigned int Kine_Filament_GetColorTextureId(KineFilamentContext* ctx)
{
    return ctx ? ctx->colorTextureId : 0;
}

KINE_API void Kine_Filament_CreateSky(KineFilamentContext* ctx, float r, float g, float b, float a)
{
    ctx->skybox = Skybox::Builder()
    .color({r, g, b,a})
    .build(*ctx->engine);
    ctx->scene->setSkybox(ctx->skybox);
}


KINE_API void Kine_Filament_SetPostProcessing(KineFilamentContext* ctx, bool enabled)
{
    ctx->view->setPostProcessingEnabled(enabled);
}

// ---------------------------------------------------------------------------
// Kine_Filament_SetSkyAtmosphere
//
// Procedural atmospheric sky without a custom .filamat material.
// We generate a 32x32 cubemap on the CPU every time this is called, evaluating
// the gradient for every pixel based on its elevation (Y component).
// We also point the built-in sun light entity at the supplied direction and
// scale its intensity.
// ---------------------------------------------------------------------------
KINE_API void Kine_Filament_SetSkyAtmosphere(
    KineFilamentContext* ctx,
    float sunDirX,  float sunDirY,  float sunDirZ,
    float skyR,     float skyG,     float skyB,
    float horizonR, float horizonG, float horizonB,
    float groundR,  float groundG,  float groundB,
    float sunIntensity)
{
    if (!ctx || !ctx->engine) return;

    // --- normalise sun direction -------------------------------------------
    float len = sqrtf(sunDirX*sunDirX + sunDirY*sunDirY + sunDirZ*sunDirZ);
    if (len < 1e-6f) { sunDirX = 0.f; sunDirY = 1.f; sunDirZ = 0.f; }
    else { sunDirX /= len; sunDirY /= len; sunDirZ /= len; }

    float lightDirX = -sunDirX;
    float lightDirY = -sunDirY;
    float lightDirZ = -sunDirZ;

    // --- update sun light entity ------------------------------------------
    if (!ctx->sunLight.isNull()) {
        auto& lm = ctx->engine->getLightManager();
        auto inst = lm.getInstance(ctx->sunLight);
        if (inst.isValid()) {
            lm.setDirection(inst, {lightDirX, lightDirY, lightDirZ});
            float elevFactor = (sunDirY + 0.05f) / 0.15f;
            if (elevFactor < 0.f) elevFactor = 0.f;
            if (elevFactor > 1.f) elevFactor = 1.f;
            lm.setIntensity(inst, sunIntensity * elevFactor);
        }
    }

    // Determine the average clear color (used for the renderer background)
    // using the sun's elevation just like the old logic, so things like fog
    // or clear-screen match the predominant sky color.
    float elev = sunDirY;
    float fr, fg, fb;
    if (elev >= 0.15f) { fr = skyR; fg = skyG; fb = skyB; }
    else if (elev >= 0.0f) {
        float t = elev / 0.15f;
        fr = horizonR + t * (skyR - horizonR);
        fg = horizonG + t * (skyG - horizonG);
        fb = horizonB + t * (skyB - horizonB);
    } else if (elev >= -0.10f) {
        float t = (elev + 0.10f) / 0.10f;
        fr = groundR + t * (horizonR - groundR);
        fg = groundG + t * (horizonG - groundG);
        fb = groundB + t * (horizonB - groundB);
    } else { fr = groundR; fg = groundG; fb = groundB; }
    
    auto clamp01 = [](float v) { return v < 0.f ? 0.f : v > 1.f ? 1.f : v; };
    ctx->skyColor = {clamp01(fr), clamp01(fg), clamp01(fb), 1.0f};

    // --- generate procedural cubemap gradient -----------------------------
    const uint32_t faceSize = 32;
    const size_t faceBytes = faceSize * faceSize * 4;
    const size_t totalBytes = 6 * faceBytes;
    
    // Allocated memory will be freed by the PixelBufferDescriptor callback
    uint8_t* pixels = (uint8_t*)malloc(totalBytes);
    if (!pixels) return;

    auto evalSky = [&](float dy) {
        float r, g, b;
        if (dy >= 0.15f) { r = skyR; g = skyG; b = skyB; }
        else if (dy >= 0.0f) {
            float t = dy / 0.15f;
            r = horizonR + t * (skyR - horizonR);
            g = horizonG + t * (skyG - horizonG);
            b = horizonB + t * (skyB - horizonB);
        } else if (dy >= -0.10f) {
            float t = (dy + 0.10f) / 0.10f;
            r = groundR + t * (horizonR - groundR);
            g = groundG + t * (horizonG - groundG);
            b = groundB + t * (horizonB - groundB);
        } else { r = groundR; g = groundG; b = groundB; }
        return std::make_tuple(clamp01(r), clamp01(g), clamp01(b));
    };

    // Fill 6 faces: +X, -X, +Y, -Y, +Z, -Z
    for (int face = 0; face < 6; ++face) {
        uint8_t* facePixels = pixels + face * faceBytes;
        for (uint32_t y = 0; y < faceSize; ++y) {
            for (uint32_t x = 0; x < faceSize; ++x) {
                // map (x,y) to [-1, 1] range
                float u = (2.0f * (x + 0.5f) / faceSize) - 1.0f;
                // Filament (OpenGL convention): +Y is DOWN for texture coordinates? 
                // Wait, standard cubemap: v goes from -1 to 1 top to bottom.
                // We'll just map v from +1 to -1 so Y is up.
                float v = 1.0f - (2.0f * (y + 0.5f) / faceSize);
                
                float dx = 0, dy = 0, dz = 0;
                switch (face) {
                    case 0: dx =  1.0f; dy = v; dz = -u; break; // +X
                    case 1: dx = -1.0f; dy = v; dz =  u; break; // -X
                    case 2: dx =  u; dy =  1.0f; dz = -v; break; // +Y
                    case 3: dx =  u; dy = -1.0f; dz =  v; break; // -Y
                    case 4: dx =  u; dy = v; dz =  1.0f; break; // +Z
                    case 5: dx = -u; dy = v; dz = -1.0f; break; // -Z
                }
                
                float dlen = sqrtf(dx*dx + dy*dy + dz*dz);
                dy /= dlen; // we only need the normalized Y component
                
                auto [pr, pg, pb] = evalSky(dy);
                
                size_t idx = (y * faceSize + x) * 4;
                facePixels[idx + 0] = (uint8_t)(pr * 255.0f);
                facePixels[idx + 1] = (uint8_t)(pg * 255.0f);
                facePixels[idx + 2] = (uint8_t)(pb * 255.0f);
                facePixels[idx + 3] = 255;
            }
        }
    }

    // If we already have a procedural texture, destroy it
    if (ctx->skyTexture) {
        ctx->engine->destroy(ctx->skyTexture);
    }
    
    ctx->skyTexture = Texture::Builder()
        .width(faceSize).height(faceSize).levels(1)
        .sampler(Texture::Sampler::SAMPLER_CUBEMAP)
        .format(Texture::InternalFormat::RGBA8)
        .build(*ctx->engine);

    Texture::PixelBufferDescriptor pb(
        pixels, totalBytes,
        Texture::Format::RGBA, Texture::Type::UBYTE,
        [](void* buffer, size_t size, void* user) { free(buffer); }
    );

    // Cubemaps are treated as a 2D array of 6 layers. We upload all 6 faces in one go.
    ctx->skyTexture->setImage(*ctx->engine, 0, 0, 0, 0, faceSize, faceSize, 6, std::move(pb));

    if (ctx->skybox) {
        ctx->engine->destroy(ctx->skybox);
        ctx->skybox = nullptr;
    }
    
    ctx->skybox = Skybox::Builder()
        .environment(ctx->skyTexture)
        .showSun(true)
        .build(*ctx->engine);
        
    ctx->scene->setSkybox(ctx->skybox);
}

KINE_API void Kine_Filament_CreateSkyboxCubemap(
    KineFilamentContext* ctx,
    void* texPosX, void* texNegX,
    void* texPosY, void* texNegY,
    void* texPosZ, void* texNegZ)
{
    if (!ctx || !ctx->engine) return;
    
    Texture2D* rtex[6] = {
        (Texture2D*)texPosX, (Texture2D*)texNegX,
        (Texture2D*)texPosY, (Texture2D*)texNegY,
        (Texture2D*)texPosZ, (Texture2D*)texNegZ
    };
    
    int width = rtex[0] ? rtex[0]->width : 0;
    int height = rtex[0] ? rtex[0]->height : 0;
    if (width <= 0 || height <= 0 || width != height) {
        fprintf(stderr, "[Kine] CreateSkyboxCubemap: Faces must be square and > 0.\n");
        return;
    }
    for (int i=1; i<6; ++i) {
        if (!rtex[i] || rtex[i]->width != width || rtex[i]->height != height) {
            fprintf(stderr, "[Kine] CreateSkyboxCubemap: All faces must have identical square dimensions.\n");
            return;
        }
    }
    
    size_t faceBytes = (size_t)width * height * 4;
    size_t totalBytes = faceBytes * 6;
    uint8_t* pixels = (uint8_t*)malloc(totalBytes);
    if (!pixels) return;
    
    // Read pixels from the 6 Raylib OpenGL textures to RAM
    for (int i=0; i<6; ++i) {
        glBindTexture(GL_TEXTURE_2D, rtex[i]->id);
        glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels + i * faceBytes);
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    
    if (ctx->skyTexture) {
        ctx->engine->destroy(ctx->skyTexture);
    }
    
    ctx->skyTexture = Texture::Builder()
        .width(width).height(height).levels(1)
        .sampler(Texture::Sampler::SAMPLER_CUBEMAP)
        .format(Texture::InternalFormat::RGBA8)
        .build(*ctx->engine);

    Texture::PixelBufferDescriptor pb(
        pixels, totalBytes,
        Texture::Format::RGBA, Texture::Type::UBYTE,
        [](void* buffer, size_t size, void* user) { free(buffer); }
    );
    
    ctx->skyTexture->setImage(*ctx->engine, 0, 0, 0, 0, width, height, 6, std::move(pb));
    
    if (ctx->skybox) {
        ctx->engine->destroy(ctx->skybox);
    }
    
    ctx->skybox = Skybox::Builder()
        .environment(ctx->skyTexture)
        .showSun(true)
        .build(*ctx->engine);
        
    ctx->scene->setSkybox(ctx->skybox);
}

KINE_API void Kine_Filament_SetSun(
    KineFilamentContext* ctx,
    float sunDirX, float sunDirY, float sunDirZ,
    float sunIntensity)
{
    if (!ctx || !ctx->engine || ctx->sunLight.isNull()) return;

    float len = sqrtf(sunDirX*sunDirX + sunDirY*sunDirY + sunDirZ*sunDirZ);
    if (len < 1e-6f) { sunDirX = 0.f; sunDirY = 1.f; sunDirZ = 0.f; }
    else { sunDirX /= len; sunDirY /= len; sunDirZ /= len; }

    float lightDirX = -sunDirX;
    float lightDirY = -sunDirY;
    float lightDirZ = -sunDirZ;

    auto& lm = ctx->engine->getLightManager();
    auto inst = lm.getInstance(ctx->sunLight);
    if (inst.isValid()) {
        lm.setDirection(inst, {lightDirX, lightDirY, lightDirZ});
        lm.setIntensity(inst, sunIntensity);
    }
}


KINE_API void Kine_Filament_Destroy(KineFilamentContext* ctx)
{
    if (!ctx) return;

    kine_restore_raylib_context(ctx);

    if (ctx->engine) {
        kine_destroy_built_batches(ctx);
        ctx->pendingBatches.clear();

        if (!ctx->sunLight.isNull()) {
            ctx->scene->remove(ctx->sunLight);
            ctx->engine->destroy(ctx->sunLight);
            EntityManager::get().destroy(ctx->sunLight);
        }
        if (ctx->skyTexture) {
            ctx->engine->destroy(ctx->skyTexture);
            ctx->skyTexture = nullptr;
        }
        if (ctx->renderTarget)  ctx->engine->destroy(ctx->renderTarget);
        if (ctx->colorTarget)   ctx->engine->destroy(ctx->colorTarget);
        if (ctx->defaultMaterial) ctx->engine->destroy(ctx->defaultMaterial);
        if (ctx->neonMaterial)    ctx->engine->destroy(ctx->neonMaterial);
        if (ctx->glassMaterial)   ctx->engine->destroy(ctx->glassMaterial);
        if (ctx->waterMaterial)   ctx->engine->destroy(ctx->waterMaterial);
        if (ctx->colorTextureId) {
            GLuint id = (GLuint)ctx->colorTextureId;
            glDeleteTextures(1, &id);
            ctx->colorTextureId = 0;
        }
        if (!ctx->cameraEntity.isNull()) {
            ctx->engine->destroyCameraComponent(ctx->cameraEntity);
            EntityManager::get().destroy(ctx->cameraEntity);
        }
        if (ctx->view)       ctx->engine->destroy(ctx->view);
        if (ctx->scene)      ctx->engine->destroy(ctx->scene);
        if (ctx->renderer)   ctx->engine->destroy(ctx->renderer);
        if (ctx->swapChain)  ctx->engine->destroy(ctx->swapChain);
        Engine::destroy(&ctx->engine);
    }

    delete ctx;
}

KINE_API void Kine_Filament_DebugPrintPixel(KineFilamentContext* ctx)
{
    if (!ctx || ctx->colorTextureId == 0 || ctx->width <= 0 || ctx->height <= 0) return;

    std::vector<unsigned char> buf((size_t)ctx->width * ctx->height * 4);

    glBindTexture(GL_TEXTURE_2D, (GLuint)ctx->colorTextureId);
    glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, buf.data());
    glBindTexture(GL_TEXTURE_2D, 0);

    int cx = ctx->width / 2;
    int cy = ctx->height / 2;
    size_t idx = ((size_t)cy * ctx->width + cx) * 4;

    glBindTexture(GL_TEXTURE_2D, (GLuint)ctx->colorTextureId);
    glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, buf.data());
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        fprintf(stderr, "[Kine] glGetTexImage GL error: 0x%x\n", err);
    }
    glBindTexture(GL_TEXTURE_2D, 0);

    fprintf(stderr, "[Kine] center pixel RGBA = %d %d %d %d\n",
        buf[idx + 0], buf[idx + 1], buf[idx + 2], buf[idx + 3]);
}

KINE_API void Kine_Filament_RenderFrame(KineFilamentContext* ctx, float deltaTime)
{
    if (!ctx || !ctx->engine) return;
    ctx->time += deltaTime;

    // Turn this frame's queued Kine_Filament_DrawMeshEx calls into batched,
    // GPU-instanced renderables before rendering.

    glEnable(GL_DEPTH_TEST);   // guard against raylib having disabled this last frame
    glDepthMask(GL_TRUE);

    kine_build_batches(ctx);

    if (ctx->renderer->beginFrame(ctx->swapChain)) {
        Renderer::ClearOptions clearOptions;
        clearOptions.clearColor = ctx->skyColor;
        clearOptions.clear = true;
        ctx->renderer->setClearOptions(clearOptions);

        ctx->renderer->render(ctx->view);
        ctx->renderer->endFrame();
    } else {
        fprintf(stderr, "[Kine] beginFrame FAILED this frame\n");
    }
    
    ctx->engine->flushAndWait();

    // Tear down this frame's batch renderables; the next round of
    // Kine_Filament_DrawMeshEx calls (before the next RenderFrame) rebuilds
    // fresh batches from scratch.
    kine_destroy_built_batches(ctx);
    ctx->pendingBatches.clear();

    rlDisableFramebuffer();
    rlViewport(0, 0, ctx->width, ctx->height);
    rlDisableDepthTest();
    rlDisableBackfaceCulling();
    rlDisableScissorTest();
    rlEnableColorBlend();
    rlSetBlendMode(RL_BLEND_ALPHA);
}

KINE_API void Kine_Filament_Resize(KineFilamentContext* ctx, int width, int height)
{
    if (!ctx || !ctx->engine) return;
    if (width <= 0 || height <= 0) return;

    rebuildRenderTarget(ctx, width, height);
    ctx->camera->setProjection(60.0, double(width) / double(height), 1.0, 500.0);
}

KINE_API void* Kine_Filament_GetEngine(KineFilamentContext* ctx) { return ctx ? (void*)ctx->engine : nullptr; }
KINE_API void* Kine_Filament_GetScene(KineFilamentContext* ctx)  { return ctx ? (void*)ctx->scene  : nullptr; }
KINE_API void* Kine_Filament_GetView(KineFilamentContext* ctx)   { return ctx ? (void*)ctx->view   : nullptr; }
KINE_API void* Kine_Filament_GetCamera(KineFilamentContext* ctx) { return ctx ? (void*)ctx->camera : nullptr; }

KINE_API void Kine_Filament_SetCameraLookAt(
    KineFilamentContext* ctx,
    float eyeX, float eyeY, float eyeZ,
    float targetX, float targetY, float targetZ,
    float upX, float upY, float upZ)
{
    if (!ctx || !ctx->camera) return;
    ctx->cameraEye = {eyeX, eyeY, eyeZ};
    ctx->cameraTarget = {targetX, targetY, targetZ};
    ctx->cameraUp = {upX, upY, upZ};
    ctx->camera->lookAt(ctx->cameraEye, ctx->cameraTarget, ctx->cameraUp);
}

KINE_API void Kine_Filament_SetCameraPosition(KineFilamentContext* ctx, float x, float y, float z)
{
    if (!ctx || !ctx->camera) return;
    ctx->cameraEye = {x, y, z};
    ctx->camera->lookAt(ctx->cameraEye, ctx->cameraTarget, ctx->cameraUp);
}

KINE_API void Kine_Filament_SetCameraDirection(KineFilamentContext* ctx, float dx, float dy, float dz)
{
    if (!ctx || !ctx->camera) return;
    ctx->cameraTarget = ctx->cameraEye + math::double3{dx, dy, dz};
    ctx->camera->lookAt(ctx->cameraEye, ctx->cameraTarget, ctx->cameraUp);
}

// light functions

KINE_API int Kine_Filament_CreateLight(
    KineFilamentContext* ctx,
    float px, float py, float pz,
    float cr, float cg, float cb,
    float intensity,
    float falloff
) {
    if (!ctx || !ctx->engine || !ctx->scene)
        return -1;

    utils::Entity entity = utils::EntityManager::get().create();

    filament::LightManager::Builder(
        filament::LightManager::Type::POINT
    )
        .color({cr, cg, cb})
        .intensity(intensity)
        .position({px, py, pz})
        .falloff(falloff)
        .build(*ctx->engine, entity);

    ctx->scene->addEntity(entity);

    return static_cast<int>(entity.getId());
}

// decals

KINE_API int Kine_Filament_CreateDecal(
    KineFilamentContext* ctx,
    float width,
    float height,
    void* rlTexturePtr,
    float offsetStudsU,
    float offsetStudsV,
    float studsPerTileU,
    float studsPerTileV,
    bool culling,
    bool castShadows,
    bool receiveShadows
)
{
    if (!ctx || !ctx->engine || !ctx->scene || !rlTexturePtr ||
        width <= 0.0f || height <= 0.0f)
        return -1;

    Texture2D* rlTexture = static_cast<Texture2D*>(rlTexturePtr);
    if (rlTexture->id == 0)
        return -1;

    Entity entity = EntityManager::get().create();

    Texture* texture = Texture::Builder()
        .width((uint32_t)rlTexture->width)
        .height((uint32_t)rlTexture->height)
        .levels(1)
        .usage(Texture::Usage::SAMPLEABLE)
        .format(Texture::InternalFormat::RGBA8)
        .import(rlTexture->id)
        .build(*ctx->engine);

    if (!texture) {
        EntityManager::get().destroy(entity);
        return -1;
    }

    MaterialInstance* material = ctx->decalMaterial->createInstance();

    if (!material) {
        ctx->engine->destroy(texture);
        EntityManager::get().destroy(entity);
        return -1;
    }

    TextureSampler sampler(
        TextureSampler::MinFilter::LINEAR,
        TextureSampler::MagFilter::LINEAR,
        TextureSampler::WrapMode::REPEAT
    );

    math::float2 uvScale{
        studsPerTileU > 0.0f ? width  / studsPerTileU : 1.0f,
        studsPerTileV > 0.0f ? height / studsPerTileV : 1.0f
    };
    math::float2 uvOffset{
        studsPerTileU > 0.0f ? offsetStudsU / studsPerTileU : 0.0f,
        studsPerTileV > 0.0f ? offsetStudsV / studsPerTileV : 0.0f
    };

    material->setParameter("baseColor", RgbaType::LINEAR, math::float4{1.0f, 1.0f, 1.0f, 1.0f});
    material->setParameter("hasTexture", 1.0f);
    material->setParameter("baseColorMap", texture, sampler);
    material->setParameter("uvScale", uvScale);
    material->setParameter("uvOffset", uvOffset);

    KineMesh* mesh = buildCube();
    uploadMesh(mesh, ctx->engine);

    RenderableManager::Builder(1)
        .boundingBox({
            {-width * 0.5f, -height * 0.5f, -0.01f},
            { width * 0.5f,  height * 0.5f,  0.01f}
        })
        .material(0, material)
        .geometry(
            0,
            RenderableManager::PrimitiveType::TRIANGLES,
            mesh->vb,
            mesh->ib,
            0,
            mesh->indexCount
        )
        .culling(culling)
        .castShadows(castShadows)
        .receiveShadows(receiveShadows)
        .build(*ctx->engine, entity);

    ctx->scene->addEntity(entity);

    return static_cast<int>(entity.getId());
}

static void kine_compute_decal_uv(
    float width, float height,
    float offsetStudsU, float offsetStudsV,
    float studsPerTileU, float studsPerTileV,
    math::float2& outScale, math::float2& outOffset)
{
    outScale = {
        studsPerTileU > 0.0f ? width  / studsPerTileU : 1.0f,
        studsPerTileV > 0.0f ? height / studsPerTileV : 1.0f
    };
    outOffset = {
        studsPerTileU > 0.0f ? offsetStudsU / studsPerTileU : 0.0f,
        studsPerTileV > 0.0f ? offsetStudsV / studsPerTileV : 0.0f
    };
}

KINE_API bool Kine_Filament_SetDecalTiling(
    KineFilamentContext* ctx, int decal,
    float width, float height,
    float offsetStudsU, float offsetStudsV,
    float studsPerTileU, float studsPerTileV)
{
    if (!ctx || !ctx->engine) return false;

    Entity entity = Entity::import(decal);
    if (entity.isNull()) return false;

    RenderableManager& rm = ctx->engine->getRenderableManager();
    auto instance = rm.getInstance(entity);
    if (!instance.isValid()) return false;

    MaterialInstance* mi = rm.getMaterialInstanceAt(instance, 0);
    if (!mi) return false;

    math::float2 uvScale, uvOffset;
    kine_compute_decal_uv(width, height, offsetStudsU, offsetStudsV,
                           studsPerTileU, studsPerTileV, uvScale, uvOffset);

    mi->setParameter("uvScale", uvScale);
    mi->setParameter("uvOffset", uvOffset);
    return true;
}

KINE_API bool Kine_Filament_SetDecalTransform(KineFilamentContext* ctx, int decal, float* mat4)
{
    if (!ctx || !ctx->engine || !mat4) return false;

    Entity entity = Entity::import(decal);
    if (entity.isNull()) return false;

    RenderableManager& rm = ctx->engine->getRenderableManager();
    if (!rm.hasComponent(entity)) return false;

    // Same column-major raylib Matrix -> filament mat4f conversion used in
    // Kine_Filament_DrawMeshEx.
    math::mat4f transform(
        math::float4{mat4[0], mat4[4], mat4[8],  mat4[12]},
        math::float4{mat4[1], mat4[5], mat4[9],  mat4[13]},
        math::float4{mat4[2], mat4[6], mat4[10], mat4[14]},
        math::float4{mat4[3], mat4[7], mat4[11], mat4[15]}
    );

    TransformManager& tm = ctx->engine->getTransformManager();
    auto instance = tm.getInstance(entity);
    if (!instance.isValid()) {
        tm.create(entity);
        instance = tm.getInstance(entity);
    }
    if (!instance.isValid()) return false;

    tm.setTransform(instance, transform);
    return true;
}

KINE_API void Kine_Filament_RemoveDecal(KineFilamentContext* ctx, int decal)
{
    if (!ctx || !ctx->engine || !ctx->scene)
        return;

    Entity entity = Entity::import(decal);
    if (entity.isNull())
        return;

    if (ctx->engine->getRenderableManager().hasComponent(entity)) {
        ctx->scene->remove(entity);
        ctx->engine->destroy(entity);
    }

    EntityManager::get().destroy(entity);
}

KINE_API bool Kine_Filament_EditDecal(
    KineFilamentContext* ctx,
    int decal,
    float width,
    float height,
    bool culling,
    bool castShadows,
    bool receiveShadows
)
{
    if (!ctx || !ctx->engine || !ctx->scene ||
        width <= 0.0f || height <= 0.0f)
        return false;

    Entity entity = Entity::import(decal);
    if (entity.isNull())
        return false;

    RenderableManager& rm = ctx->engine->getRenderableManager();

    if (!rm.hasComponent(entity))
        return false;

    auto instance = rm.getInstance(entity);

    rm.setCastShadows(instance, castShadows);
    rm.setReceiveShadows(instance, receiveShadows);
    rm.setLayerMask(instance, 0x1, culling ? 0x1 : 0x0);

    rm.setAxisAlignedBoundingBox(
        instance,
        {
            {-width * 0.5f, -height * 0.5f, -0.01f},
            { width * 0.5f,  height * 0.5f,  0.01f}
        }
    );

    return true;
}

KINE_API void Kine_Filament_SetColorLight(KineFilamentContext* ctx, int light, float r, float g, float b) {
    if (!ctx || !ctx->engine) return;
    auto& lm = ctx->engine->getLightManager();
    auto instance = lm.getInstance(Entity::import(light));
    if (!instance.isValid()) return;
    lm.setColor(instance, {r, g, b});
}

KINE_API void Kine_Filament_SetIntensityLight(KineFilamentContext* ctx, int light, float intensity) {
    if (!ctx || !ctx->engine) return;
    auto& lm = ctx->engine->getLightManager();
    auto instance = lm.getInstance(Entity::import(light));
    if (!instance.isValid()) return;
    lm.setIntensity(instance, intensity);
}

KINE_API void Kine_Filament_SetFalloffLight(KineFilamentContext* ctx, int light, float falloff) {
    if (!ctx || !ctx->engine) return;
    auto& lm = ctx->engine->getLightManager();
    auto instance = lm.getInstance(Entity::import(light));
    if (!instance.isValid()) return;
    lm.setFalloff(instance, falloff);
}

KINE_API void Kine_Filament_SetPositionLight(KineFilamentContext* ctx, int light, float x, float y, float z) {
    if (!ctx || !ctx->engine) return;
    auto& lm = ctx->engine->getLightManager();
    auto instance = lm.getInstance(Entity::import(light));
    if (!instance.isValid()) return;
    lm.setPosition(instance, {x, y, z});
}

// camera functions

KINE_API void Kine_Filament_SetCameraPerspective(
    KineFilamentContext* ctx,
    double fovYDegrees, double aspect, double nearPlane, double farPlane)
{
    if (!ctx || !ctx->camera) return;
    ctx->camera->setProjection(fovYDegrees, aspect, nearPlane, farPlane);
}

// ---------------------------------------------------------------------------
// Mesh system
//   shape: 1 = cube, 2 = sphere, 3 = pyramid
// ---------------------------------------------------------------------------

// kine_filament_shim.cpp
KineFilamentMesh* Kine_Filament_CreateCustomMesh(
    KineFilamentContext* ctx,
    const float* vertexData,
    int vertexCount,
    const uint16_t* indices,
    int indexCount)
{
    if (!ctx || !ctx->engine || !vertexData || vertexCount <= 0 || !indices || indexCount <= 0)
        return nullptr;
    if (vertexCount > 65535) {
        fprintf(stderr, "[Kine] CreateCustomMesh: %d verts exceeds uint16 index range\n", vertexCount);
        return nullptr;
    }
    auto* m = new KineMesh();
    m->vertices.resize(vertexCount);
    memcpy(m->vertices.data(), vertexData, vertexCount * sizeof(KineVertex));
    m->indices.assign(indices, indices + indexCount);
    m->indexCount = (uint32_t)indexCount;
    uploadMesh(m, ctx->engine); // computes tangents via SurfaceOrientation automatically
    return (KineFilamentMesh*)m;
}

KINE_API KineFilamentMesh* Kine_Filament_CreateMesh(KineFilamentContext* ctx, int shape)
{
    if (!ctx || !ctx->engine) return nullptr;

    KineMesh* m = nullptr;
    switch (shape) {
        case 2:  m = buildSphere(); break;
        case 3:  m = buildPyramid(); break;
        default: m = buildCube();   break; // 1 = cube (default)
    }
    uploadMesh(m, ctx->engine);
    return (KineFilamentMesh*)m;
}

KINE_API void Kine_Filament_DestroyMesh(KineFilamentContext* ctx, KineFilamentMesh* mesh)
{
    if (!ctx || !mesh) return;
    auto* m = (KineMesh*)mesh;
    if (m->vb) ctx->engine->destroy(m->vb);
    if (m->ib) ctx->engine->destroy(m->ib);
    delete m;
}

// ---------------------------------------------------------------------------
// Texture system -- wraps an existing raylib Texture2D GL id.
// rlTexture layout: { uint id, int w, int h, int mipmaps, int format }
// ---------------------------------------------------------------------------

KINE_API KineFilamentTex* Kine_Filament_CreateTex(KineFilamentContext* ctx, void* rlTexturePtr)
{
    if (!ctx || !rlTexturePtr) return nullptr;

    Texture2D* texture = (Texture2D*)rlTexturePtr;
    if (texture->id == 0) return nullptr;

    auto* th = new KineTexHandle();

    th->tex = Texture::Builder()
        .width((uint32_t)texture->width)
        .height((uint32_t)texture->height)
        .levels(1)
        .usage(Texture::Usage::SAMPLEABLE)
        .format(Texture::InternalFormat::RGBA8)
        .import(texture->id)
        .build(*ctx->engine);

    if (!th->tex) {
        delete th;
        return nullptr;
    }

    return (KineFilamentTex*)th;
}

KINE_API void Kine_Filament_DestroyTex(KineFilamentContext* ctx, KineFilamentTex* tex)
{
    if (!ctx || !tex) return;
    auto* th = (KineTexHandle*)tex;
    if (th->tex) ctx->engine->destroy(th->tex);
    delete th;
}

// ---------------------------------------------------------------------------
// DrawMesh -- queues a mesh instance to be drawn this frame.
//
//   ctx          : context handle
//   mesh         : mesh from Kine_Filament_CreateMesh
//   r,g,b        : base color [0..1]
//   tex          : optional texture handle (may be NULL)
//   transparency : [0..1], 0 = fully opaque, 1 = fully transparent
//   mat4         : column-major float[16] world transform (raylib Matrix layout)
//
// Calls that share the same mesh, materialKind, color/params, and
// shadow/culling flags are automatically batched together and issued as a
// single GPU-instanced draw call from Kine_Filament_RenderFrame -- see the
// "Automatic instanced batching" comment near the top of this file.
// ---------------------------------------------------------------------------

KINE_API void Kine_Filament_DrawMeshEx(
    KineFilamentContext* ctx,
    KineFilamentMesh*    mesh,
    int                  materialKind,
    float                r, float g, float b,
    float                param1, // roughness (glass) / intensity (neon)
    float                param2, // ior (glass) / unused (neon)
    float                param3, // thickness (glass) / unused (neon)
    float                transmission, // glass only
    float*               mat4,
    bool                 castshadow,
    bool                 receiveShadow,
    bool                 culling,
    KineFilamentTex*     tex)
{
    if (!ctx || !mesh || !mat4) return;

    KineBatchKey key;
    key.mesh          = (KineMesh*)mesh;
    key.materialKind  = materialKind;
    key.r = r; key.g = g; key.b = b;
    key.param1 = param1; key.param2 = param2; key.param3 = param3;
    key.transmission  = transmission;
    key.castShadow    = castshadow;
    key.receiveShadow = receiveShadow;
    key.culling       = culling;
    key.texture       = (KineTexHandle*)tex;

    KineBatchInstance& inst = ctx->pendingBatches[key].emplace_back();
    inst.transform = math::mat4f(
        math::float4{mat4[0], mat4[4], mat4[8],  mat4[12]},
        math::float4{mat4[1], mat4[5], mat4[9],  mat4[13]},
        math::float4{mat4[2], mat4[6], mat4[10], mat4[14]},
        math::float4{mat4[3], mat4[7], mat4[11], mat4[15]}
    );
    // Raylib's Matrix layout always keeps translation at m12/m13/m14
    // regardless of how the block above maps into filament's mat4f, so pull
    // it straight from the source array for the batch's bounding box.
    inst.translation = math::float3{mat4[12], mat4[13], mat4[14]};

}

} // extern "C"

extern "C" {

// ---------------------------------------------------------------------------
// Pixel readback -- reads Filament's rendered frame into a CPU buffer.
// Call after Kine_Filament_RenderFrame. outPixels must be width*height*4 bytes.
// ---------------------------------------------------------------------------
KINE_API void Kine_Filament_ReadPixels(KineFilamentContext* ctx, void* outPixels)
{
    if (!ctx || !outPixels || ctx->readFboId == 0) return;
    if (!kine_glBindFramebuffer) return;

    kine_glBindFramebuffer(GL_FRAMEBUFFER, (GLuint)ctx->readFboId);
    glReadPixels(0, 0, (GLsizei)ctx->width, (GLsizei)ctx->height,
                 GL_RGBA, GL_UNSIGNED_BYTE, outPixels);
    kine_glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

KINE_API int Kine_Filament_GetWidth(KineFilamentContext* ctx)
{
    return ctx ? ctx->width : 0;
}

KINE_API int Kine_Filament_GetHeight(KineFilamentContext* ctx)
{
    return ctx ? ctx->height : 0;
}

} // extern "C" (ReadPixels block)
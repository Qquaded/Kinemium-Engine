layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec3 vertexNormal;
layout(location = 2) in vec2 vertexTexCoord;

out vec3 fragPos;
out vec3 fragNormal;

void main() {
    // Force fullscreen quad using the plane mesh XZ coordinates.
    // Ensure we map to -1..1 range robustly.
    // If vertexPosition is from GenMeshPlane(2,2), coords are -1 to 1.
    // We can just pass them directly if we trust the mesh.
    // But to be safe vs scaling/transforms:
    vec2 pos = vertexPosition.xz;
    if (abs(pos.x) < 0.1) pos.x = 0.0; // avoid 0 being mapped to 0 by sign if it was sign logic
    
    // Actually, just pass the raw position if it is -1..1
    // The "sign" logic was `sign(vertexPosition.xz)`. 
    // If mesh has a center vertex (0,0,0), sign is 0 -> center of screen.
    // GenMeshPlane often adds a center vertex!
    // If we draw a triangle fan/strip with a center point, that center point goes to (0,0) clip space.
    // And the corners go to (-1,-1)...
    // This creates 4 triangles covering the screen.
    // So "plane in the center" might mean they see the wireframe or something?
    // Or maybe the TRIANGLES are forming correctly, but the winding order is weird?
    
    // Reverting to `sign` logic is fine IF the mesh is a grid.
    // To be perfectly safe, let's output a fullscreen triangle if we used a specific index buffer,
    // but here we are using a generic mesh.
    
    // Better logic: `pos = sign(vertexPosition.xz)`. 
    // If input is 0, output is 0.
    // If input is -1, output is -1.
    // This IS correct for a plane with a center vertex. It maps center to center of screen,
    // and corners to corners of screen.
    // So `gl_Position` works.
    
    // Why did user say "gen plane is in the center"?
    // Maybe Z clipping? `gl_Position.z` is 0.0.
    // `gl_Position.w` is 1.0.
    
    // Just in case, let's make Z 0.999 (far plane) or similar, or 0.0 (near).
    gl_Position = vec4(sign(vertexPosition.xz), 0.0, 1.0);
    
    fragPos = vertexPosition; 
    fragNormal = vertexNormal;
}

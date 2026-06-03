local object = require("./object");
local datatypes = require("../datatypes");
local roblox = require("../dom/roblox");
local fonts = require("./fonts");

local Enum = datatypes.Enums.DataType;

local function Alias(name: string)
    return {
        loader = function(self: object.object, from: string, property: any?)
            if (not property) then
                return;
            end
            local props = self["@instance"].properties;
            if (props[from]) then
                props[name] = props[from]
            end
        end,
        get = function(self: object.object, from: string): any
            return self[name]; -- use get handler
        end,
        set = function(self: object.object, from: string, value: any): ()
            self[name] = value; -- use set handler
            self[from] = value;
        end,
    }
end

local function Coloru8Migrate(name: string)
    return {
        loader = function(self: object.object, from: string, property: any?)
            if (not property) then
                return;
            end
            local props = self["@instance"].properties;
            if (props[from]) then
                assert(props[from].type == roblox.PropertyTypes.Color3, "Failure to migrate to Color when source is not a Color3uint8");
                if (not props[name]) then
                    props[name] = {
                        type = roblox.PropertyTypes.Color3uint8,
                    }
                end
                props[name].value = props[from].value;
                props[from] = nil;
            end
        end,
        get = function(self: object.object, from: string): any
            local Color: datatypes.Color3 = self["@instance"].properties[name].value;
            return Color;
        end,
        set = function(self: object.object, from: string, value: any): ()
            assert(datatypes.Color3.Is(value), "Cannot set non-Color3 value to a Color-migrated property");
            self[name] = value;
        end,
    }
end

local function ContentMigrate(name: string)
    return {
        loader = function(self: object.object, from: string, property: any?)
            if (not property) then
                return;
            end
            local props = self["@instance"].properties;
            if (props[from]) then
                assert(props[from].type == roblox.PropertyTypes.String, "Failure to migrate to Content when source is not a string");
                if (not props[name]) then
                    props[name] = {
                        type = roblox.PropertyTypes.Content,
                    }
                end
                props[name].value = datatypes.Content.Deserialize(Enum.ContentSourceType.Uri.Value, props[from].value, nil);
            end
        end,
        get = function(self: object.object, from: string): any
            local Content: datatypes.Content = self["@instance"].properties[name].value;
            if (Content.SourceType ~= Enum.ContentSourceType.Uri) then
                return "";
            end
            return Content.Uri;
        end,
        set = function(self: object.object, from: string, value: any): ()
            assert(type(value) == "string", "Cannot set non-string value to a Content-migrated property");
            self[name] = datatypes.Content.Deserialize(Enum.ContentSourceType.Uri.Value, value, nil);
            local props = self["@instance"].properties;
            if (not props[from]) then
                props[from] = {
                    type = roblox.PropertyTypes.String,
                }
            end
            props[from].value = value;
        end,
    }
end

local function BrickColorMigrate(name: string)
    return {
        loader = function(self: object.object, from: string, property: any?)
            if (not property) then
                return;
            end
            local props = self["@instance"].properties;
            if (props[from] and not props[name]) then
                assert(props[from].type == roblox.PropertyTypes.BrickColor, "Failure to migrate to Color when source is not a BrickColor");
                props[name] = props[from].value.Color;
                props[from] = nil;
            end
        end,
        get = function(self: object.object, from: string): any
            local Color: datatypes.Color3 = self["@instance"].properties[name].value;
            return datatypes.BrickColor.DataType.new(Color);
        end,
        set = function(self: object.object, from: string, value: any): ()
            if (not datatypes.BrickColor.Is(value)) then
                assert(type(value) == "string", "Cannot set non-BrickColor value to a Color-migrated property");
            end
            self[name] = value.Color;
        end,
    }
end

local function FontMigrate(name: string)
    return {
        loader = function(self: object.object, from: string, property: any?)
            if (not property) then
                return;
            end
            local props = self["@instance"].properties;
            if (props[from] and not props[name]) then
                assert(props[from].type == roblox.PropertyTypes.Enum, "Failure to migrate to Font when source is not a Enum");
                assert(datatypes.EnumItem.Is(props[from].value) and props[from].value.EnumType == Enum.Font, "Failure to migrate to Font when source is not a Font Enum");
                local fontface = fonts[props[from].value];
                props[name] = datatypes.Font.DataType.new(fontface.family, fontface.weight, fontface.style);
                props[from] = nil;
            end
        end,
        get = function(self: object.object, from: string): any
            -- local Font: datatypes.Font = self["@instance"].properties[name].value;
            error("Getting Font enum from migrated Front is not supported");
        end,
        set = function(self: object.object, from: string, value: any): ()
            assert(datatypes.EnumItem.Is(value) and value.EnumType == Enum.Font, "Failure to migrate to Font when source is not a Font Enum");
            local fontface = fonts[value];
            self[name] = datatypes.Font.DataType.new(fontface.family, fontface.weight, fontface.style);
        end,
    }
end

local function IgnoreGuiInsetMigrate()
    return {
        loader = function(self: object.object, from: string, property: any?)
            
            if (not property) then
                return;
            end
            local inset = self["@instance"].properties["ScreenInsets"];
            if (inset.value == Enum.ScreenInsets.CoreUISafeInsets) then
                inset.value = Enum.ScreenInsets.DeviceSafeInsets;
            end
        end,
        get = function(self: object.object): any
            return self["@instance"].properties["ScreenInsets"].value ~= Enum.ScreenInsets.CoreUISafeInsets
        end,
        set = function(self: object.object, from: string, value: any): ()
            local inset = self["@instance"].properties["ScreenInsets"];
            if (value) then
                if (inset.value ~= Enum.ScreenInsets.CoreUISafeInsets) then
                    return;
                end
                inset.value = Enum.ScreenInsets.DeviceSafeInsets;
            else
                inset.value = Enum.ScreenInsets.CoreUISafeInsets;
            end
        end,
    }
end

return {
    AudioPlayer = {
        Asset = ContentMigrate "AudioContent",
    },

    BackpackItem = {
        TextureId = ContentMigrate "TextureContent",
    },

    BodyAngularVelocity = {
        angularvelocity = Alias "AngularVelocity",
        maxTorque = Alias "MaxTorque",
    },
    BodyForce = {
        force = Alias "Force",
    },
    BodyGyro = {
        cframe = Alias "CFrame",
        maxTorque = Alias "MaxTorque",
    },
    BodyPosition = {
        position = Alias "Position",
        maxForce = Alias "MaxForce",
    },
    BodyThrust = {
        force = Alias "Force",
        location = Alias "Location",
    },
    BodyVelocity = {
        velocity = Alias "Velocity",
        maxForce = Alias "MaxForce",
    },

    Camera = {
        CoordinateFrame = Alias "CFrame",
        focus = Alias "Focus",
    },

    ClickDetector = {
        CursorIcon = ContentMigrate "CursorIconContent",
    },
    DragDetector = {
        ActivatedCursorIcon = ContentMigrate "ActivatedCursorIconContent",
    },

    Decal = {
        Texture = ContentMigrate "TextureContent",
        MetalnessMap = ContentMigrate "MetalnessMapContent",
        NormalMap = ContentMigrate "NormalMapContent",
        RoughnessMap = ContentMigrate "RoughnessMapContent",
    },
    ColorMap = {
        ColorMap = ContentMigrate "ColorMapContent",
    },

    ImageButton = {
        Image = ContentMigrate "ImageContent",
        HoverImage = ContentMigrate "HoverImageContent",
        PressedImage = ContentMigrate "PressedImageContent",
    },
    ImageLabel = {
        Image = ContentMigrate "ImageContent",
    },

    Instance = {
        archivable = Alias "Archivable",
    },

    JointInstance = {
        part1 = Alias "Part1",
    },

    MaterialVariant = {
        MetalnessMap = ContentMigrate "MetalnessMapContent",
        NormalMap = ContentMigrate "NormalMapContent",
        RoughnessMap = ContentMigrate "RoughnessMapContent",
        ColorMap = ContentMigrate "ColorMapContent",
    },

    Model = {
        ScaleFactor = Alias "Scale",
    },

    Mouse = {
        Icon = ContentMigrate "IconContent",
    },

    Object = {
        className = Alias "ClassName",
    },

    PackageLink = {
        PackageIdSerialized = Alias "PackageId",
    },

    BasePart = {
        brickColor = BrickColorMigrate "Color",
        BrickColor = BrickColorMigrate "Color",
        Color = Coloru8Migrate "Color3uint8",
        size = Alias "Size",
    },
    FormFactorPart = {
        formFactor = Alias "FormFactor",
        formFactorRaw = Alias "FormFactor",
    },
    Part = {
        shape = Alias "Shape",
    },
    MeshPart = {
        MeshId = ContentMigrate "MeshContent",
        TextureID = ContentMigrate "TextureContent",
    },

    Players = {
        MaxPlayersInternal = Alias "MaxPlayers",
        PreferredPlayersInternal = Alias "PreferredPlayers",
    },

    ScreenGui = {
        IgnoreGuiInset = IgnoreGuiInsetMigrate(),
    },

    ScrollingFrame = {
        BottomImage = ContentMigrate "BottomImageContent",
        MidImage = ContentMigrate "MidImageContent",
        TopImage = ContentMigrate "TopImageContent",
    },

    Sound = {
        EmitterSize = Alias "RollOffMinDistance",
        SoundId = ContentMigrate "AudioContent",
    },

    SurfaceAppearance = {
        MetalnessMap = ContentMigrate "MetalnessMapContent",
        NormalMap = ContentMigrate "NormalMapContent",
        RoughnessMap = ContentMigrate "RoughnessMapContent",
        ColorMap = ContentMigrate "ColorMapContent",
    },

    TerrainDetail = {
        MetalnessMap = ContentMigrate "MetalnessMapContent",
        NormalMap = ContentMigrate "NormalMapContent",
        RoughnessMap = ContentMigrate "RoughnessMapContent",
        ColorMap = ContentMigrate "ColorMapContent",
    },

    TextLabel = {
        Font = FontMigrate "FontFace",
    },
    TextButton = {
        Font = FontMigrate "FontFace",
    },
    TextBox = {
        Font = FontMigrate "FontFace",
    },

    UIDragDetector = {
        ActivatedCursorIcon = ContentMigrate "ActivatedCursorIconContent",
        CursorIcon = ContentMigrate "CursorIconContent",
    },

    UserInputService = {
        MouseIcon = Alias "MouseIconContent",
    },

    VideoFrame = {
        Video = ContentMigrate "VideoContent",
    },

    WeldConstraint = {
        Part0Internal = Alias "Part0",
        Part1Internal = Alias "Part1",
    },

    Workspace = {
        SignalBehavior2 = Alias "SignalBehavior",
    },

    BaseWrap = {
        CageMeshId = ContentMigrate "CageMeshContent",
    },
    WrapLayer = {
        ReferenceMeshId = ContentMigrate "ReferenceMeshContent",
    },
}
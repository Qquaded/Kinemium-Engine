--!strict
export type Class = {
    index: number,
    name: string,
    isService: boolean,
    instances: {number},
};

export type Property = {
    type: number,
    value: any,
}

export type Instance = {
    className: string,
    referent: number,
    parent: number?,
    properties: {[string]: Property},
};

export type Signature = {
    Type: "Ed25519",
    PublicKey: buffer,
    Value: string,
};

export type SharedString = string;

export type DocumentInfo = {
    version: number,
    classes: number,
    instances: number,
    reserved: buffer,
};

export type Document = {
    info: DocumentInfo,
    instances: {Instance},
    classes: {Class},
    metadata: {[string]: string},
    sharedstrings: {[string]: SharedString},
    signatures: {Signature}?,
    --- internal use only.
    --- would ideally be nil
    __sharedstrings_id: {string}?,
};

local PROPERTY_TYPES = {
    Unknown = 0,
    String = 1,
    Bool = 2,
    Int = 3,
    Float = 4,
    Double = 5,
    UDim = 6,
    UDim2 = 7,
    Ray = 8,
    Faces = 9,
    Axes = 10,
    BrickColor = 11,
    Color3 = 12,
    Vector2 = 13,
    Vector3 = 14,
    -- Padded
    CFrame = 16,
    Quaternion = 17,
    Enum = 18,
    Ref = 19,
    Vector3int16 = 20,
    NumberSequence = 21,
    ColorSequence = 22,
    NumberRange = 23,
    Rect = 24,
    PhysicalProperties = 25,
    Color3uint8 = 26,
    Int64 = 27,
    SharedString = 28,
    OptionalCFrame = 30,
    UniqueId = 31,
    Font = 32,
    SecurityCapabilities = 33,
    Content = 34,
}

return {
    PropertyTypes = PROPERTY_TYPES,
}

--!strict
--!optimize 2
--!native

local raylib = require("./raylib")
local structs = raylib.structs

local ffi = _G.zune.ffi
local float = ffi.types.float
local Vector3 = structs.Vector3
type Vector3 = raylib.Vector3
type Matrix = raylib.Matrix

type float = number

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

local double = ffi.types.double
type double = number

export type Fns = {
	Vector3Distance: (v1: Vector3, v2: Vector3) -> float,
	MatrixInvert: (mat: Matrix) -> Matrix,
	MatrixMultiply: (left: Matrix, right: Matrix) -> Matrix,
	MatrixTranspose: (mat: Matrix) -> Matrix,
	MatrixPerspective: (fovy: double, aspect: double, near: double, far: double) -> Matrix,
	MatrixOrtho: (left: double, right: double, bottom: double, top: double, near: double, far: double) -> Matrix,
	MatrixLookAt: (eye: Vector3, target: Vector3, up: Vector3) -> Matrix,
	MatrixIdentity: () -> Matrix,
	MatrixFrustum: (left: double, right: double, bottom: double, top: double, near: double, far: double) -> Matrix,
}

return {
	defs = {
		Clamp = { returns = ffi.types.float, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		Lerp = { returns = ffi.types.float, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		Normalize = { returns = ffi.types.float, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		Remap = {
			returns = ffi.types.float,
			args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
		},
		Wrap = { returns = ffi.types.float, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		FloatEquals = { returns = ffi.types.i32, args = { ffi.types.float, ffi.types.float } },
		Vector2Zero = { returns = ffi.types.pointer, args = {} },
		Vector2One = { returns = ffi.types.pointer, args = {} },
		Vector2Add = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2AddValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		Vector2Subtract = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2SubtractValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		Vector2Length = { returns = ffi.types.float, args = { ffi.types.pointer } },
		Vector2LengthSqr = { returns = ffi.types.float, args = { ffi.types.pointer } },
		Vector2DotProduct = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Distance = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2DistanceSqr = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Angle = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2LineAngle = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Scale = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Multiply = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Negate = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector2Divide = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Normalize = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector2Transform = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Lerp = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
		Vector2Reflect = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Min = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Max = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Rotate = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		Vector2MoveTowards = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		Vector2Invert = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector2Clamp = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
		},
		Vector2ClampValue = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
		},
		Vector2Equals = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector2Refract = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		Vector3Zero = { returns = ffi.types.pointer, args = {} },
		Vector3One = { returns = ffi.types.pointer, args = {} },
		Vector3Add = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3AddValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		Vector3Subtract = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3SubtractValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		Vector3Scale = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Multiply = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3CrossProduct = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Perpendicular = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector3Length = { returns = ffi.types.float, args = { ffi.types.pointer } },
		Vector3LengthSqr = { returns = ffi.types.float, args = { ffi.types.pointer } },
		Vector3DotProduct = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Distance = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3DistanceSqr = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Angle = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Negate = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector3Divide = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Normalize = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector3Project = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Reject = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3OrthoNormalize = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Transform = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3RotateByQuaternion = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3RotateByAxisAngle = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		Vector3MoveTowards = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		Vector3Lerp = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
		Vector3CubicHermite = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		Vector3Reflect = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Min = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Max = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Barycenter = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
		},
		Vector3Unproject = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
		},
		Vector3ToFloatV = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector3Invert = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector3Clamp = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
		},
		Vector3ClampValue = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.float, ffi.types.float },
		},
		Vector3Equals = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector3Refract = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		Vector4Zero = { returns = ffi.types.pointer, args = {} },
		Vector4One = { returns = ffi.types.pointer, args = {} },
		Vector4Add = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4AddValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		Vector4Subtract = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4SubtractValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		Vector4Length = { returns = ffi.types.float, args = { ffi.types.pointer } },
		Vector4LengthSqr = { returns = ffi.types.float, args = { ffi.types.pointer } },
		Vector4DotProduct = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4Distance = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4DistanceSqr = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4Scale = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4Multiply = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4Negate = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector4Divide = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4Normalize = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector4Min = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4Max = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		Vector4Lerp = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
		Vector4MoveTowards = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		Vector4Invert = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		Vector4Equals = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
		MatrixDeterminant = { returns = ffi.types.float, args = { ffi.types.pointer } },
		MatrixTrace = { returns = ffi.types.float, args = { ffi.types.pointer } },
		MatrixTranspose = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		MatrixInvert = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		MatrixIdentity = { returns = structs.Matrix, args = {} },
		MatrixAdd = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		MatrixSubtract = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		MatrixMultiply = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		MatrixTranslate = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		MatrixRotate = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		MatrixRotateX = { returns = ffi.types.pointer, args = { ffi.types.float } },
		MatrixRotateY = { returns = ffi.types.pointer, args = { ffi.types.float } },
		MatrixRotateZ = { returns = ffi.types.pointer, args = { ffi.types.float } },
		MatrixRotateXYZ = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		MatrixRotateZYX = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		MatrixScale = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
		MatrixFrustum = {
			returns = ffi.types.pointer,
			args = {
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
			},
		},
		MatrixPerspective = {
			returns = ffi.types.pointer,
			args = { ffi.types.double, ffi.types.double, ffi.types.double, ffi.types.double },
		},
		MatrixOrtho = {
			returns = ffi.types.pointer,
			args = {
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
				ffi.types.double,
			},
		},
		MatrixLookAt = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
		},
		MatrixToFloatV = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		QuaternionAdd = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		QuaternionAddValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		QuaternionSubtract = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		QuaternionSubtractValue = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		QuaternionIdentity = { returns = structs.Quaternion, args = {} },
		QuaternionLength = { returns = ffi.types.float, args = { ffi.types.pointer } },
		QuaternionNormalize = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		QuaternionInvert = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		QuaternionMultiply = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		QuaternionScale = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		QuaternionDivide = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		QuaternionLerp = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		QuaternionNlerp = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		QuaternionSlerp = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		QuaternionCubicHermiteSpline = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		QuaternionFromVector3ToVector3 = {
			returns = ffi.types.pointer,
			args = { ffi.types.pointer, ffi.types.pointer },
		},
		QuaternionFromMatrix = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		QuaternionToMatrix = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		QuaternionFromAxisAngle = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.float } },
		QuaternionToAxisAngle = {
			returns = ffi.types.void,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float },
		},
		QuaternionFromEuler = {
			returns = ffi.types.pointer,
			args = { ffi.types.float, ffi.types.float, ffi.types.float },
		},
		QuaternionToEuler = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
		QuaternionTransform = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
		QuaternionEquals = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
		MatrixDecompose = {
			returns = ffi.types.void,
			args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
		},
	},
}

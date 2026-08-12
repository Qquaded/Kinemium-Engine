export type Mesh = {
	material: string,
}

export type Image = {
	_handle: any,
}

export type Texture = {
	_handle: any,
}

export type Renderer = {
	_handle: any,
}

export type PixelFormat = number

export type TextureParams = {
	renderer: Renderer,
	pixelFormat: PixelFormat,
	access: number,
	width: number,
	height: number,
}

export type Text = {
	Text: string,
	_handle: any,
}

export type Font = {
	_handle: any,
}

export type RGBA = {
	R: number,
	G: number,
	B: number,
	A: number,
}

export type Rectangle = {
	x: number,
	y: number,
	width: number,
	height: number,
	Color: RGBA,
}

export type Vector = {
	X: number,
	Y: number,
}

export type Vector3 = {
	X: number,
	Y: number,
	Z: number,
}

export type WindowGraphicsInterface = "vulkan" | "opengl"

export type WindowParams = {
	Width: number,
	Height: number,
	Title: string,
	WGI: WindowGraphicsInterface,
}

export type Window = {
	Width: number,
	Height: number,
	_handle: any,
	WGI: WindowGraphicsInterface,
}

export type RenderingContext = {
	_handle: any,
	Window: Window,
}

return {}

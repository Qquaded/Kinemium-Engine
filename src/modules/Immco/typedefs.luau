export type Theme = {
	BgColor: Color3,
	AccentColor: Color3,
	Font: string,
	FontBold: string,
	SecondaryColor: Color3,
	CornerRadius: number,
}

export type WidgetParams = {
	engine_window: any,
	x: number,
	y: number,
	width: number,
	height: number,
	theme: Theme,
	callback: () -> ()?,
}

export type ImageParams = {
	engine_window: any,
	x: number,
	y: number,
	width: number,
	height: number,
	theme: Theme,
	Image: { _handle: any },
	callback: () -> ()?,
}

export type TextParams = {
	text: string?,
	TextSize: number?,
	Font: string?,
	Color: Color3?,
	x: number,
	y: number,
}

export type Image = { _handle: {} }

export type ImageButtonParams = {
	engine_window: any,
	x: number,
	y: number,
	width: number,
	height: number,
	theme: Theme,
	Color: any,
	Image: Image,
	padding: number?,
	imageWidth: number?,
	imageHeight: number?,
	preserveAspectRatio: boolean?,
	imageAspectRatio: number?,
}

export type TextButtonParams = WidgetParams & TextParams

return {}

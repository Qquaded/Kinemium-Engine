local Enum = require("@Enum")

export type DockWidgetPluginGuiInfo = {
	InitialDockState: Enum.InitialDockState,
	InitialEnabled: boolean,
	InitialEnabledShouldOverrideRestore: boolean,
	FloatingXSize: number,
	FloatingYSize: number,
	MinWidth: number,
	MinHeight: number,

	ToTable: (self: DockWidgetPluginGuiInfo) -> { [string]: any },
}

local DockWidgetPluginGuiInfo = {}
DockWidgetPluginGuiInfo.__index = DockWidgetPluginGuiInfo

function DockWidgetPluginGuiInfo.new(
	initialDockState: Enum.InitialDockState,
	initialEnabled: boolean,
	initialEnabledShouldOverrideRestore: boolean,
	floatingXSize: number,
	floatingYSize: number,
	minWidth: number,
	minHeight: number
): DockWidgetPluginGuiInfo
	return setmetatable({
		InitialDockState = initialDockState,
		InitialEnabled = initialEnabled,
		InitialEnabledShouldOverrideRestore = initialEnabledShouldOverrideRestore,
		FloatingXSize = floatingXSize,
		FloatingYSize = floatingYSize,
		MinWidth = minWidth,
		MinHeight = minHeight,
	}, DockWidgetPluginGuiInfo)
end

function DockWidgetPluginGuiInfo:ToTable()
	return {
		InitialDockState = self.InitialDockState,
		InitialEnabled = self.InitialEnabled,
		InitialEnabledShouldOverrideRestore = self.InitialEnabledShouldOverrideRestore,
		FloatingXSize = self.FloatingXSize,
		FloatingYSize = self.FloatingYSize,
		MinWidth = self.MinWidth,
		MinHeight = self.MinHeight,
	}
end

return DockWidgetPluginGuiInfo

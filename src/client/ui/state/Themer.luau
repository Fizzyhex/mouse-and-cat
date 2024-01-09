local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local colorPalette = require(StarterPlayer.StarterPlayerScripts.client.ui.constants.colorPalette)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Value = Fusion.Value

local Themer = {}

Themer.fonts = {
	body = Value(Font.fromName("FredokaOne", Enum.FontWeight.Regular, Enum.FontStyle.Normal)),
}

Themer.textSizes = {
	body = 16,
}

Themer.colors = colorPalette

return Themer

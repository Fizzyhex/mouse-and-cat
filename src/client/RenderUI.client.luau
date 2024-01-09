local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Container = require(StarterPlayer.StarterPlayerScripts.client.ui.Container)
local HintDisplay = require(StarterPlayer.StarterPlayerScripts.client.ui.HintDisplay)
local Themer = require(StarterPlayer.StarterPlayerScripts.client.ui.state.Themer)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Signal = require(ReplicatedStorage.Packages.Signal)
local remotes = require(ReplicatedStorage.shared.remotes)
local New = Fusion.New
local Children = Fusion.Children

local LOCAL_PLAYER = Players.LocalPlayer
local PLAYER_GUI = LOCAL_PLAYER:WaitForChild("PlayerGui") :: PlayerGui

local HINT_COLOR_MAP = {
    warning = Themer.colors.accents.yellow,
    error = Themer.colors.accents.red,
    default = Themer.colors.accents.blue,
}

local displayHint = Signal.new()

New "ScreenGui" {
    Name = "Hints",
    Parent = PLAYER_GUI,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,

    [Children] = Container {
        Size = UDim2.new(1, 0, 1, -70),

        Children = HintDisplay {
            DisplayHint = displayHint
        }
    }
}

remotes.displayHint.OnClientEvent:Connect(function(data)
    data.color = HINT_COLOR_MAP[data.color or "default"]
    print("displaying hint", data)
    displayHint:Fire(data)
end)
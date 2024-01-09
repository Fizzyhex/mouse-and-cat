local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observePlayer(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"

    local stat = Instance.new("IntValue")
    stat.Name = "🧶"
    stat.Parent = leaderstats

    leaderstats.Parent = player
    
    local stop = Observers.observeAttribute(player, "money", function(value)
        local tween = TweenService:Create(stat, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = value })
        tween:Play()

        return function()
            tween:Cancel()
        end
    end)

    return stop
end)
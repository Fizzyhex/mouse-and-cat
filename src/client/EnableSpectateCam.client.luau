local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local FreecamUtil = require(ReplicatedStorage.shared.FreecamUtil)

Observers.observeCharacter(function(player, character)
    if player ~= Players.LocalPlayer then
        return
    end
    
    FreecamUtil.onDisable:Fire()

    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    
    humanoid.Died:Once(function()
        FreecamUtil.onEnable:Fire()
    end)

    return function() end
end)
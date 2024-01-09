local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observePlayer(function(player)
    player:SetAttribute("money", 0)
    return nil
end)
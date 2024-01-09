local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observeCharacter(function(_, character)
    character:AddTag("character")
    character:AddTag("mouse_ignore")
    return nil
end)
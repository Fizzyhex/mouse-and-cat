local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observeTag("conveyor", function(part: BasePart)
    local stopObserving = Observers.observeAttribute(part, "speed", function(speed)
        part.AssemblyLinearVelocity = part.CFrame.LookVector * (speed :: Vector3)
        return function() end
    end)

    return stopObserving
end, {workspace})
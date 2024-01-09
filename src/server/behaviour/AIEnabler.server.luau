local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observeTag("ai_enabler", function(part: BasePart)
    local connection = part.Touched:Connect(function(part: BasePart)
        if part.Parent and part.Parent:HasTag("mouse") then
            part.Parent:AddTag("mouse_ai")
        end
    end)

    return function()
        connection:Disconnect()
    end
end, {workspace})
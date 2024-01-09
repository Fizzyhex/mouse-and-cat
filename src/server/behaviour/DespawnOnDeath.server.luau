local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observeTag("despawn_on_death", function(humanoid: Humanoid)
    local connection = humanoid.Died:Once(function()
        task.delay(4, function()
            if humanoid.Parent then
                humanoid.Parent:Destroy()
            end
        end)
    end)

    return function()
        connection:Disconnect()
    end
end)
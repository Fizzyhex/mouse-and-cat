local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

Observers.observeTag("destructible", function(destructible: Model)
    local stopObserving

    stopObserving = Observers.observeAttribute(destructible, "health", function(health)
        if health <= 0 then
            destructible:Destroy()
            stopObserving()
        end

        return function()
        end
    end)

    return stopObserving
end, {workspace})
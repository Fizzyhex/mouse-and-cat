local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local HintDisplay = require(script.Parent.HintDisplay)

return function(target)
    local display = Signal.new()

    local ui = HintDisplay {
        Parent = target,
        DisplayHint = display,
    }
    
    local spam = task.spawn(function()
        while true do
            display:Fire({
                text = "This is a test hint!",
                duration = 2,
            })

            task.wait(0.5)
        end
    end)

    return function()
        task.cancel(spam)
        ui:Destroy()
    end
end
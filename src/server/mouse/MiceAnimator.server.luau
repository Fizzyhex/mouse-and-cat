local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local ANIMATIONS = ReplicatedStorage.Animations

Observers.observeTag("mouse", function(mouse: Model)
    local humanoid = mouse:WaitForChild("Humanoid") :: Humanoid
    local animator = humanoid:WaitForChild("Animator") :: Animator

    local runAnim = animator:LoadAnimation(ANIMATIONS.Run)
    local idleAnim = animator:LoadAnimation(ANIMATIONS.Idle)
    local slashAnim =  animator:LoadAnimation(ANIMATIONS.Slash)

    local function handleState(state: string)
        if state == "attacking" then
            slashAnim:Play(0)      
        end
        
        return function()
        end
    end

    local stopObserving = Observers.observeAttribute(mouse, "state", function(state: unknown)
        return handleState(state :: string) 
    end)

    humanoid.Running:Connect(function(speed)
        if speed > 0 then
            runAnim:Play()
            idleAnim:Stop()
        else
            runAnim:Stop()
            idleAnim:Play()
        end
    end)

    return stopObserving
end, {workspace})
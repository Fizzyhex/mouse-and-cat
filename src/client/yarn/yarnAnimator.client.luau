local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local GarbageUtil = require(ReplicatedStorage.shared.GarbageUtil)

Observers.observeTag("yarn_ball", function(tool: Tool)
    local binAdd, binEmpty = GarbageUtil.makeBin({})

    local currentCharacter: Model
    local currentHumanoid: Humanoid
    local currentAnimator: Animator

    local throwAnim = tool:WaitForChild("Animations"):WaitForChild("Throw") :: Animation
    local idleAnim = tool:WaitForChild("Animations"):WaitForChild("Idle") :: Animation

    local throwTrack: AnimationTrack
    local idleTrack: AnimationTrack

    local handle = tool:WaitForChild("Handle") :: BasePart

    binAdd(tool.Equipped:Connect(function()
        currentCharacter = tool.Parent :: Model
        currentHumanoid = currentCharacter:WaitForChild("Humanoid") :: Humanoid
        currentAnimator = currentHumanoid:WaitForChild("Animator") :: Animator

        throwTrack = currentAnimator:LoadAnimation(throwAnim)
        idleTrack = currentAnimator:LoadAnimation(idleAnim)
        idleTrack:Play(0.05, 10)
    end))

    binAdd(tool.Unequipped:Connect(function()
        throwTrack:Stop()
        idleTrack:Stop()
    end))

    binAdd(Observers.observeAttribute(tool, "state", function(state)
        handle.LocalTransparencyModifier = if state == "throw" then 1 else 0

        if state == "throw" then
            throwTrack:Play(0, 0.9)
        end

        return function() end
    end))

    return binEmpty
end)
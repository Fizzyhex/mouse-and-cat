local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local function getAnimator(parent: Instance): Animator
    local animator = parent:FindFirstChildWhichIsA("Animator")

    if animator then
        return animator
    else
        local newAnimator = Instance.new("Animator")
        newAnimator.Parent = parent
        return newAnimator
    end
end

Observers.observeTag("mouse_trap", function(trap: Model)
    local root = trap:WaitForChild("Root") :: BasePart
    local cheese = trap:WaitForChild("Cheese") :: BasePart
    local animationController = trap:WaitForChild("AnimationController") :: AnimationController
    local swingAnimation = trap:WaitForChild("Animations"):WaitForChild("Swing") :: Animation

    local onCooldown = false
    cheese.Transparency = 0

    local swingTrack = getAnimator(animationController):LoadAnimation(swingAnimation)
    local swingSound = root:WaitForChild("SwingSound") :: Sound

    local function swing(humanoid: Humanoid)
        onCooldown = true
        cheese.Transparency = 1
        humanoid:TakeDamage(trap:GetAttribute("damage"))
        swingTrack:Play(0)
        swingSound:Play()

        task.delay(trap:GetAttribute("cooldown"), function()
            onCooldown = false
            
            if trap:GetAttribute("uses") > 0 then
                trap:SetAttribute("uses", trap:GetAttribute("uses") - 1)
                cheese.Transparency = 0
            else
                trap:Destroy()
            end
        end)
    end

    local connection = root.Touched:Connect(function(part)
        if onCooldown then
            return
        end
        
        local humanoid = part.Parent and part.Parent:FindFirstChildWhichIsA("Humanoid")
        local character = humanoid and part.Parent

        if not humanoid then
            return
        end

        if Players:GetPlayerFromCharacter(character) then
            return
        end

        swing(humanoid)
    end)

    return function()
        connection:Disconnect()
    end
end)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local MouseBrain = require(script.MouseBrain)
local Observers = require(ReplicatedStorage.Packages.Observers)
local DamageUtil = require(ReplicatedStorage.shared.DamageUtil)
local RaycastUtil = require(ReplicatedStorage.shared.RaycastUtil)

type MouseData = {
    primaryPart: BasePart,
    humanoid: Humanoid,
    model: Model,
    lunge: Sound,
}

type Target = Model & {
    PrimaryPart: BasePart,
}

local miceState: { [MouseData]: MouseBrain.AnyState<Target> } = {}
local ATTACKCAST_SIZE = Vector3.new(2, 2, 1)
local ATTACKCAST_RANGE = 2

Observers.observeTag("mouse_ai", function(mouse: Model)
    print("mouse=", mouse)
    
    if not mouse:IsDescendantOf(workspace) then
        print("FAIL", mouse:GetFullName())
    end

    local mouseData: MouseData = {
        model = mouse,
        humanoid = mouse:WaitForChild("Humanoid") :: Humanoid,
        primaryPart = assert(mouse.PrimaryPart, "Mouse is missing PrimaryPart"),
        lunge = mouse:WaitForChild("HumanoidRootPart"):WaitForChild("SwordLunge") :: Sound,
    }

    if mouse.PrimaryPart:CanSetNetworkOwnership() then
        mouse.PrimaryPart:SetNetworkOwner(nil)
    end

    miceState[mouseData] = MouseBrain.initState()

    return function()
        miceState[mouseData] = nil
    end
end, {workspace})

local function doAttackcast(part: BasePart, params: RaycastParams): RaycastResult?
    local result = RaycastUtil.recursiveBlockcast(part.CFrame, ATTACKCAST_SIZE, part.CFrame.LookVector * ATTACKCAST_RANGE, params, function(result)
        if result.Instance:FindFirstAncestorWhichIsA("Tool") then
            return false
        end

        return true
    end)
    
    return result
end

local function characterFromPart(part: BasePart): Model?
    if part.Parent and part.Parent:IsA("Model") and part.Parent:FindFirstChildWhichIsA("Humanoid") then
        return part.Parent
    end

    return nil
end

local function deduceObstacle(part: BasePart): (MouseBrain.Obstacle, Instance?)
    local character = characterFromPart(part)

    if character and not character:HasTag("enemy") then
        return "enemy", character
    end

    if part.Parent and part.Parent:HasTag("destructible") then
        return "environment", part.Parent
    end

    return "none", nil
end

RunService.Heartbeat:Connect(function()
    local targetPositions: { [Target]: Vector3 } = {}

    for _, character in CollectionService:GetTagged("character") do
        if character.PrimaryPart then
            targetPositions[character] = character.PrimaryPart.Position
        end
    end

    for mouse, oldState in miceState do
        if mouse.humanoid.Health <= 0 then
            continue
        end

        local attackcastParams = RaycastParams.new()
        attackcastParams.FilterDescendantsInstances = { mouse.model }

        local attackcast = doAttackcast(mouse.primaryPart, attackcastParams)

        local obstacleType: MouseBrain.Obstacle
        local obstacle: Instance?

        if attackcast then
            assert(attackcast)
            obstacleType, obstacle = deduceObstacle(attackcast.Instance :: BasePart)
        else
            obstacleType = "none"
        end

        local context: MouseBrain.Context<Target> = {
            position = mouse.primaryPart.Position,
            targets = targetPositions,
            obstacle = obstacleType,
        }

        local newState = MouseBrain.step(context, oldState)
        miceState[mouse] = newState

        if newState.phase == "pursuit" then
            if attackcast and (attackcast.Instance :: BasePart).Anchored then
                mouse.humanoid.Jump = true
            end

            mouse.humanoid:MoveTo(newState.target.PrimaryPart.Position)
        elseif newState.phase == "attacking" and oldState.phase ~= newState.phase then
            mouse.humanoid:MoveTo(mouse.primaryPart.Position)

            if obstacle then
                local damageSubject = DamageUtil.subjectFromInstance(obstacle)

                if damageSubject and DamageUtil.canDamage(mouse.model, damageSubject) then
                    local damage = if obstacleType == "enemy" then mouse.model:GetAttribute("damage") else mouse.model:GetAttribute("environment_damage")
                    DamageUtil.dealDamage(mouse.model, damageSubject, damage)
                    mouse.lunge:Play()
                end
            end
        end

        mouse.model:SetAttribute("state", newState.phase)
    end
end)
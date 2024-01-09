local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local playDamageFlash = require(StarterPlayer.StarterPlayerScripts.client.effects.playDamageFlash)
local Observers = require(ReplicatedStorage.Packages.Observers)
local DamageUtil = require(ReplicatedStorage.shared.DamageUtil)
local GarbageUtil = require(ReplicatedStorage.shared.GarbageUtil)
local InputUtil = require(ReplicatedStorage.shared.InputUtil)
local RaycastUtil = require(ReplicatedStorage.shared.RaycastUtil)
local KnockbackUtil = require(ReplicatedStorage.shared.KnockbackUtil)
local remotes = require(ReplicatedStorage.shared.remotes)

local LOCAL_PLAYER = Players.LocalPlayer

type State = "throw" | "ready"

local function raycastFilter(result: RaycastResult)
    if result.Instance:HasTag("mouse_ignore") then
        return false
    end

    local model = result.Instance:FindFirstAncestorOfClass("Model")

    -- Ignore any parts underneath characters that aren't direct children
    if model and model:FindFirstChildWhichIsA("Humanoid") and model ~= result.Instance.Parent then
        return false
    end

    return true
end

Observers.observeTag("yarn_ball", function(tool: Tool)
    local binAdd, binEmpty = GarbageUtil.makeBin({})
    local currentCharacter: Model
    local currentHumanoid: Humanoid

    local function setState(state: State)
        tool:SetAttribute("state", state)
    end

    setState("ready")

    binAdd(tool.Equipped:Connect(function()
        currentCharacter = tool.Parent :: Model
        currentHumanoid = currentCharacter:FindFirstChildWhichIsA("Humanoid") or currentHumanoid
    end))

    binAdd(tool.Activated:Connect(function()
        if currentCharacter ~= LOCAL_PLAYER.Character then
            return
        end

        if not tool.Enabled then
            return
        end

        local rootPart = currentHumanoid.RootPart

        if not rootPart then
            return
        end

        tool.Enabled = false
        setState("throw")

        task.delay(tool:GetAttribute("cooldown"), function()
            setState("ready")
            tool.Enabled = true
        end)

        local origin = rootPart.Position
        local direction = (InputUtil.getCursorWorldPosition() - origin).Unit
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = { currentCharacter }

        local result = RaycastUtil.recursiveRaycast(origin, direction * 10000, raycastParams, raycastFilter)

        if not result then
            return
        end

        rootPart.CFrame = CFrame.lookAt(rootPart.Position, Vector3.new(result.Position.X, rootPart.Position.Y, result.Position.Z))

        local subject = DamageUtil.subjectFromInstance(result.Instance)

        if subject and DamageUtil.getKind(subject) == "character" and DamageUtil.canDamage(currentCharacter, subject) then
            if DamageUtil.getHealth(subject) > 0 then
                playDamageFlash(subject)

                if DamageUtil.getHealth(subject) - tool:GetAttribute("damage") > 0 then
                    -- time runnin out, this is a lil gross :D
                    ((tool :: any).Handle).Hitmarker:Play()
                else
                    ((tool :: any).Handle).Kill:Play()
                end
            end

            remotes.hit:FireServer(tool, subject)

            local ourRoot = currentHumanoid.RootPart
            local subjectRoot = subject:FindFirstChild("HumanoidRootPart") :: BasePart?

            if ourRoot and subjectRoot then
                local velocity = (subjectRoot.Position - (rootPart.Position - Vector3.new(0, 1.5, 0))).Unit * 400
                KnockbackUtil.network(subjectRoot, velocity)
            end
        end
    end))

    return binEmpty
end)
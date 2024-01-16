local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local PlacementUtil = require(ReplicatedStorage.shared.PlacementUtil)
local remotes = require(ReplicatedStorage.shared.remotes)

local DEFAULT_BLOCKS = ReplicatedStorage.Blocks.Default
local SPECIAL_BLOCKS = ReplicatedStorage.Blocks.Special

local PREVIEW_COLORS = {
    valid = Color3.fromRGB(0, 255, 0),
    invalid = Color3.fromRGB(255, 0, 0)
}

local LOCAL_PLAYER = Players.LocalPlayer

type Result<a, b> = {ok: true, value: a} | {ok: false, value: b}

local function raycastFromScreenPoint(position: Vector2): {didHit: true, origin: Vector3, raycastResult: RaycastResult} | {didHit: false, origin: Vector3}
    local ray = workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = CollectionService:GetTagged("ground")

    local result = workspace:Raycast(ray.Origin, ray.Direction.Unit * 10000, params)

    return if result then {
        didHit = true,
        origin = ray.Origin,
        raycastResult = result
    } else {
        didHit = false,
        origin = ray.Origin,
    }
end

local function placeBlock(tool: Tool, blockData: PlacementUtil.BlockData, position: Vector3)
    local tempBlock = blockData.prefab:Clone()
    tempBlock:PivotTo(CFrame.new(position))
    tempBlock.Parent = workspace

    local ok, err = pcall(function()
        remotes.build:InvokeServer(tool, blockData.prefab, position)
    end)

    if not ok then
        warn(`{err}\n{debug.traceback()}`)
    end

    tempBlock:Destroy()

    return tempBlock
end

local function alignBlock(blockData: PlacementUtil.BlockData, position: Vector3): Result<Vector3, string>
    local result = PlacementUtil.groundcast(position)
    
    if not result then
        return { ok = false, value = "Groundcast missed" }
    end

    local normalOffset = result.Normal * (blockData.prefab.PrimaryPart.Size.Y / 2)

    if blockData.mode == "grid" then
        position = PlacementUtil.conformToGrid(result.Position) + normalOffset
    else
        position = result.Position + normalOffset
    end

    return {
        ok = true,
        value = position,
    }
end

local currentTool: Tool
local blockIndex = 1
local blockData: PlacementUtil.BlockData = PlacementUtil.getBlockData(DEFAULT_BLOCKS:GetChildren()[blockIndex])
local blockPreview: PlacementUtil.BlockModel?
local previewOutline = PlacementUtil.newPreviewOutline()

local function _onCycleInput(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
    if inputState == Enum.UserInputState.Begin then
        blockIndex = PlacementUtil.cycle(blockIndex, #DEFAULT_BLOCKS:GetChildren(), "next")
        blockData = PlacementUtil.getBlockData(DEFAULT_BLOCKS:GetChildren()[blockIndex])

        if blockPreview then
            blockPreview:Destroy()
            blockPreview = nil
        end

        blockPreview = PlacementUtil.previewify(blockData.prefab)
    end
end

local function onBuildInput(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        local raycast = raycastFromScreenPoint(UserInputService:GetMouseLocation())

        if not raycast.didHit then
            print("cl1")
            return
        end

        local positionResult = alignBlock(blockData, raycast.raycastResult.Position)

        if not positionResult.ok then
            warn(positionResult.value)
            return
        end

        print("Placed")
        placeBlock(currentTool, blockData, positionResult.value)
    end
end

local function getPreviewPosition(): Vector3?
    local raycast = raycastFromScreenPoint(UserInputService:GetMouseLocation())
    
    if not raycast.didHit then
        return nil
    end

    local positionResult = alignBlock(blockData, raycast.raycastResult.Position)

    if not positionResult.ok then
        return nil
    end

    return positionResult.value
end

RunService.RenderStepped:Connect(function()
    if not blockPreview then
        return
    end

    local previewPosition = getPreviewPosition()

    if previewPosition then
        blockPreview:PivotTo(CFrame.new(previewPosition))
        blockPreview.Parent = workspace
        previewOutline.Adornee = blockPreview
        previewOutline.Visible = true
    
        local space = PlacementUtil.checkBlockSpace(blockData, previewPosition)
        previewOutline.Color3 = if space.available then PREVIEW_COLORS.valid else PREVIEW_COLORS.invalid
    else
        blockPreview.Parent = nil
        previewOutline.Visible = false
    end

    previewOutline.Parent = workspace.CurrentCamera
end)

local function enableBuilding()
    print("building enabled")
    ContextActionService:BindAction("build", onBuildInput, false, Enum.UserInputType.MouseButton1)
    blockPreview = PlacementUtil.previewify(blockData.prefab)
end

local function disableBuilding()
    print("building disabled")
    ContextActionService:UnbindAction("build_cycle")
    ContextActionService:UnbindAction("build")

    if blockPreview then
        blockPreview:Destroy()
        blockPreview = nil
    end
end

Observers.observeTag("build_tool", function(tool: Tool)
    if tool.Parent == LOCAL_PLAYER.Character then
        currentTool = tool
        enableBuilding()

        if tool:GetAttribute("special_block") then
            blockData = PlacementUtil.getBlockData(SPECIAL_BLOCKS:FindFirstChild(tool:GetAttribute("special_block")))
            blockPreview = PlacementUtil.previewify(blockData.prefab)
        else
            blockData = PlacementUtil.getBlockData(DEFAULT_BLOCKS:GetChildren()[blockIndex])
            blockPreview = PlacementUtil.previewify(blockData.prefab)
        end

        return disableBuilding
    end
    
    return function() end
end, { workspace })
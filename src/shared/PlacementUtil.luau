local CollectionService = game:GetService("CollectionService")

local GRID_SIZE = 3

export type BlockModel = Model & {PrimaryPart: BasePart}

export type BlockData = {
    prefab: BlockModel,
    mode: "grid" | "free",
    gridSize: number
}

local PlacementUtil = {}
PlacementUtil.GRID_SIZE = GRID_SIZE

function PlacementUtil.newPreviewOutline()
    local outline = Instance.new("SelectionBox")
    outline.Name = "Outline"
    outline.Color3 = Color3.new(0, 0, 0)
    outline.SurfaceTransparency = 1
    outline.LineThickness = 0.05
   
    return outline
end

function PlacementUtil.previewify(prefab: Model)
    local preview = prefab:Clone() :: BlockModel
    preview:AddTag("mouse_ignore")
    preview.Name = `{preview.Name} (PREVIEW)`

    for _, child in preview:GetDescendants() do
        if child:IsA("BasePart") then
            child.Anchored = true
            child.CanCollide = false
            child.CanTouch = false
            child.CanQuery = false
            child.LocalTransparencyModifier = 0.5
        end
    end

    return preview
end

function PlacementUtil.getBlockData(block: BlockModel): BlockData
    return {
        prefab = block,
        mode = block:GetAttribute("align_mode") or "grid",
        gridSize = block.PrimaryPart.Size.X
    }
end

function PlacementUtil.conformToGrid(position: Vector3)
    return Vector3.new(
        math.round(position.X / GRID_SIZE + 0) * GRID_SIZE,
        math.round(position.Y / GRID_SIZE + 0) * GRID_SIZE,
        math.round(position.Z / GRID_SIZE + 0) * GRID_SIZE
    )
end

function PlacementUtil.cycle(index: number, blockCount: number, input: "next" | "previous"): number
    if input == "next" then
        return if index >= blockCount then 1 else index + 1
    elseif input == "previous" then
        return if index <= 1 then blockCount else index - 1
    end

    error("Invalid input")
end

function PlacementUtil.groundcast(position: Vector3): RaycastResult?
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = CollectionService:GetTagged("ground")
    params.FilterType = Enum.RaycastFilterType.Include

    local result = workspace:Raycast(position + Vector3.new(0, 3, 0), -Vector3.new(0, 1000, 0), params)
    return result
end

function PlacementUtil.checkSpace(bounds: Vector3, position: Vector3): {available: true, parts: {}} | {available: false, parts: unknown}
    bounds -= Vector3.new(0.1, 0.1, 0.1)
    local params = OverlapParams.new()
    params.FilterDescendantsInstances = CollectionService:GetTagged("mouse_ignore")
    local parts = workspace:GetPartBoundsInBox(CFrame.new(position), bounds, params)

    if #parts == 0 then
        return {
            available = true,
            parts = parts
        }
    else
        return {
            available = false,
            parts = parts
        }
    end
end

function PlacementUtil.checkBlockSpace(blockData: BlockData, position: Vector3)
    return PlacementUtil.checkSpace(blockData.prefab.PrimaryPart.Size, position)
end

return PlacementUtil
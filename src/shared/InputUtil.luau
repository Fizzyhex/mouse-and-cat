local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local InputUtil = {}

function InputUtil.getCursorWorldPosition()
    local position = UserInputService:GetMouseLocation()
    local ray = workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = CollectionService:GetTagged("mouse_ignore")
    local result = workspace:Raycast(ray.Origin, ray.Direction.Unit * 10000, params)

    return if result then result.Position else ray.Origin + ray.Direction.Unit * 10000
end

return InputUtil
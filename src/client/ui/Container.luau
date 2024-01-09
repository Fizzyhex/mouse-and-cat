local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children

export type Props = {
    Parent: Fusion.CanBeState<Instance>?,
    Name: Fusion.CanBeState<string>?,
    Size: Fusion.CanBeState<UDim2>?,
    Position: Fusion.CanBeState<UDim2>?,
    AnchorPoint: Fusion.CanBeState<Vector2>?,
    SizeConstraint: Fusion.CanBeState<Enum.SizeConstraint>?,
    AutomaticSize: Fusion.CanBeState<Enum.AutomaticSize>?,
    LayoutOrder: Fusion.CanBeState<number>?,
    Children: any,
}

--- Super basic positional container
local function Container(props: Props)
    return New "Frame" {
        Parent = props.Parent,
        Name = props.Name or "Container",
        Size = props.Size or UDim2.fromScale(1, 1),
        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        SizeConstraint = props.SizeConstraint,
        AutomaticSize = props.AutomaticSize,
        LayoutOrder = props.LayoutOrder,
        BackgroundTransparency = 1,
        [Children] = props.Children,
    }
end

return Container
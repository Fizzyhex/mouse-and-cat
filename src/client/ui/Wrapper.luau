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
    LayoutOrder: Fusion.CanBeState<number>?,
    Children: unknown,
}

--- An invisible frame that wraps around children with automatic sizing.
local function Wrapper(props: Props)
    return New "Frame" {
        Parent = props.Parent,
        Name = props.Name or "Wrapper",
        Size = props.Size or UDim2.fromScale(0, 0),
        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        SizeConstraint = props.SizeConstraint,
        AutomaticSize = Enum.AutomaticSize.XY,
        LayoutOrder = props.LayoutOrder,
        BackgroundTransparency = 1,
        [Children] = props.Children,
    }
end

return Wrapper
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New

export type Props = {
    Parent: Fusion.CanBeState<Instance>?,
    Name: Fusion.CanBeState<string>?,
    Padding: Fusion.CanBeState<UDim>?,
    PaddingLeft: Fusion.CanBeState<UDim>?,
    PaddingRight: Fusion.CanBeState<UDim>?,
    PaddingTop: Fusion.CanBeState<UDim>?,
    PaddingBottom: Fusion.CanBeState<UDim>?,
}

local function Padding(props: Props)
    return New "UIPadding" {
        Parent = props.Parent,
        Name = props.Name or "Padding",
        PaddingLeft = props.PaddingLeft or props.Padding,
        PaddingRight = props.PaddingRight or props.Padding,
        PaddingTop = props.PaddingTop or props.Padding,
        PaddingBottom = props.PaddingBottom or props.Padding,
    }
end

return Padding
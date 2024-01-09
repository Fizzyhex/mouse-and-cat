local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Themer = require(StarterPlayer.StarterPlayerScripts.client.ui.state.Themer)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local Children = Fusion.Children
local New = Fusion.New

export type Props = {
    Name: Fusion.CanBeState<string>?,
    Size: Fusion.CanBeState<UDim2>?,
    Parent: Fusion.CanBeState<Instance>?,
    Text: Fusion.CanBeState<string>?,
    TextXAlignment: Fusion.CanBeState<Enum.TextXAlignment>?,
    TextColor3: Fusion.CanBeState<Color3>?,
    RichText: Fusion.CanBeState<boolean>?,
    AutomaticSize: Fusion.CanBeState<Enum.AutomaticSize>?,
    Children: any,
}

local function Label(props: Props)
    return New "TextLabel" {
        Name = props.Name or "Label",
        Parent = props.Parent,
        Text = props.Text,
        Size = props.Size or UDim2.fromScale(1, 1),
        FontFace = Themer.fonts.body,
        TextColor3 = props.TextColor3 or Themer.colors.neutrals.text,
        TextSize = Themer.textSizes.body,
        BackgroundTransparency = 1,
        RichText = props.RichText,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        AutomaticSize = props.AutomaticSize,
        [Children] = props.Children or {},
    }
end

return Label

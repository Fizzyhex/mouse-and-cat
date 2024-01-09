local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Themer = require(StarterPlayer.StarterPlayerScripts.client.ui.state.Themer)
local Container = require(script.Parent.Container)
local Label = require(script.Parent.Label)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Signal = require(ReplicatedStorage.Packages.Signal)
local New = Fusion.New
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value
local peek = Fusion.peek

export type HintArgs = {
    text: string,
    color: Color3?,
    duration: number?
}

export type Props = {
    DisplayHint: Signal.Signal<HintArgs>,
    Parent: Instance?,
}

local TWEEN_DURATION = 0.5

local function HintDisplay(props: Props)
    local hints = Value({})

    props.DisplayHint:Connect(function(args: HintArgs)
        local scale = Value(0)
        local tweenScale = Tween(scale, TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
        
        local hint = Container {
            Size = UDim2.new(1, 0, 0, Themer.textSizes.body),

            Children = {
                Label {
                    Text = args.text,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextColor3 = args.color,

                    Children = New "UIStroke" {
                        Color = Color3.new(0, 0, 0),
                        Transparency = 0.5,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                    },
                },
    
                New "UIScale" {
                    Scale = tweenScale,
                },
            }
        }

        peek(hints)[hint] = hint
        hints:set(peek(hints), true)
        scale:set(2.5)

        task.delay(args.duration or 3.5, function()
            scale:set(0)

            task.delay(TWEEN_DURATION, function()
                peek(hints)[hint] = nil
                hints:set(peek(hints), true)
                hint:Destroy()
            end)
        end)
    end)

    return New "Frame" {
        Parent = props.Parent,
        BackgroundTransparency = 1,
        Name = "HintDisplay",
        Size = UDim2.fromScale(1, 1),

        [Children] = {
            New "UIListLayout" {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
            },
            
            New "UIPadding" {
                PaddingBottom = UDim.new(0, 32),
            },

            hints :: any,
        }
    }
end

return HintDisplay
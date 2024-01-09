local TweenService = game:GetService("TweenService")

local DURATION = 0.5

local function playDamageFlash(adornee: Instance)
    local highlight = Instance.new("Highlight")
    highlight.Name = "damageFlash"
    highlight.FillColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Adornee = adornee
    highlight.Parent = workspace.CurrentCamera

    TweenService:Create(highlight, TweenInfo.new(DURATION), {
        FillTransparency = 1,
    }):Play()

    task.delay(DURATION, function()
        highlight:Destroy()
    end)
end

return playDamageFlash
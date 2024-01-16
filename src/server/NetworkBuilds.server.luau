local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlacementUtil = require(ReplicatedStorage.shared.PlacementUtil)
local remotes = require(ReplicatedStorage.shared.remotes)

remotes.build.OnServerInvoke = function(player, tool: Tool, prefab: Model, position: Vector3)
    local cost = prefab:GetAttribute("cost")
    local balance = player:GetAttribute("money")

    if cost > balance then
        remotes.displayHint:FireClient(player, {
            text = `you need {cost - balance} more 🧶 to build that!`,
            color = "error",
        })

        print("need monei")

        return
    end

    if not PlacementUtil.checkBlockSpace(PlacementUtil.getBlockData(prefab :: any), position).available then
        remotes.displayHint:FireClient(player, {
            text = `build obstructed!`,
            color = "error",
        })
        
        return
    end

    if tool:GetAttribute("uses") then
        tool:SetAttribute("uses", tool:GetAttribute("uses") - 1)

        if tool:GetAttribute("uses") <= 0 then
            tool:Destroy()
        end
    end

    player:SetAttribute("money", balance - cost)

    local build = prefab:Clone()

    if build.Name == "Wool" and build.PrimaryPart then
        local key = (position.X + position.Z) % 2
        local color = if key == 0 then build:GetAttribute("color1") else build:GetAttribute("color2")
        build.PrimaryPart.Color = color
    end

    build:PivotTo(CFrame.new(position))
    build.Parent = workspace.Map:FindFirstChild("Dynamic")

    return true
end
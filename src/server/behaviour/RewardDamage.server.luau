local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DamageUtil = require(ReplicatedStorage.shared.DamageUtil)

DamageUtil.onDamage:Connect(function(from, to, damage)
    if DamageUtil.getHealth(to) > 0 then
        return
    end

    local killReward = to:GetAttribute("kill_reward")

    if not killReward then
        return
    end

    if to:HasTag("kill_rewarded") then
        return
    end

    to:AddTag("kill_rewarded")

    local player = Players:GetPlayerFromCharacter(from)

    if player then
        player:SetAttribute("money", player:GetAttribute("money") + killReward)
    end
end)
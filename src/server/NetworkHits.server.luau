local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DamageUtil = require(ReplicatedStorage.shared.DamageUtil)
local remotes = require(ReplicatedStorage.shared.remotes)

-- SCREW NETWORK SECURITY IM NOT DOING ALL THAT
remotes.hit.OnServerEvent:Connect(function(player, weapon, target)
    if player.Character and target and DamageUtil.canDamage(player.Character, target) then
        DamageUtil.dealDamage(player.Character, target, weapon:GetAttribute("damage"))
    end
end)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KnockbackUtil = require(ReplicatedStorage.shared.KnockbackUtil)
local remotes = require(ReplicatedStorage.shared.remotes)

-- DANGEROUS! :D
remotes.applyKnockback.OnServerEvent:Connect(function(player: Player, part: BasePart, velocity: Vector3, duration: number)
    if part and not part.Anchored then
        KnockbackUtil.applyForce(part, velocity, duration)
    end
end)
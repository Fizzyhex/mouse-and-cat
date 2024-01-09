local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KnockbackUtil = require(ReplicatedStorage.shared.KnockbackUtil)
local remotes = require(ReplicatedStorage.shared.remotes)

remotes.applyKnockback.OnClientEvent:Connect(function(part, velocity, duration)
    KnockbackUtil.applyForce(part, velocity, duration)
end)
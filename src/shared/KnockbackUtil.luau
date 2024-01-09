local RunService = game:GetService("RunService")

local remotes = require(script.Parent.remotes)
local function makeAttachment(part: BasePart): Attachment
    local attachment = Instance.new("Attachment")
    attachment.Name = "KnockbackAttachment"
    attachment.Parent = part
    return attachment
end

local KnockbackUtil = {}

function KnockbackUtil.applyForce(part: BasePart, velocity: Vector3, duration: number?)
    duration = duration or 0.4
    assert(duration)

    local attachment = (part:FindFirstChild("KnockbackAttachment") or makeAttachment(part))
    assert(attachment:IsA("Attachment"), "Child named KnockbackAttachment is not an attachment")
    
    local knockback = Instance.new("LinearVelocity")
    knockback.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    knockback.MaxAxesForce = velocity * part.AssemblyMass * 2
    knockback.VectorVelocity = velocity
    knockback.RelativeTo = Enum.ActuatorRelativeTo.World
    knockback.Attachment0 = attachment
    knockback.Parent = workspace.CurrentCamera -- We don't want it to replicate!

    task.delay(duration, function()
        knockback:Destroy()
    end)
end

function KnockbackUtil.network(part: BasePart, velocity: Vector3, duration: number?)
    if RunService:IsClient() then
        remotes.applyKnockback:FireServer(part, velocity, duration)
    else
        remotes.applyKnockback:FireAllClients(part, velocity, duration)
    end

    KnockbackUtil.applyForce(part, velocity, duration)
end

return KnockbackUtil
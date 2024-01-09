local InstanceUtil = {}

function InstanceUtil.characterFromPart(part: BasePart): Model?
    if part.Parent and part.Parent:IsA("Model") and part.Parent:FindFirstChildWhichIsA("Humanoid") then
        return part.Parent
    end

    return nil
end

function InstanceUtil.cosmeticFilter(instance: Instance)
    local thing = instance:FindFirstAncestorOfClass("Tool") or instance:FindFirstAncestorOfClass("Accessory")
    return thing == nil
end

return InstanceUtil
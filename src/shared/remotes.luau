local RunService = game:GetService("RunService")
local remoteIndex = 0

local function createRemote(): RemoteEvent
    remoteIndex += 1

    if RunService:IsClient() then
        return script:WaitForChild(tostring(remoteIndex))
    else
        local remote = Instance.new("RemoteEvent")
        remote.Name = tostring(remoteIndex)
        remote.Parent = script
        return remote
    end
end

local function createRemoteFunction(): RemoteFunction
    remoteIndex += 1

    if RunService:IsClient() then
        return script:WaitForChild(tostring(remoteIndex))
    else
        local remote = Instance.new("RemoteFunction")
        remote.Name = tostring(remoteIndex)
        remote.Parent = script
        return remote
    end
end

return {
    build = createRemoteFunction(),
    hit = createRemote(),
    displayHint = createRemote(),
    applyKnockback = createRemote(),
}
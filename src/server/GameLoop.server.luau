local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local filter = require(ReplicatedStorage.shared.filter)
local remotes = require(ReplicatedStorage.shared.remotes)
local PlayerVitalsTracker = require(script.Parent.PlayerVitalsTracker)

local MOUSE_PREAFB = ServerStorage.Mouse
local ROUND_START_TIME = 15
local INTERMISSION_DURATION = if RunService:IsStudio() then 3 else 30
local SPANW_VARIANCE_MIN_ROUND = 3
local TIME_BETWEEN_WAVES = 13

local MAP = workspace.Map
local DYNAMIC_PREFAB = MAP:WaitForChild("Dynamic"):Clone()
local SUPPLY_DROP_ZONE = MAP:WaitForChild("SupplyDropZone")

local function respawnDead()
    for _, player in Players:GetPlayers() do
        if player.Character == nil then
            local ok, err = pcall(player.LoadCharacter, player)
        
            if not ok then
                warn(`Failed to load character {player}: {err}`)
            end
        else
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if humanoid == nil or humanoid.Health <= 0 then
                task.spawn(player.LoadCharacter, player)
            end
        end
    end
end

local function healPlayers()
    for _, player in Players:GetPlayers() do
        if player.Character == nil then
            continue
        end

        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end

local function newDynamic()
    local existing = MAP:FindFirstChild("Dynamic")

    if existing then
        existing:Destroy()
    end

    local new = DYNAMIC_PREFAB:Clone()
    new.Parent = MAP

    return new
end

local function spawnSupplyDrop(dynamic, radius: Vector3)
    local drop = ServerStorage.SupplyDrop:Clone()
    drop:PivotTo(CFrame.new(((radius * (Random.new():NextUnitVector() / 2)) + Vector3.new(0, 200, 0))))
    drop.Parent = dynamic
end

local function resetStats()
    for _, player in Players:GetPlayers() do
        player:SetAttribute("money", 0)
    end
end

local function match(dynamic)
    local roundNumber = 0
    local vitalsTracker = PlayerVitalsTracker()
    local over = false

    resetStats()

    local function mapFilter(instance: Instance)
        return instance:IsDescendantOf(MAP)
    end

    local function pickSpawn(): BasePart
        local spawns = filter(CollectionService:GetTagged("mouse_spawn"), mapFilter)
        return spawns[math.random(1, #spawns)]
    end

    local loop = task.spawn(function()
        while true do
            roundNumber += 1

            if roundNumber > 1 and roundNumber%3 == 1 then
                for _ = 1, math.random(1, 2) do
                    spawnSupplyDrop(dynamic, SUPPLY_DROP_ZONE.Size)
                end
            end

            Players.CharacterAutoLoads = true
            respawnDead()

            if roundNumber == 1 then
                remotes.displayHint:FireAllClients({
                    text = `defend against the mice!`,
                    duration = 5
                })

                task.wait(3)
            else
                remotes.displayHint:FireAllClients({
                    text = `the mice will return in {ROUND_START_TIME} seconds...`,
                    duration = ROUND_START_TIME
                })

                task.wait(ROUND_START_TIME)
            end

            remotes.displayHint:FireAllClients({
                text = `round {roundNumber}`,
                duration = 5
            })

            local waves = math.floor(math.clamp(1 + roundNumber * 0.5, 1, 4))
            local waveSize = 5 + math.min(roundNumber * 2, 10)
            local spawnVarianceChance = math.min(100 - (roundNumber * 10), 10)
            local spawnPoint = pickSpawn()

            Players.CharacterAutoLoads = false

            for _ = 1, waves do
                if over then
                    return
                end

                if roundNumber > 3 and math.random(1, 15) == 1 then
                    spawnSupplyDrop(dynamic, SUPPLY_DROP_ZONE.Size)
                end

                for _ = 1, waveSize do
                    if over then
                        return
                    end

                    local enemy = MOUSE_PREAFB:Clone()
                    enemy:PivotTo(CFrame.new(spawnPoint.Position))

                    if spawnPoint:GetAttribute("disable_ai") then
                        enemy:RemoveTag("mouse_ai")
                    end

                    enemy.Parent = dynamic
    
                    if roundNumber > SPANW_VARIANCE_MIN_ROUND and math.random(1, spawnVarianceChance) == 1 then
                        spawnPoint = pickSpawn()
                    end
        
                    task.wait(2)
                end

                if waves > 1 then
                    task.wait(TIME_BETWEEN_WAVES)
                end
            end 

            while #filter(CollectionService:GetTagged("enemy"), mapFilter) > 0 do
                CollectionService:GetInstanceRemovedSignal("enemy"):Wait()
            end

            remotes.displayHint:FireAllClients({
                text = `all enemies defeated! ^-^`,
            })

            print("All enemies defeated!")
            task.wait(3)
        end
    end)

    local function onVitalsUpdated(_, alive)
        if next(alive) == nil then
            if over then
                return
            end

            over = true
            task.cancel(loop)
            vitalsTracker:destroy()
            print("Game over!", alive, _)
            dynamic:Destroy()

            remotes.displayHint:FireAllClients({
                text = `GAME OVER!`,
                duration = 7
            })

            remotes.displayHint:FireAllClients({
                text = `you made it to round {roundNumber}!`,
                duration = 7
            })
        end
    end

    vitalsTracker.onChange:Connect(onVitalsUpdated)
    return loop
end

while true do
    Players.CharacterAutoLoads = true
    respawnDead()

    if #Players:GetPlayers() == 0 then
        Players.PlayerAdded:Wait()
    end

    local dynamic = newDynamic()

    remotes.displayHint:FireAllClients({
        text = `intermission... ({INTERMISSION_DURATION})`,
        duration = INTERMISSION_DURATION
    })

    task.wait(INTERMISSION_DURATION)
    print("New match starting")

    local ok, result = pcall(match, dynamic)

    if ok then
        local loop = result :: thread
        
        repeat
            task.wait(1)
        until coroutine.status(loop) == "dead"
    else
        warn(`Match error: {result}`)
    end

    task.wait(7)
end
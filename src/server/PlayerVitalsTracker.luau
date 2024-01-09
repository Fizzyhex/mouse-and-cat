local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Signal = require(ReplicatedStorage.Packages.Signal)
local GarbageUtil = require(ReplicatedStorage.shared.GarbageUtil)

local function PlayerVitalsTracker()
    local binAdd, binEmpty = GarbageUtil.makeBin({})
    
    local alive: {[Player]: true} = {}

    local self = {}
    self.onChange = Signal.new()

    binAdd(Observers.observeCharacter(function(player, character)
        alive[player] = true
        self.onChange:Fire(player, alive)
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid

        local connection = humanoid.Died:Connect(function()
            alive[player] = nil
            self.onChange:Fire(player, alive)
        end)

        return function()
            alive[player] = nil
            self.onChange:Fire(player, alive)
            connection:Disconnect()
        end
    end))

    function self:destroy()
        binEmpty()
    end

    function self:isAlive(player: Player): boolean
        return alive[player] == true
    end

    return self
end

return PlayerVitalsTracker
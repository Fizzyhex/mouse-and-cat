export type Obstacle = "enemy" | "environment" | "none"

export type BaseState<Target> = {
    target: Target?
}

export type Idle<Target> = BaseState<Target> & {
    phase: "idle",
}

export type Pursuit<Target> = BaseState<Target> & {
    phase: "pursuit",
    target: Target,
}

export type Attacking<Target> = BaseState<Target> & {
    phase: "attacking",
    target: Target,
    start: number,
}

export type AnyState<Target> = Idle<Target> | Pursuit<Target> | Attacking<Target>

export type Context<Target> = {
    position: Vector3,
    targets: { [Target]: Vector3 },
    obstacle: Obstacle,
}

local ATTACK_DURATION = 1

local function findClosestTarget<T>(ourPosition: Vector3, targets: { [T]: Vector3 }): T?
    local closest: T?
    local closestDistance = math.huge
    
    for index, targetPosition in targets do
        local distance = (ourPosition - targetPosition).Magnitude

        if closest == nil then
            closest = index
            closestDistance = distance
        elseif distance < closestDistance then
            closest = index
            closestDistance = distance
        end
    end

    return closest
end

local MouseBrain = {}

function MouseBrain.initState<Target>(): AnyState<Target>
    return {
        phase = "idle" :: "idle",
        target = nil,
    }
end

function MouseBrain.step<Target>(context: Context<Target>, state: AnyState<Target>): AnyState<Target>
    if state.target and not context.targets[state.target] then
        return {
            phase = "idle" :: "idle",
            target = nil,
        }
    end

    if state.phase == "idle" then
        local closestTarget = findClosestTarget(context.position, context.targets)
    
        if closestTarget then
            return {
                phase = "pursuit" :: "pursuit",
                target = closestTarget,
            }
        else
            return table.clone(state) :: AnyState<Target>
        end
    elseif state.phase == "pursuit" then
        if context.obstacle ~= "none" then
            return {
                phase = "attacking" :: "attacking",
                target = state.target,
                start = os.clock(),
            }
        else
            return table.clone(state) :: AnyState<Target>
        end
    elseif state.phase == "attacking" then
        if os.clock() - state.start > ATTACK_DURATION then
            return {
                phase = "pursuit" :: "pursuit",
                target = state.target,
            }
        else
            return table.clone(state) :: AnyState<Target>
        end
    end

    error(`Unhandled state "{state.phase}"`)
end

return MouseBrain
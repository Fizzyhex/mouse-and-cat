local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local DamageUtil = {}

DamageUtil.onDamage = Signal.new() :: Signal.Signal<Instance, Instance, number>

function DamageUtil.canDamage(from: Instance, to: Instance): boolean
	if Players:GetPlayerFromCharacter(from) and Players:GetPlayerFromCharacter(to) then
		return false
	end

	return true
end

function DamageUtil.getKind(subject: Instance): "character" | "environment"
	local humanoid = subject:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		return "character"
	end

	return "environment"
end

function DamageUtil.getHealth(subject: Instance)
	local humanoid = subject:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		return humanoid.Health
	end

	return subject:GetAttribute("health") or 0
end

function DamageUtil.dealDamage(from: Instance, to: Instance, damage: number)
	local humanoid = to:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		humanoid:TakeDamage(damage)
	end

	local health = to:GetAttribute("health")

	if health then
		to:SetAttribute("health", math.max(health - damage, 0))
	end

	DamageUtil.onDamage:Fire(from, to, damage)
end

function DamageUtil.subjectFromInstance(instance: Instance): Instance?
	local function check(instance: Instance): Instance?
		if instance:GetAttribute("health") then
			return instance
		end

		local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			return instance
		end

		return nil
	end

	local subject = check(instance)

	if subject then
		return subject
	end

	if instance.Parent then
		subject = check(instance.Parent)

		if subject then
			return subject
		end
	end

	return nil
end

return DamageUtil

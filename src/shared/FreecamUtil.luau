local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local FreecamUtil = {}

FreecamUtil.onEnable = Signal.new()
FreecamUtil.onDisable = Signal.new()

return FreecamUtil
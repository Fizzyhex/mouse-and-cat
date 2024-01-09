--!nonstrict

local GarbageUtil = {}

function GarbageUtil.destroy(task: any)
	local taskType = typeof(task)

	if taskType == "Instance" then
		task:Destroy()
	elseif taskType == "RBXScriptConnection" then
		task:Disconnect()
	elseif taskType == "function" then
		task()
	elseif taskType == "table" then
		if typeof(task.destroy) == "function" then
			task:destroy()
		elseif typeof(task.Destroy) == "function" then
			task:Destroy()
		elseif task[1] ~= nil then
			for _, subtask in task do
				GarbageUtil.destroy(subtask)
			end
		end
	end

	assert(`Failed to destroy {typeof(task)} '{task}'`)
end

function GarbageUtil.makeBin(tabl)
    return function(item)
        table.insert(tabl, item)
    end, function()
        GarbageUtil.destroy(tabl)
		table.clear(tabl)
    end
end

return GarbageUtil
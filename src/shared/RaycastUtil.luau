local RaycastUtil = {}

function RaycastUtil.recursiveRaycast(
	origin: Vector3,
	direction: Vector3,
	raycastParams: RaycastParams?,
	filter: (RaycastResult) -> unknown
): RaycastResult?
	raycastParams = raycastParams or RaycastParams.new()
	assert(raycastParams)
	local ignoreList = raycastParams.FilterDescendantsInstances

	while true do
		local result = workspace:Raycast(origin, direction, raycastParams)

		if result then
			if filter(result) then
				return result
			else
				table.insert(ignoreList, result.Instance)
				raycastParams.FilterDescendantsInstances = ignoreList
			end
		else
			return nil
		end
	end
end

function RaycastUtil.recursiveBlockcast(
	cframe: CFrame,
	size: Vector3,
	direction: Vector3,
	raycastParams: RaycastParams?,
	filter: (RaycastResult) -> unknown
): RaycastResult?
	raycastParams = raycastParams or RaycastParams.new()
	assert(raycastParams)
	local ignoreList = raycastParams.FilterDescendantsInstances

	while true do
		local result = workspace:Blockcast(cframe, size, direction, raycastParams)

		if result then
			if filter(result) then
				return result
			else
				table.insert(ignoreList, result.Instance)
				raycastParams.FilterDescendantsInstances = ignoreList
			end
		else
			return nil
		end
	end
end

return RaycastUtil

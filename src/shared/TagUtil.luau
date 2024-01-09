local CollectionService = game:GetService("CollectionService")
local TagUtil = {}

function TagUtil.filter(tag: string, filter: (Instance) -> (unknown)): {Instance}
    local tagged = CollectionService:GetTagged(tag)

    for index, instance in tagged do
        if not filter(instance) then
            table.remove(tagged, index)
        end
    end

    return tagged
end

return TagUtil
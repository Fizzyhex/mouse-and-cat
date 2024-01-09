local function filter<a, b>(tabl: {[a]: b}, filter: (b, a) -> (unknown)): {[a]: b}
    local filtered = {}
    
    for index, value in tabl do
        if filter(value, index) then
            filtered[index] = value
        end
    end

    return filtered
end

return filter
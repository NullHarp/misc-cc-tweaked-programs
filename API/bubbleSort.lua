local function sort(data)
    -- Convert input table to a sortable array
    local sorted_data = {}
    for name, count in pairs(data) do
        table.insert(sorted_data, {name = name, count = count})
    end

    local function swap(a, b, table)

        if table[a] == nil or table[b] == nil then
            return false
        end
    
        if table[a].count < table[b].count then
            table[a], table[b] = table[b], table[a]
            return true
        end
    
        return false
    
    end
    
    
    local function bubblesort(array)
    
        for i=1,table.maxn(array) do
    
            local ci = i
            ::redo::
            if swap(ci, ci+1, array) then
                ci = ci - 1
                goto redo
            end
        end
    end
    bubblesort(sorted_data)

    return sorted_data
end

return {sort = sort}
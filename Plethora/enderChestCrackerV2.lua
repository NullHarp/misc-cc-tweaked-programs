local enderChests = table.pack(peripheral.find("ender_storage"))

local new_colors = {}

for i, v in pairs(colors) do
    if type(v) == "number" then
        new_colors[i] = v
    end
end

local combinations = {}
local combinations_labels = {}

for i, v in pairs(new_colors) do
    for i1, v1 in pairs(new_colors) do
        for i2, v2 in pairs(new_colors) do
            table.insert(combinations,{x=v,y=v1,z=v2})
            table.insert(combinations_labels,{x=i,y=i1,z=i2})
        end
    end
end

local function findItem(list)
    for _, item in pairs(list) do
        if type(item) ~= "nil" then
            return true
        end
    end
    return false
end

local function computeCombination(x,y,z,enderChest)
    enderChest.setFrequency(x,y,z)
    local list = enderChest.list()
    local success = findItem(list)
    return success
end

local function divideTable(tbl, divisions)
    local result = {}
    local totalSize = #tbl
    local chunkSize = math.ceil(totalSize / divisions)
    
    for i = 1, divisions do
        result[i] = {}
    end
    
    for i, value in ipairs(tbl) do
        local chunkIndex = math.ceil(i / chunkSize)
        table.insert(result[chunkIndex], value)
    end

    return result
end

local dividedLabels = divideTable(combinations_labels, enderChests.n)
local divided = divideTable(combinations, enderChests.n)


local function computeSegment(segmentIndex)
    for i = #divided[segmentIndex], 1, -1 do
        if computeCombination(divided[segmentIndex][i].x,divided[segmentIndex][i].y,divided[segmentIndex][i].z,enderChests[segmentIndex]) then
            print("Found Chest: ", dividedLabels[segmentIndex][i].x, dividedLabels[segmentIndex][i].y, dividedLabels[segmentIndex][i].z)
        end
        
        table.remove(divided[segmentIndex],i)
        table.remove(dividedLabels[segmentIndex],i)
    end
end

local functions = {}

for i = 1, enderChests.n do
    table.insert(functions, function()
        computeSegment(i)
    end)
end

local startTime = os.clock()

-- Run all functions in parallel
parallel.waitForAll(table.unpack(functions))

local finishTime = os.clock()

local elapsedTime = finishTime-startTime
print("Took",math.floor(elapsedTime),"seconds to compute",#combinations, "premutations at",math.floor(#combinations/elapsedTime),"permutations a second with",math.floor(#combinations/enderChests.n),"permutations per ender chest.")
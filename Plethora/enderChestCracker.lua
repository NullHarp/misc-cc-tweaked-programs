local enderChests = table.pack(peripheral.find("ender_storage"))

if type(enderChests) == "nil" then
    error("Ender Chest not found, can't procede.")
end

local newColors = {}

local testedCombos = {}

for name, num in pairs(colors) do
    if type(num) == "number" then
        newColors[name] = num
    end
end

local results = {}

local function a()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i..i2..i3]) ~= "nil" then
                    break
                end
                enderChests[1].setFrequency(v,v2,v3)
                local list1 = enderChests[1].list()
                local found = 0
                for i4, v4 in pairs(list1) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i,i2,i3)
                end
                testedCombos[i..i2..i3] = true
            end
        end
    end
end

local function b()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i..i3..i2]) ~= "nil" then
                    break
                end
                enderChests[2].setFrequency(v,v3,v2)
                local list2 = enderChests[2].list()
                local found = 0
                for i4, v4 in pairs(list2) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i,i3,i2)
                end
                testedCombos[i..i3..i2] = true
            end
        end
    end
end

local function c()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i3..i..i2]) ~= "nil" then
                    break
                end
                enderChests[3].setFrequency(v3,v,v2)
                local list3 = enderChests[3].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i3,i,i2)
                end
                testedCombos[i3..i..i2] = true
            end
        end
    end
end

local function d()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i2..i3..i]) ~= "nil" then
                    break
                end
                enderChests[4].setFrequency(v2,v3,v)
                local list3 = enderChests[4].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i2,i3,i)
                end
                testedCombos[i2..i3..i] = true
            end
        end
    end
end

local function e()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i3..i2..i]) ~= "nil" then
                    break
                end
                enderChests[5].setFrequency(v3,v2,v)
                local list3 = enderChests[5].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i3,i2,i)
                end
                testedCombos[i3..i2..i] = true
            end
        end
    end
end

local function f()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i2..i..i3]) ~= "nil" then
                    break
                end
                enderChests[6].setFrequency(v2,v,v3)
                local list3 = enderChests[6].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i2,i,i3)
                end
                testedCombos[i2..i..i3] = true
            end
        end
    end
end

local function a2()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i..i2..i3]) ~= "nil" then
                    break
                end
                enderChests[7].setFrequency(v,v2,v3)
                local list1 = enderChests[7].list()
                local found = 0
                for i4, v4 in pairs(list1) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i,i2,i3)
                end
                testedCombos[i..i2..i3] = true
            end
        end
    end
end

local function b2()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i..i3..i2]) ~= "nil" then
                    break
                end
                enderChests[8].setFrequency(v,v3,v2)
                local list2 = enderChests[8].list()
                local found = 0
                for i4, v4 in pairs(list2) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i,i3,i2)
                end
                testedCombos[i..i3..i2] = true
            end
        end
    end
end

local function c2()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i3..i..i2]) ~= "nil" then
                    break
                end
                enderChests[9].setFrequency(v3,v,v2)
                local list3 = enderChests[9].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i3,i,i2)
                end
                testedCombos[i3..i..i2] = true
            end
        end
    end
end

local function d2()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i2..i3..i]) ~= "nil" then
                    break
                end
                enderChests[10].setFrequency(v2,v3,v)
                local list3 = enderChests[10].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i2,i3,i)
                end
                testedCombos[i2..i3..i] = true
            end
        end
    end
end

local function e2()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i3..i2..i]) ~= "nil" then
                    break
                end
                enderChests[11].setFrequency(v3,v2,v)
                local list3 = enderChests[11].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i3,i2,i)
                end
                testedCombos[i3..i2..i] = true
            end
        end
    end
end

local function f2()
    for i,v in pairs(newColors) do
        for i2,v2 in pairs(newColors) do
            for i3,v3 in pairs(newColors) do
                if type(testedCombos[i2..i..i3]) ~= "nil" then
                    break
                end
                enderChests[12].setFrequency(v2,v,v3)
                local list3 = enderChests[12].list()
                local found = 0
                for i4, v4 in pairs(list3) do
                    if type(v) ~= "nil" then
                        found = found+1
                    end
                end
                if found > 0 then
                    print("Found a match",i2,i,i3)
                end
                testedCombos[i2..i..i3] = true
            end
        end
    end
end

local start = os.clock()

local function alpha()
    parallel.waitForAll(a,b,c,d,e,f)
end

local function beta()
    --sleep(0.1)
    parallel.waitForAll(a2,b2,c2,d2,e2,f2)
end

parallel.waitForAll(alpha)


local endTime = os.clock()
print("Took: ",endTime-start," seconds to compute")
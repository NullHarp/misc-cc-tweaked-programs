local function compressBlockData(blockData)
    local file = fs.open("map.json", "r")
    local map = textutils.unserialiseJSON(file.readAll())
    file.close()

    local scanned_lookup = {}
    for _, block in ipairs(blockData) do
        local key = ("%d,%d,%d"):format(block.x, block.y, block.z)
        scanned_lookup[key] = block
    end

    local complete_scan = {}
    for _, pos in ipairs(map) do
        local key = ("%d,%d,%d"):format(pos.x, pos.y, pos.z)
        local block = scanned_lookup[key] or {
            x = pos.x,
            y = pos.y,
            z = pos.z,
            name = "minecraft:air"
        }
        table.insert(complete_scan, block)
    end

    local block_to_char = {
        ["minecraft:air"] = string.char(1)
    }
    local next_char_code = 2

    for _, block in ipairs(complete_scan) do
        local name = block.name
        if not block_to_char[name] then
            block_to_char[name] = string.char(next_char_code)
            next_char_code = next_char_code + 1
        end
    end

    local compressed = {}
    for _, pos in ipairs(map) do
        local key = ("%d,%d,%d"):format(pos.x, pos.y, pos.z)
        local block = scanned_lookup[key]

        if block then
            table.insert(compressed, string.char(2)) -- not air
        else
            table.insert(compressed, string.char(1)) -- air
        end
    end

    return table.concat(compressed)
end


local function decompressBlockData(compressedBlocks)
    local file = fs.open("map.json","r")
    local json_map = file.readAll()
    file.close()
    local map = textutils.unserialiseJSON(json_map)

    local decompressedBlocksRaw = {}
    for i = 1, #compressedBlocks do
        decompressedBlocksRaw[i] = string.byte(string.sub(compressedBlocks,i,i))
    end

    local decompressedBlocks = {}
    for i = 1, #decompressedBlocksRaw do
        decompressedBlocks[i] = {}
        decompressedBlocks[i].name = decompressedBlocksRaw[i]
        decompressedBlocks[i].x = map[i].x
        decompressedBlocks[i].y = map[i].y
        decompressedBlocks[i].z = map[i].z
    end
    return decompressedBlocks
end

return {compressBlockData = compressBlockData,decompressBlockData = decompressBlockData}

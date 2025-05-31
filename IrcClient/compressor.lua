local base64 = require("base64")

local function compressBlockData(blockData)
    local block_name_lookup = {}

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
        ["minecraft:unknown"] = "A",
        ["minecraft:air"] = "B",
        ["minecraft:water"] = "C"
    }
    local next_char_code = 4

    for _, block in ipairs(complete_scan) do
        local name = block.name
        if not block_to_char[name] then
            block_to_char[name] = base64.encode(next_char_code) or base64.encode(1)
            next_char_code = next_char_code + 1
        end
    end

    for name, code in pairs(block_to_char) do
        block_name_lookup[base64.decode(code)] = name
    end

    local compressed = {}
    for _, block in ipairs(complete_scan) do
        table.insert(compressed, block_to_char[block.name])
    end

    return table.concat(compressed),
    table.concat(block_name_lookup,";")
end


local function decompressBlockData(compressedBlocks, compressedBlockLookup)
    local block_lookup = {}
    for name in string.gmatch(compressedBlockLookup, "([^;]+)") do
        table.insert(block_lookup,name)
    end

    local file = fs.open("map.json","r")
    local json_map = file.readAll()
    file.close()
    local map = textutils.unserialiseJSON(json_map)

    local decompressedBlocksRaw = {}
    for i = 1, #compressedBlocks do
        decompressedBlocksRaw[i] = base64.decode(string.sub(compressedBlocks,i,i))
    end

    local decompressedBlocks = {}
    for i = 1, #decompressedBlocksRaw do
        decompressedBlocks[i] = {}
        decompressedBlocks[i].name = block_lookup[decompressedBlocksRaw[i]]
        decompressedBlocks[i].x = map[i].x
        decompressedBlocks[i].y = map[i].y
        decompressedBlocks[i].z = map[i].z
    end
    return decompressedBlocks
end

return {compressBlockData = compressBlockData,decompressBlockData = decompressBlockData}

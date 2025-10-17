local lookup = {
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "+",
    "/",
}

local reverse_lookup = {
    ["A"] = 1,
    ["B"] = 2,
    ["C"] = 3,
    ["D"] = 4,
    ["E"] = 5,
    ["F"] = 6,
    ["G"] = 7,
    ["H"] = 8,
    ["I"] = 9,
    ["J"] = 10,
    ["K"] = 11,
    ["L"] = 12,
    ["M"] = 13,
    ["N"] = 14,
    ["O"] = 15,
    ["P"] = 16,
    ["Q"] = 17,
    ["R"] = 18,
    ["S"] = 19,
    ["T"] = 20,
    ["U"] = 21,
    ["V"] = 22,
    ["W"] = 23,
    ["X"] = 24,
    ["Y"] = 25,
    ["Z"] = 26,
    ["a"] = 27,
    ["b"] = 28,
    ["c"] = 29,
    ["d"] = 30,
    ["e"] = 31,
    ["f"] = 32,
    ["g"] = 33,
    ["h"] = 34,
    ["i"] = 35,
    ["j"] = 36,
    ["k"] = 37,
    ["l"] = 38,
    ["m"] = 39,
    ["n"] = 40,
    ["o"] = 41,
    ["p"] = 42,
    ["q"] = 43,
    ["r"] = 44,
    ["s"] = 45,
    ["t"] = 46,
    ["u"] = 47,
    ["v"] = 48,
    ["w"] = 49,
    ["x"] = 50,
    ["y"] = 51,
    ["z"] = 52,
    ["0"] = 53,
    ["1"] = 54,
    ["2"] = 55,
    ["3"] = 56,
    ["4"] = 57,
    ["5"] = 58,
    ["6"] = 59,
    ["7"] = 60,
    ["8"] = 61,
    ["9"] = 62,
    ["+"] = 63,
    ["/"] = 64,
}

---Encodes a table of numbers representing the numerical representation of base64 chars into a base64 string
---@param data table The list of numbers, each representing a differnt base64 char
---@return string res The base64 string resulting from the provided data
local function encodeTable(data)
    local res = ""
    for _, num in ipairs(data) do
        if not lookup[num] then
            error("Unsupported number found: "..num)
        end
        res = res..lookup[num]
    end
    return res
end

---Decodes a base64 string into a list of numbers representing the numerical representation of the char (ex: A = 1)
---@param data string The base64 encoded string
---@return table res The data represented as a list of nums
local function decodeString(data)
    local res = {}
    for char in string.gmatch(data, ".") do
        if not reverse_lookup[char] then
            error("Unsupported char found: "..char)
        end
        table.insert(res,reverse_lookup[char])
    end
    return res
end

---Encodes a char into base64 based off the number representing the char
---@param char integer
---@return string base64_char
local function encode(char)
    if not lookup[char] then
        --error("Unsupported char found: "..char)
    end
    return lookup[char] or "?"
end

---Decodes a char from base64 into the number representing the char
---@param base64_char string
---@return integer
local function decode(base64_char)
    if not reverse_lookup[base64_char] then
        error("Unsupported char found: "..base64_char)
    end
    return reverse_lookup[base64_char]
end

return {encode = encode, decode = decode, encodeTable = encodeTable, decodeString = decodeString}
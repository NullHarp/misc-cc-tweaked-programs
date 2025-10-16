local base64 = require("base64")

local test_data = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

local function encode(data)
    local result = ""
    local running_total = 1
    local last_char = " "
    for i = 1, #data+1 do
        local data_char = string.sub(data,i,i)
        if data_char == last_char and running_total < 64 then
            running_total = running_total + 1
        elseif last_char ~= " " then
            local encoded_str = base64.encode(running_total)
            encoded_str = encoded_str .. last_char
            running_total = 1
            result = result .. encoded_str
        end
        last_char = data_char
    end
    return result
end

local function decode(data)
    local result = ""
    for i = 1, #data, 2 do
        local len_char = string.sub(data,i,i)
        local data_char = string.sub(data,i+1,i+1)
        local len = base64.decode(len_char)
        local decomp = string.rep(data_char,len)
        result = result .. decomp
    end
    return result
end

return {encode = encode, decode = decode}
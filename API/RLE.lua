local base64 = require("base64")

local test_data = "ABC"

local function encode(data)
    local result = ""
    local running_total = 1
    local last_char = " "
    for i = 1, #data+1 do
        local data_char = string.sub(data,i,i)
        if data_char == last_char and running_total < 4096 then
            running_total = running_total + 1
        elseif last_char ~= " " then
            local encoded_str = ""
            if running_total > 64 then
                local len = math.floor(running_total/64)
                local len_2 = running_total%64
                encoded_str = base64.encode(len+1)..base64.encode(len_2+1)
            else
                encoded_str = "A"..base64.encode(running_total)
            end
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
    for i = 1, #data, 3 do
        local len_char = string.sub(data,i,i)
        local len_char_2 = string.sub(data,i+1,i+1)
        local data_char = string.sub(data,i+2,i+2)
        local len = base64.decode(len_char)
        local len_2 = base64.decode(len_char_2)
        local decomp = string.rep(data_char,((len-1)*64)+len_2-1)
        print(len_char,len_char_2)
        print(((len-1)*64)+len_2-1)
        result = result .. decomp
    end
    return result
end

return {encode = encode, decode = decode}
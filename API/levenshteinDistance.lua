---Calculates the minimum number of single-character edits (insertions, deletions, 
---or substitutions) required to transform one string into another.
---@param str1 string
---@param str2 string
---@return integer distance
local function levenshtein(str1, str2)
    local len1, len2 = #str1, #str2

    -- Create a table to store the distances
    local distance = {}
    for i = 0, len1 do
        distance[i] = {}
        for j = 0, len2 do
            -- Initialize the distance table
            if i == 0 then
                distance[i][j] = j
            elseif j == 0 then
                distance[i][j] = i
            else
                distance[i][j] = 0
            end
        end
    end

    -- Compute the distances
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (str1:sub(i, i) == str2:sub(j, j)) and 0 or 1
            distance[i][j] = math.min(
                distance[i - 1][j] + 1,   -- Deletion
                distance[i][j - 1] + 1,   -- Insertion
                distance[i - 1][j - 1] + cost -- Substitution
            )
        end
    end
    return distance[len1][len2]
end

return {levenshtein = levenshtein}
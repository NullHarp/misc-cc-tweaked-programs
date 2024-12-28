local input = ...

local function tokenize(expression)
    local tokens = {}
    local i = 1
    while i <= #expression do
        local char = expression:sub(i, i)
        if char:match("%d") then
            -- Parse numbers
            local num = ""
            while i <= #expression and expression:sub(i, i):match("[%d%.]") do
                num = num .. expression:sub(i, i)
                i = i + 1
            end
            table.insert(tokens, tonumber(num))
        elseif char:match("[%+%-%*%/%(%)%^]") then
            -- Operators and parentheses
            table.insert(tokens, char)
            i = i + 1
        elseif char:match("%s") then
            -- Skip whitespace
            i = i + 1
        else
            error("Unexpected character: " .. char)
        end
    end
    return tokens
end


local function toPostfix(tokens)
    local precedence = {["+"] = 1, ["-"] = 1, ["*"] = 2, ["/"] = 2, ["^"] = 3}
    local rightAssociative = {["^"] = true}
    local output = {}
    local operators = {}

    for _, token in ipairs(tokens) do
        if type(token) == "number" then
            table.insert(output, token)
        elseif token:match("[%+%-%*%/%^]") then
            while #operators > 0 and operators[#operators] ~= "(" do
                local top = operators[#operators]
                if (rightAssociative[token] and precedence[top] > precedence[token]) or
                   (not rightAssociative[token] and precedence[top] >= precedence[token]) then
                    table.insert(output, table.remove(operators))
                else
                    break
                end
            end
            table.insert(operators, token)
        elseif token == "(" then
            table.insert(operators, token)
        elseif token == ")" then
            while operators[#operators] ~= "(" do
                table.insert(output, table.remove(operators))
                if #operators == 0 then
                    error("Mismatched parentheses")
                end
            end
            table.remove(operators) -- Remove "("
        end
    end

    while #operators > 0 do
        table.insert(output, table.remove(operators))
    end

    return output
end


local function evaluatePostfix(postfix)
    local stack = {}

    for _, token in ipairs(postfix) do
        if type(token) == "number" then
            table.insert(stack, token)
        elseif token:match("[%+%-%*%/%^]") then
            local b = table.remove(stack)
            local a = table.remove(stack)
            if token == "+" then
                table.insert(stack, a + b)
            elseif token == "-" then
                table.insert(stack, a - b)
            elseif token == "*" then
                table.insert(stack, a * b)
            elseif token == "/" then
                table.insert(stack, a / b)
            elseif token == "^" then
                table.insert(stack, a ^ b)
            end
        else
            error("Unexpected token: " .. token)
        end
    end

    return stack[1]
end


local function parseMath(expression)
    local tokens = tokenize(expression)
    local postfix = toPostfix(tokens)
    return evaluatePostfix(postfix)
end

return {parseMath = parseMath}
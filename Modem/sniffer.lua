local port = ...
port = tonumber(port)
-- Function to solve a linear system using Gaussian elimination
local function solve_linear_system(A, b)
    local n = #A
    for i = 1, n do
        -- Pivot for the largest value in column i
        local maxRow = i
        for k = i + 1, n do
            if math.abs(A[k][i]) > math.abs(A[maxRow][i]) then
                maxRow = k
            end
        end
        -- Swap rows
        A[i], A[maxRow] = A[maxRow], A[i]
        b[i], b[maxRow] = b[maxRow], b[i]

        -- Make all rows below row i in column i zero
        for k = i + 1, n do
            local factor = A[k][i] / A[i][i]
            for j = i, n do
                A[k][j] = A[k][j] - factor * A[i][j]
            end
            b[k] = b[k] - factor * b[i]
        end
    end

    -- Back substitution
    local x = {}
    for i = n, 1, -1 do
        x[i] = b[i]
        for j = i + 1, n do
            x[i] = x[i] - A[i][j] * x[j]
        end
        x[i] = x[i] / A[i][i]
    end
    return x
end

-- Trilateration function
local function trilaterate(points, distances)
    local A = {}
    local b = {}

    -- Construct the linear system
    for i = 2, 4 do
        local x_diff = points[i][1] - points[1][1]
        local y_diff = points[i][2] - points[1][2]
        local z_diff = points[i][3] - points[1][3]
        local rhs = (
            distances[1]^2 - distances[i]^2
            + points[i][1]^2 - points[1][1]^2
            + points[i][2]^2 - points[1][2]^2
            + points[i][3]^2 - points[1][3]^2
        )
        table.insert(A, {2 * x_diff, 2 * y_diff, 2 * z_diff})
        table.insert(b, rhs)
    end

    -- Solve the linear system
    return solve_linear_system(A, b)
end

local modem_0 = peripheral.wrap("modem_0")
local modem_1 = peripheral.wrap("modem_1")
local modem_2 = peripheral.wrap("modem_2")
local modem_3 = peripheral.wrap("modem_3")

modem_0.open(port)
modem_1.open(port)
modem_2.open(port)
modem_3.open(port)
local data_points = 0
local points = {
    {104, 0, 263},  -- Point 0 (x1, y1, z1)
    {99, 0, 263},  -- Point 1 (x2, y2, z2)
    {99, 0, 258},  -- Point 2 (x3, y3, z3)
    {99, 4, 263}   -- Point 3 (x4, y4, z4)
}
local distances = {}
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    data_points = data_points + 1
    if side == "modem_0" then
        distances[1] = distance
    elseif side == "modem_1" then
        distances[2] = distance
    elseif side == "modem_2" then
        distances[3] = distance
    elseif side == "modem_3" then
        distances[4] = distance
    end
    if data_points == 4 then
        data_points = 0
        print(tostring(message).." "..side)
        local position = trilaterate(points, distances)
        print("Position:", math.floor(position[1]*100)/100, math.floor(position[2]*100)/100, math.floor(position[3]*100)/100)    
    end
end
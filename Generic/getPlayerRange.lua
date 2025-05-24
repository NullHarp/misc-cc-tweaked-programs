local function getPlayerDistance(scanner, playerName, maxRange, precision)
  precision = precision or 0.05  -- Lower = more precise
  maxRange = maxRange or 1000    -- Prevent excessive searching

  -- Check if player is in range at all
  if not scanner.isPlayerInRange(maxRange, playerName) then
    print("Player", playerName, "not in range (max", maxRange .. ")")
    return nil
  end

  local low = 0
  local high = maxRange
  local attempts = 0

  while (high - low) > precision do
    local mid = (low + high) / 2
    if scanner.isPlayerInRange(mid, playerName) then
      high = mid
    else
      low = mid
    end
    attempts = attempts + 1
    if attempts > 100 then
      print("Warning: Distance search took too long.")
      break
    end
  end

  local result = (low + high) / 2
  print(string.format("Estimated distance to %s: %.3f blocks", playerName, result))
  return result
end


local player_name = ...

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

local playerDet_0 = peripheral.wrap("playerDetector_0")
local playerDet_1 = peripheral.wrap("playerDetector_1")
local playerDet_2 = peripheral.wrap("playerDetector_2")
local playerDet_3 = peripheral.wrap("playerDetector_3")

local points = {
    {3, -6, -2},  -- Point 0 (x1, y1, z1)
    {3, -9, -2},  -- Point 1 (x2, y2, z2)
    {3, -9, 2},  -- Point 2 (x3, y3, z3)
    {-1, -9, -2}   -- Point 3 (x4, y4, z4)
}
local distances = {}

local range = 500

distances[1] = getPlayerDistance(playerDet_0,player_name,5000)
distances[2] = getPlayerDistance(playerDet_1,player_name,5000)
distances[3] = getPlayerDistance(playerDet_2,player_name,5000)
distances[4] = getPlayerDistance(playerDet_3,player_name,5000)

local position = trilaterate(points, distances)
print("Position:", math.floor(position[1]*100)/100, math.floor(position[2]*100)/100, math.floor(position[3]*100)/100)
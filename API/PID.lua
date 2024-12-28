---Creates a new PID table using the inputed variables as a template.
---@param setKp number
---@param setKi number
---@param setKd number
---@param target number
---@param current number
---@return table
local function makePID(setKp,setKi,setKd,target,current)
    local pidData = {
        Kp = setKp,
        Ki = setKi,
        Kd = setKd,
        last_error = 0,
        integral = 0,
        current = 0,
        target = target
    }
    if pidData.current ~= nil  then
        pidData.current = current
    end
    return pidData
end

---Takes in PID data and outputs the computed PID signal based off the provided data
---@param pidData table
---@return number
local function PID(pidData)
    -- Calculate error
    local error = pidData.target - pidData.current
    
    -- Proportional term
    local proportional = pidData.Kp * error
    
    -- Integral term (sum of errors over time)
    pidData.integral = pidData.integral + error
    
    -- Apply integral windup prevention
    if pidData.integral > 100 then
        pidData.integral = 100
    elseif pidData.integral < -100 then
        pidData.integral = -100
    end
    
    local integral_term = pidData.Ki * pidData.integral
    
    -- Derivative term (rate of change of error)
    local derivative = error - pidData.last_error
    local derivative_term = pidData.Kd * derivative
    
    pidData.last_error = error

    -- Calculate control output
    local output = proportional + integral_term + derivative_term
    return output
end

return {makePID = makePID, PID = PID}

--local example = makePID(0.15,0.01,1.4,inputX,pos.x)
--local example_output = PID(example)
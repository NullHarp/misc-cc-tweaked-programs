local modem = peripheral.find("modem")

local serverChannel = 301

if not modem then
    error("Modem is required for successful operation.",0)
end

local clientAddress = ""

modem.open(serverChannel)

---Sends a request to the server and awaits a response or timesout, whatever comes first
---@param request table Data containing the request to send to server
---@param response_type string What message type are we waiting for
---@param timeout? integer How many seconds do we wait before the request times out
---@return boolean success Did we get the response we wanted
---@return table|string responseData The message response, or the reason why it failed
local function sendRequest(request, response_type, timeout)
    sleep(0.05)
    modem.transmit(serverChannel,serverChannel,request)
    timeout = timeout or 5
    local timerId = os.startTimer(timeout)
    while true do
        local event, arg1, arg2, arg3, arg4, arg5 = os.pullEvent()
        if event == "modem_message" then
            if arg1 == peripheral.getName(modem) and arg2 == serverChannel and arg3 == serverChannel then
                if type(arg4) == "table" then
                    local message = arg4
                    if message.type == response_type then
                        if message.clientAddress == request.clientAddress then
                            return true, message
                        end
                    elseif message.type == "requestFailure" then
                        return false, message.reason
                    end
                end
            end
        elseif event == "timer" then
            if arg1 == timerId then
                return false, "Request timed out"
            end
        end
    end
end

local function verifyAddress(address)
    local packet = {
        type = "verifyAddress",
        clientAddress = address
    }
    local success, msg = sendRequest(packet,"addressValidity",5)
    if success then
        return msg.isValid
    else
        return false
    end
end

---Sets the CMail address to use for the client
---@param address string
local function setAddress(address)
    if verifyAddress(address) then
        clientAddress = address
        sleep(0.1)
        return true
    else
        return false
    end
end

---Requests the clients emails stored in the server
local function requestMail()
    local packet = {
        type = "getMail",
        clientAddress = clientAddress
    }
    local success, response = sendRequest(packet,"mailIndex",5)
    if success then
        return response.index
    else
        error("Could not contact the server to get mail index, please insure mail server on channel "..tostring(serverChannel).." is operational.")
    end
end

---Sends an email to a specified computer id
---@param message string The message contents
---@param targetAddress string Valid cmail address
---@param title? string Optional title to include with email
---@return boolean
local function sendEmail(message, targetAddress, title)
    title = title or ""
    if type(message) ~= "string" then
        error("Message must be string.")
    elseif type(targetAddress) ~= "string" then
        error("Target must be valid address")
    elseif type(title) ~= "string" then
        error("Title must be a string")
    end
    local packet = {
        type = "sendEmail",
        targetAddress = targetAddress,
        clientAddress = clientAddress,
        title = title,
        message = message
    }
    local success, response = sendRequest(packet,"emailSuccess",5)
    return success
end

return {
    setAddress = setAddress,
    sendEmail = sendEmail,
    requestMail = requestMail,
}
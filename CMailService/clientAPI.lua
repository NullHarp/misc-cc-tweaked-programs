local sha2 = require("sha2")

local modems = {peripheral.find("modem")}
local modem = {}
for i,v in pairs(modems) do
    if v.isWireless then
        modem = modems[i]
    end
end
if modem == {} then
    modem = modems[1]
end
local serverChannel = 301

if not modem then
    error("Modem is required for successful operation.",0)
end

local clientAddress = ""

local salt = "bobby"
local passwordHash = ""

modem.open(serverChannel)

local function generateTimestampHash()
    local timestamp = math.floor(os.epoch("utc")/2000)
    return sha2.hash256(passwordHash..timestamp..salt)
end

---Sends a request to the server and awaits a response or timesout, whatever comes first
---@param request table Data containing the request to send to server
---@param response_type string What message type are we waiting for
---@param timeout? integer How many seconds do we wait before the request times out
---@return boolean success Did we get the response we wanted
---@return table|string responseData The message response, or the reason why it failed
local function sendRequest(request, response_type, timeout)
    if not request then
        error("Must specify request.")
    end
    if not response_type then
        error("Must specify response type.")
    end
    timeout = timeout or 5
    request.data = request.data or {}
    request.data.tPasswordHash = generateTimestampHash()
    modem.transmit(serverChannel,serverChannel,request)
    sleep(0.1)
    local timerId = os.startTimer(timeout)
    while true do
        local event, arg1, arg2, arg3, arg4, arg5 = os.pullEvent()

        -- We check if a timer representing the timeout has been pulled
        if event == "timer" then
            --Confirm the id of the pulled timer matches the specified one
            if arg1 == timerId then
                return false, "Request timed out"
            end
        end

        if event == "modem_message" then
            if arg1 == peripheral.getName(modem) and arg2 == serverChannel and arg3 == serverChannel then
                if type(arg4) == "table" then
                    local message = arg4

                    if message.type == "requestFailure" then
                        return false, message.reason
                    end

                    if message.type == response_type then
                        if message.clientAddress == request.clientAddress then
                            return true, message.data
                        end
                    end
                end
            end
        end
    end
end

local function verifyAddress(address, password)
    if not address then
        error("Address not specified.")
    end
    if not password then
        error("Password not specified.")
    end
    passwordHash = sha2.hash256(password..salt)
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
local function setAddress(address,password)
    if not address then
        error("Address not specified.")
    end
    if not password then
        error("Password not specified.")
    end
    if verifyAddress(address,password) then
        clientAddress = address
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
        clientAddress = clientAddress,
        data = {
            title = title,
            message = message,
            targetAddress = targetAddress,
        }
    }
    local success, response = sendRequest(packet,"emailSuccess",5)
    return success
end

return {
    setAddress = setAddress,
    sendEmail = sendEmail,
    requestMail = requestMail,
}
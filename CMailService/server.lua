local server = require("serverAPI")
local logger = require("logger")

local serverLog = logger.getLogHandle("server")

server.registerDomain("cmail.co")
server.registerName("nullharp","cmail.co","test")
server.registerDomain("testing.co")
server.registerName("test","testing.co","test")

local function main()
    print("Starting main request response loop.")
    while true do
        local mType, clientAddress, message = server.receiveRequest()
        print("Got request of type: "..mType)
        serverLog:writeLog("Got request of type: "..mType,"DEBUG")
        if mType == "verifyAddress" then
            local response = {
                type = "addressValidity",
                isValid = server.authenticate(message.tPasswordHash,clientAddress)
            }
            server.sendResponse(response,clientAddress)
            serverLog:writeLog("Sent addressValidity to: "..clientAddress,"DEBUG")
        elseif server.authenticate(message.tPasswordHash, clientAddress) then
            if mType == "getMail" then
                local hasMail, index = server.getMailIndex(clientAddress)
                local response = {
                    type = "mailIndex",
                    hasMail = hasMail,
                    index = index
                }
                server.sendResponse(response,clientAddress)
                serverLog:writeLog("Sent mailIndex to: "..clientAddress,"DEBUG")
            elseif mType == "sendEmail" then
                if server.isValidAddress(message.targetAddress) then
                    local email = {
                        time = os.date("*t"),
                        message = message.message,
                        title = message.title,
                        senderAddress = clientAddress
                    }
                    server.saveEmail(message.targetAddress,email)
                    local response = {
                        type = "emailSuccess"
                    }
                    server.sendResponse(response,clientAddress)
                    serverLog:writeLog("Sent emailSuccess to: "..clientAddress,"DEBUG")
                else
                    local response = {
                        type = "emailFailure",
                        reason = "Invalid target address."
                    }
                    server.sendResponse(response,clientAddress)
                    serverLog:writeLog("Sent emailFailure to: "..clientAddress.." Reason: Invalid target address.","DEBUG")
                end
            end
        else
            local response = {
                type = "requestFailure",
                reason = "Invalid address / password."
            }
            server.sendResponse(response,clientAddress)
            print("Sent requestFailure to: "..clientAddress.." Reason: Invalid address / password.")
            serverLog:writeLog("Sent requestFailure to: "..clientAddress.." Reason: Invalid address.","DEBUG")

        end
        --sleep(0)
    end
end

main()
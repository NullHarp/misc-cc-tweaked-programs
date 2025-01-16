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

modem.open(serverChannel)

---Gets all currently registered domains
---@return table domains A table of all domains and their associated names
local function getDomains()
    local domains = {}
    if fs.exists("domains.json") then
        local file = fs.open("domains.json","r")
        local fileData = file.readAll()
        file.close()
        domains = textutils.unserialiseJSON(fileData)
        return domains
    else
        return {}
    end
end

---Gets the names of the specific domain name
---@param domain_name string Domain name Ex: nullco.com
---@return boolean isDomain
---@return table|nil names Returns all valid names, or nil if the domain doesent exist
local function getDomain(domain_name)
    local domains = getDomains()
    if domains[domain_name] then
        return true, domains[domain_name]
    else
        return false, nil
    end
end

---Attempts to register a new domain in the domains.json
---@param domain string Name of the domain
---@return boolean success Did we successfully register the new domain
local function registerDomain(domain)
    local domains = getDomains()
    if not domains[domain] then
        domains[domain] = {}
    end
    local file = fs.open("domains.json","w")
    local domains_json = textutils.serialiseJSON(domains)
    file.write(domains_json)
    file.close()
    return true
end

---Registers a new name under a domain
---@param name string Represents the name, such as nullharp
---@param domain_name string Valid domain name
---@param password string Password used to authenticate the address
local function registerName(name,domain_name, password)
    local domains = getDomains()
    if domains[domain_name] then
        local existingName = false
        for i, v in pairs(domains[domain_name]) do
            if v == name then
                existingName = true
            end
        end
        if not existingName then
            table.insert(domains[domain_name],name)
        end
        local file = fs.open("domains.json","w")
        local domains_json = textutils.serialiseJSON(domains)
        file.write(domains_json)
        file.close()

        local file = fs.open(domain_name.."/"..name..".acc","w")
        local account = {
            password = {
                hash = "",
                salt = "bobby"
            }
        }
        account.password.hash = sha2.hash256(password..account.password.salt)
        local account_json = textutils.serialiseJSON(account)
        file.write(account_json)
        file.close()
        return true
    else
        return false
    end
end

local function isValidName(name, domain_name)
    local validDomain, names = getDomain(domain_name)
    if not validDomain then
        return false
    else
        for i = 1, #names do
            if names[i] == name then
                return true
            end
        end
        return false
    end
end

local function translateToAddress(name,domain_name)
    if isValidName(name,domain_name) then
        local address = name.."@"..domain_name
        return true, address
    else
        return false, nil
    end

end

local function translateFromAddress(address)
    local s, e = string.find(address,"@", 1, true)
    if not s and not e then
        return false, nil, nil
    elseif s and e then
        local name = string.sub(address, 1, s-1)
        local domain_name = string.sub(address,s+1,#address)
        if isValidName(name,domain_name) then
            return true, name, domain_name
        else
            return false, nil, nil
        end
    end
end

local function authenticate(timestampedPasswordHash, address)
    local success, name, domain_name = translateFromAddress(address)
    if success then
        local file = fs.open(domain_name.."/"..name..".acc","r")
        local fileData = file.readAll()
        file.close()
        local account_tbl = textutils.unserialiseJSON(fileData)
        local password = account_tbl.password
        local hash = password.hash
        local salt = password.salt
        local timestamp = math.floor(os.epoch("utc")/2000)
        local tPasswordHash = sha2.hash256(hash..timestamp..salt)
        if timestampedPasswordHash == tPasswordHash then
            return true
        else
            timestamp = timestamp-1
            tPasswordHash = sha2.hash256(hash..timestamp..salt)
            if timestampedPasswordHash == tPasswordHash then
                return true
            end
            return false
        end
    else
        return false
    end
end

local function isValidAddress(address)
    local success, name, domain_name = translateFromAddress(address)
    return success
end

local function receiveRequest()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if side == peripheral.getName(modem) and channel == serverChannel and replyChannel == serverChannel then
            if type(message) == "table" then
                if type(message.type) == "string" then
                    if type(message.clientAddress) == "string" then
                        return message.type, message.clientAddress, message.data
                    end
                end
            end
        end
    end
end

local function sendResponse(response, clientAddress)
    if type(response) ~= "table" then
        error("Response must be a table")
    end
    if type(clientAddress) ~= "string" then
        error("Client address must be a string")
    end
    local packet = response
    packet.clientAddress = clientAddress
    modem.transmit(serverChannel,serverChannel,packet)
end

local function getMailIndex(address)
    if type(address) ~= "string" then
        error("Client address must be a string.")
    end
    local success, name, domain_name = translateFromAddress(address)
    if success then
        if fs.exists(domain_name.."/"..name..".mail") then
            local file = fs.open(domain_name.."/"..name..".mail","r")
            local file_data = file.readAll()
            file.close()
            local index = textutils.unserialiseJSON(file_data)
            return true, index
        else
            return false, {}
        end
    else
        return false, {}
    end
end

local function saveEmail(address, email)
    if type(address) ~= "string" then
        error("Client address must be a string.")
    end
    local success, name, domain_name = translateFromAddress(address)
    if success then
        local index = {}
        if fs.exists(domain_name.."/"..name..".mail") then
            local file = fs.open(domain_name.."/"..name..".mail","r")
            local file_data = file.readAll()
            file.close()
            index = textutils.unserialiseJSON(file_data)
        end
        table.insert(index,email)
        local file = fs.open(domain_name.."/"..name..".mail","w")
        local json_index = textutils.serialiseJSON(index)
        file.write(json_index)
        file.close()
        return true
    else
        return false
    end
end

return {
    translateFromAddress = translateFromAddress,
    translateToAddress = translateToAddress,
    registerDomain = registerDomain,
    registerName = registerName,
    getDomains = getDomains,
    isValidAddress = isValidAddress,
    authenticate = authenticate,
    isValidName = isValidName,
    receiveRequest = receiveRequest,
    getMailIndex = getMailIndex,
    saveEmail = saveEmail,
    sendResponse = sendResponse,
}
local client = require("clientAPI")

local address, password, mode, arg1, arg2, arg3 = ...

if not address then
    error("CMail address is required.")
elseif not password then
    error("CMail account password is required.")
elseif not mode then
    error("Mode is required to be specified.")
end

local success = client.setAddress(address,password)

if not success then
    error("Invalid CMail or password.")
end

if mode == "inbox" then
    local inbox = client.requestMail()
    if #inbox > 0 then
        print("You have",#inbox,"cmail(s)")
        local startIndex = #inbox-3
        if arg1 then
            startIndex = tonumber(arg1)
        end
        local endIndex = startIndex + 3
        for index, cmail in pairs(inbox) do
            if index >= startIndex and index <= endIndex then
                print(" Index:",index)
                if tonumber(cmail.time.min) < 10 then
                    cmail.time.min = "0"..cmail.time.min
                end
                print("From:",cmail.senderAddress,cmail.time.month.."/"..cmail.time.day.."/"..cmail.time.year,cmail.time.hour..":"..cmail.time.min)
                print("Title:",cmail.title)
                print("Message:",cmail.message)
            end
        end
    else
        print("No mail found, check again later.")
    end
elseif mode == "send" then
    if not arg1 then
        error("Target address not specified.")
    elseif not arg2 then
        error("Body message not specified.")
    end
    arg3 = arg3 or ""
    success = client.sendEmail(arg2,arg1,arg3)
    if success then
        print("Successfully sent CMail to "..arg1)
        print("Title:",arg3)
        print("Message:",arg2)
    end
else
    error("Invalid mode: "..mode)
end
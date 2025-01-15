local client = require("clientAPI")

if os.getComputerID() ~= 23 then
    local success = client.setAddress("nullharp@cmail.co","test")
    if not success then
        error("Invalid address.")
    end
    local message = read()
    client.sendEmail(message,"test@testing.co","Bobby's Love")
else
    local success = client.setAddress("test@testing.co","test")
    if not success then
        error("Invalid address.")
    end
    local index = client.requestMail()
    for i, cmail in pairs(index) do
        print("From:",cmail.senderAddress,"At:",cmail.time.month,"/",cmail.time.day," | ",cmail.time.hour,":",cmail.time.min)
        print(cmail.message)
    end
end

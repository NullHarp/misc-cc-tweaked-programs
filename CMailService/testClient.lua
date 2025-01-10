local client = require("clientAPI")

if os.getComputerID() ~= 23 then
    local success = client.setAddress("nullharp@cmail.co")
    if not success then
        error("Invalid address.")
    end
    client.sendEmail("Hi this is bob","test@testing.co","Bobby's Love")
else
    local success = client.setAddress("test@testing.co")
    if not success then
        error("Invalid address.")
    end
    local index = client.requestMail()
    for i, cmail in pairs(index) do
        print("From:",cmail.senderAddress,"At:",cmail.time.month,"/",cmail.time.day," | ",cmail.time.hour,":",cmail.time.min)
        print(cmail.message)
    end
end

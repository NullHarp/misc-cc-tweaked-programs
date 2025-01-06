local modems = table.pack(peripheral.find("modem"))
local new_modems = {}
for i,v in pairs(modems) do
    if i == "n" then
        new_modems.n = modems.n
    elseif  v.isWireless() then
        table.insert(new_modems,v)
    end
end
modems = new_modems
for i = 1, 512 do
    modems[i].closeAll()
    for channel = 0, 127 do
        modems[i].open(channel+(i-1)*128)
    end
end

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    print("Side:",side,"Channel:",channel,"RChannel:",replyChannel,"Dist:",distance)
    if type(message) ~= "table" then
        print("Message:",message)
    elseif type(message) == "table" then
        print("Message:",textutils.serialiseJSON(message))
    end
    sleep(0)
end
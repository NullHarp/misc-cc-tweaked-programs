local modem = peripheral.wrap("top")

while true do
    local pos = {}
    pos.x,pos.y,pos.z = gps.locate()
    modem.transmit(15,43,textutils.serialiseJSON(pos))
end
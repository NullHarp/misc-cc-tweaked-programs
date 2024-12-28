local mod = require("http_module")
local chatBox = peripheral.find("chatBox")

while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    local resp = mod.post("/zone/1",message)
    chatBox.sendMessage(resp.readAll(),"Echo","<>")
end

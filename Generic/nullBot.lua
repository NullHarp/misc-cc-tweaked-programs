local chat = peripheral.find("chatBox")

while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    message = string.lower(message)
    if string.find(message,"null",1,true) then
        local responseDelay = math.random(1,4)
        local responseSelection = math.random(5)
        local response = ""
        if responseSelection == 1 then
            message = "nah, id win"
        elseif responseSelection == 2 then
            message = "win id nah"
        elseif responseSelection == 3 then
            message = "nah id win"
        elseif responseSelection == 4 then
            message = "id win, nah"
        else
            message = "nah, id KILL. CONSUME. MULTIPLY. CONQUER."
        end
        sleep(responseDelay)
        chat.sendMessage(message,"NullHarp","<>")
    end
end
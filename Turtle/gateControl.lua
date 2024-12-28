while true do
    local event, username, message, uuid, isHidden = os.pullEvent("chat")
    if username == "NullHarp" or username == "awesomehome7_dj" or username == "Blista__Compact" then
        if message == "OPEN THE GATES" then
            redstone.setOutput("left",true)
        elseif message == "CLOSE THE GATES" then
            redstone.setOutput("left",false)
        end
    end
    sleep(0)
end
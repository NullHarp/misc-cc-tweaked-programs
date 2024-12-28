local chatBox = peripheral.find("chatBox")


while true do
    sleep(5)
    local request = http.get("https://example.tweaked.cc")
    chatBox.sendMessage(request.readAll(),"GET","<>")
    -- => HTTP is working!
    request.close()
end
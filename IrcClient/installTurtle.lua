local base_url = "https://raw.githubusercontent.com/NullHarp/misc-cc-tweaked-programs/refs/heads/main/"

local function installFile(sub_url,file_name)
    local file = fs.open(file_name,"w")
    local data = http.get(base_url..sub_url)
    file.write(data.readAll())
    file.close()
end

installFile("API/base64.lua","base64.lua")
installFile("API/RLE.lua","RLE.lua")

installFile("Turtle/API/turtUtil.lua","turtUtil.lua")
installFile("Turtle/generatePos.lua","generatePos.lua")

installFile("IrcClient/map.json","map.json")

installFile("IrcClient/IRC_backend.lua","IRC_backend.lua")
installFile("IrcClient/turtleIRC.lua","turtleIRC.lua")
installFile("IrcClient/compressor.lua","compressor.lua")

installFile("IrcClient/turtlePlugins/chat.lua","plugins/chat.lua")
installFile("IrcClient/turtlePlugins/scanner.lua","plugins/scanner.lua")
installFile("IrcClient/turtlePlugins/extendedFunctionality.lua","plugins/extendedFunctionality.lua")
installFile("IrcClient/turtlePlugins/execution.lua","plugins/execution.lua")
installFile("IrcClient/turtlePlugins/uninstall.lua","plugins/uninstall.lua")


local file = fs.open("startup.lua","w")
file.write("shell.run('turtleIRC.lua')")

--os.reboot()
while not fs.exists("/disk/startup/main") do
    sleep(0)
end
fs.move("/disk/startup/main","/disk/st.lua")

local handle = http.get("https://raw.githubusercontent.com/NullHarp/VoidOS/refs/heads/master/install.lua")
local file_data = handle.readAll()
local file = fs.open("/disk/startup/main",'w')
file.write(file_data)
file.close()
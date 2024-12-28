print("Confirm installation of the Taskie")
local response = read()
response = string.lower(response)
if response == "yes" then
    print("Continuing with the installation process")
else
    print("Canceling install.")
    return
end

print("Copying util.lua")
fs.copy("/disk/util.lua","/util.lua")
print("Copying turtUtil.lua")
fs.copy("/disk/turtUtil.lua","/turtUtil.lua")
print("Copying guideRail.lua")
fs.copy("/disk/guideRail.lua","/guideRail.lua")
print("Copying 3dPrinter.lua")
fs.copy("/disk/3dPrinter.lua","/3dPrinter.lua")
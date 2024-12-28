local util = require("util")

local version = "V0.1.3"

local pwr, target = ...
-- (Rapid Automated Inteligent-Lifeform Destroyer)
util.title("R.A.I.D",version)
if type(target) == "nil" then
    print("Target: N/A")
    print("Launch Power"..pwr)
    shell.run("bg","aimbot")
    shell.run("bg","follow",pwr)
else
    print("Target: "..target)
    print("Launch Power"..pwr)
    shell.run("bg","aimbot",target)
    shell.run("bg","follow",pwr,target)
end
while true do
    sleep(0)
end


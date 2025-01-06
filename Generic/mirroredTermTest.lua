local mirror = require("mirroredTerm")
local monitor = peripheral.wrap("top")

mirror.setSourceTerm(term.native())
mirror.mirrorTerm(monitor)


term.redirect(mirror)
term.clear()
term.setCursorPos(1,1)

shell.run("shell")
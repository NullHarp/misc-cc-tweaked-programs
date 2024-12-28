local win = window.create(term.current(),0,0,10,5,true)
win.setBackgroundColor(colors.white)
win.clear()
win.redraw()

while true do
    local event, button, x, y = os.pullEvent("mouse_drag")
    local cX,cY = win.getPosition()
    local offsetX = cX - x
    local offsetY = cY - y
    term.clear()
    term.setBackgroundColor(colors.black)
    win.reposition(-offsetX+cX,-offsetY+cY)
    win.redraw()
    sleep(0)
end
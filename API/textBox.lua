local button = require("buttonAPI")

local textBoxes = {}

local conversionLookup = {
    [keys.one] = "\33",
    [keys.two] = "\64",
    [keys.three] = "\35",
    [keys.four] = "\36",
    [keys.five] = "\37",
    [keys.six] = "\94",
    [keys.seven] = "\38",
    [keys.eight] = "\42",
    [keys.nine] = "\40",
    [keys.zero] = "\41"
}

local Box = {}

function Box.read(self)
    local event, key, is_held
    if self.isSelected then
        local isUppercase = false
        while key ~= keys.enter do
            event, key, is_held = os.pullEvent("key")
            if key == keys.enter then
                self.isSelected = false
            elseif key == keys.backspace then
                self.text = string.sub(self.text,1,#self.text-1)
            elseif key == keys.capsLock then
                isUppercase = not isUppercase
            else
                local success, char
                if conversionLookup[key] and isUppercase then
                    success = true
                    char = conversionLookup[key]
                else
                    success, char = pcall(string.char,key)
                end
                if success then
                    if #self.text < self.width*self.height then
                        if isUppercase then
                            self.text = self.text..char
                        else
                            self.text = self.text..string.lower(char)
                        end
                    end
                end
            end
            self:draw()
        end
    end
end

function Box.getInput(boxes)
    while true do
        local event, mB, x, y = os.pullEvent("mouse_click")
        local selectedButton = button.processButtons(x,y,"textBoxes")
        if selectedButton ~= "" then
            for i = 1, #boxes do
                if selectedButton == boxes[i].id then
                    boxes[i].isSelected = true
                    return
                end
            end
        end
    end
end

function Box.draw(self)
    paintutils.drawFilledBox(self.startX,self.startY,self.startX+self.width-1,self.startY+self.height-1,self.bgColor)
    local old_term = term.current()
    self.win.setTextColor(self.textColor)
    self.win.setBackgroundColor(self.bgColor)
    self.win.setCursorPos(1,1)
    self.win.clear()
    if self.height == 1 then
        self.win.setCursorPos(1,1)
        self.win.write(self.text)
    else
        if #self.text > self.width then
            for i = 1, math.ceil(#self.text / self.width) do
                local posX, posY = self.win.getCursorPos()
                self.win.setCursorPos(1,posY)
                if i == 1 then
                    self.win.write(string.sub(self.text,1,i*(self.width-1)))
                else
                    self.win.write(string.sub(self.text,(i-1)*(self.width-1)-1,i*(self.width-2)))
                end
                if i ~= #self.text / self.width then
                    self.win.setCursorPos(1,posY+1)
                end
            end
        else
            self.win.setCursorPos(1,1)
            self.win.write(self.text)
        end
        --term.redirect(self.win)
        --print(self.text)
        --term.redirect(old_term)
    end
    self.win.redraw()
end

local function createTextBox(startX,startY,width,height,id)
    button.newButton(term.native(),"textBoxes",startX,startY,"",id,colors.lightGray,colors.lightGray,colors.gray,true,width,height)
    local win = window.create(term.native(),startX,startY,width,height)
    local box = {
        win = win,
        text = "",
        startX = startX,
        startY = startY,
        width = width,
        height = height,
        textColor = colors.white,
        bgColor = colors.lightGray,
        draw = Box.draw,
        read = Box.read,
        isSelected = false,
        id = id
    }
    box:draw()
    return box
end

--[[Example
local box = createTextBox(1,1,20,10,"bob")
local box2 = createTextBox(1,11,20,10,"bob")

Box.getInput({box,box2})
box:read()
--]]

return {createTextBox = createTextBox, getInput = Box.getInput}


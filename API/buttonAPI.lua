---Contains all the created button objects
local buttons = {}

---Creates a new button using the specified paramaters
---@param terminal table What terminal should the button be parented to (Ex: term.native())
---@param startX integer Where should the button start on the x axis
---@param startY integer Where should the button start on the y axis
---@param label string The label is what is shown on the button
---@param id string The id will be used to identify which button was pressed
---@param bgColor? integer What should the button be colored
---@param textColor? integer What should the color of the label be
---@param bgColorPressed? integer What should the button be colored when its pressed / toggled
---@param isToggle? boolean Should the button act like a lever, or like a button
---@param width? integer How wide should the button be
---@param height? integer How tall should the button be
local function newButton(terminal,startX,startY,label,id,bgColor,textColor,bgColorPressed,isToggle,width,height)
    width = width or #label
    height = height or 0
    bgColor = bgColor or colors.white
    bgColorPressed = bgColorPressed or bgColor
    textColor = textColor or colors.black
    isToggle = isToggle or false
    local data = {
        terminal = terminal,
        label = label,
        id = id,
        minX = startX,
        minY = startY,
        maxX = startX+width-1,
        maxY = startY+height,
        bgColor = bgColor,
        bgColorPressed = bgColorPressed,
        textColor = textColor,
        isToggle = isToggle,
        toggled = false,
    }
    table.insert(buttons,data)
end

---Draws all the created button objects with an optional specifer for a button id to "press" that button
---@param pressed_button_id? string Id that was provided on button creation, this is the button that will be pressed (or toggled depending on params)
local function drawButtons(pressed_button_id)
    local old_term = term.native()
    pressed_button_id = pressed_button_id or ""
    for i,button in pairs(buttons) do
        local terminal = button.terminal

        if button.id == pressed_button_id or button.toggled then
            terminal.setBackgroundColor(button.bgColorPressed)
            term.redirect(terminal)
            paintutils.drawFilledBox(button.minX,button.minY,button.maxX,button.maxY,button.bgColorPressed)
            term.redirect(old_term)
        else
            terminal.setBackgroundColor(button.bgColor)
            term.redirect(terminal)
            paintutils.drawFilledBox(button.minX,button.minY,button.maxX,button.maxY,button.bgColor)
            term.redirect(old_term)
        end
        terminal.setTextColor(button.textColor)
        terminal.setCursorPos(math.floor((button.minX+button.maxX)/2-(#button.label/2-1)),math.floor((button.minY+button.maxY)/2))
        terminal.write(button.label)
    end
end

---Processes all the created button objects with an optional terminal object specifier
---@param x integer What x character was clicked
---@param y integer What y character was clicked
---@param terminal? table terminal object like term.native() or a monitor, used as a filter
---@return string buttonId Id that was provided on button creation
---@return table buttonTerminal terminal object like term.native() or a monitor
local function processButtons(x,y,terminal)
    local specificTerminal = not not terminal
    for i,button in pairs(buttons) do
        local isVisible = true
        ---offset representing window -> native terminal coordinate on x axis
        local offsetX = 0
        ---offset representing window -> native terminal coordinate on y axis
        local offsetY = 0
        --Crude check to see if the terminal object is a window
        if type(button.terminal.isVisible) ~= "nil" then
            isVisible = button.terminal.isVisible()
            offsetX, offsetY = button.terminal.getPosition()
            offsetX = offsetX - 1
            offsetY = offsetY - 1
        end
        local old_x = x
        local old_y = y
        y = y - offsetY
        x = x - offsetX
        if isVisible and y >= button.minY and y <= button.maxY and x >= button.minX and x <= button.maxX and (terminal == button.terminal or not specificTerminal) then
            if button.isToggle then
                button.toggled = not button.toggled
            end
            return button.id, button.terminal
        end
        y = old_y
        x = old_x
    end
end

---Gets a button using the provided button id
---@param button_id string Id that was provided on button creation
---@return table buttonData Button data based off the paramaters given to newButton
local function getButton(button_id)
    for i,button in pairs(buttons) do
        if button.id == button_id then
            return button
        end
    end
end

---Deletes a button using the provided button id
---@param button_id string Id that was provided on button creation
---@return boolean success Did we successfully delete the button
local function deleteButton(button_id)
    for i, button in pairs(buttons) do
        if button.id == button_id then
            table.remove(buttons,i)
            return true
        end
    end
    return false
end

return {newButton = newButton, drawButtons = drawButtons, processButtons = processButtons, getButton = getButton, deleteButton = deleteButton}
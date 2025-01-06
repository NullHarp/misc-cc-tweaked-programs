local completion = require "cc.shell.completion"

local files = fs.list("/")
for i = #files, 1, -1 do
    if fs.isDir(files[i]) then
        table.remove(files,i)
    elseif string.sub(files[i], #files[i]-3, #files[i]) == ".vmc" then
        files[i] = string.sub(files[i], 1, #files[i]-4)
    else
        table.remove(files,i)
    end
end

local complete = completion.build(
    {completion.choice, files }, completion.file
)
shell.setCompletionFunction("virtMonitor.lua", complete)
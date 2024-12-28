local function post(path,message)
    local headers = {["Content-Type"] = "application/json"}
    local msg = textutils.serialiseJSON({text = message})
    local resp = http.post("http://my-flask-app-container:5000"..path, msg, headers)
    return resp
end

return {post = post}
abplib.nui = {}

abplib.nui.on = function(endpoint, fn)
    RegisterNuiCallback(endpoint, function(data, cb)
        local result = fn(data)
        if result ~= nil then
            return cb(result)
        end

        return cb(false)
    end)
end

abplib.nui.emit = function(action, data, timeout)
    if timeout then Wait(timeout) end
    SendNuiMessage(json.encode({
        action = action,
        data = data or {}
    }))
end


return abplib.nui
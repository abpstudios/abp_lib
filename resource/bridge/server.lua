local bridge = abplib.bridge
---@type table
local serverCallbacks = bridge.callbacks and bridge.callbacks() or {}

for _, cb in pairs(serverCallbacks) do
    print('Server callbacks registered', cb.eventName)
    abplib.callback.register(cb.eventName, function(source, ...)
        return cb.fallback(source, abplib.bridge, ...)
    end)
end
---@diagnostic disable: duplicate-set-field
abplib.player = {}

abplib.player.getRole = function()
    return abplib.callback.await('abplib.player.getPlayerGroup', 100)
end

abplib.player.hasPermission = function(permission)
    return abplib.callback.await('abplib.player.hasPermission', false, permission)
end

abplib.player.getServerPermissions = function()
    local file = abplib.requireFile('config/permissions')
    return file
end

return abplib.player
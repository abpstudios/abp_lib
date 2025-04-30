---@diagnostic disable: duplicate-set-field
abplib.player = {}

abplib.player.getPlayer = function(playerId)
    return exports.abp_lib:getPlayer(playerId)
end

abplib.player.getRole = function(playerId)
    return exports.abp_lib:getPlayer(playerId).role.id
end

---Check if player has permission
---@param playerId number
---@param permission integer
---@return boolean
abplib.player.hasPermission = function(playerId, permission)
    return exports.abp_lib:getPlayer(playerId).hasPermission(permission)
end
abplib.player.setRole = function(playerId, role)
    return exports.abp_lib:getPlayer(playerId).setRole(role)
end

abplib.player.getIdentifier = function(playerId, idType)
    local identifier = GetPlayerIdentifierByType(playerId, idType)
    
    if identifier then
        local result = identifier:match("^" .. idType .. ":(.+)$")
        return result or false
    end

    return false
end

return abplib.player
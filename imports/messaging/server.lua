---getAdmins
---@param all any
---@return table
local function getStaff(role)
    local players = abplib.bridge.getPlayers()
    local admins = {}

    for _, player in ipairs(players) do
        local pRole = abplib.player.getRole(player.source)
        if pRole ~= (role or 'default') then
            table.insert(admins, player)
        end
    end

    return admins
end

---getPlayersMemberOf
---@param category 'job'|'gang'
---@param factionName string
---@return table
local function getPlayersMemberOf(category, factionName)
    local bPlayers = abplib.bridge.getPlayers()
    local memberPlayers = {}

    for _, bPlayer in pairs(bPlayers) do
        if bPlayer and category == 'job' then
            local playerId = bPlayer.source
            local jobName = bPlayer.job.name

            if jobName == factionName then
                table.insert(memberPlayers, playerId)
            end
        end
    end

    return memberPlayers
end

abplib.messaging = {}

abplib.messaging.triggerCallbackToStaff = function(role, callback)
    local admins = getStaff(role)
    for _, admin in ipairs(admins) do
        callback(admin)
    end
end

abplib.messaging.triggerCallbackToGang = function(callback, faction)
    local players = getPlayersMemberOf('gang', faction)
    for _, player in ipairs(players) do
        callback(player)
    end
end

abplib.messaging.triggerCallbackToFaction = function(callback, faction)
    local players = getPlayersMemberOf('job', faction)
    for _, player in ipairs(players) do
        callback(player)
    end
end

abplib.messaging.triggerCallbackToPlayer = function(callback, playerId)
    local player = abplib.GetPlayer(playerId)
    if player then
        callback(player)
    end
end

abplib.messaging.triggerCallbackToAll = function(callback)
    local players = abplib.GetPlayers()
    for _, player in ipairs(players) do
        callback(player)
    end
end

abplib.messaging.triggerNotificationToStaff = function(message)
    abplib.messaging.triggerCallbackToStaff(function(player)
        abplib.messaging.sendNotification(player.source, message)
    end)
end

abplib.messaging.sendNotification = function(playerId, message)
    TriggerClientEvent('nex:Core:showNotification', playerId, message)
end

return abplib.messaging
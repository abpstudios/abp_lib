abplib.callback.register('friends:fetch', function(playerId)
    local player = abplib.bridge.getPlayer(playerId)
    local friendsList = abplib.friends.get(player.citizenId)

    for friendCitizenId, _ in pairs(friendsList) do
        local bPlayer = abplib.bridge.getPlayerByCitizenId(friendCitizenId)
        friendsList[friendCitizenId].playerId = bPlayer and abplib.bridge.getPlayerServerId(bPlayer) or nil
    end

    return friendsList
end)

abplib.callback.register('friends:add', function(playerId, targetPlayerServerId)
    local bPlayer = abplib.bridge.getPlayer(playerId)
    local bTargetPlayer = abplib.bridge.getPlayer(targetPlayerServerId)

    if not bPlayer or not bTargetPlayer then
        return false
    end

    local playerCitizenId = abplib.bridge.getPlayerCitizenId(bTargetPlayer)

    local targetPlayerCitizenId = abplib.bridge.getPlayerCitizenId(bTargetPlayer)
    local targetPlayerDisplayName = GetPlayerName(targetPlayerServerId)

    if not targetPlayerCitizenId then
        return false
    end

    return abplib.friends.addFriend(playerCitizenId, targetPlayerCitizenId, targetPlayerDisplayName)
end)

abplib.callback.register('friends:remove', function(playerId, targetPlayerServerId)
    local bPlayer = abplib.bridge.getPlayer(playerId)
    local bTargetPlayer = abplib.bridge.getPlayer(targetPlayerServerId)

    if not bPlayer or not bTargetPlayer then
        return false
    end

    local playerCitizenId = abplib.bridge.getPlayerCitizenId(bPlayer)
    local targetPlayerCitizenId = abplib.bridge.getPlayerCitizenId(bTargetPlayer)

    if not targetPlayerCitizenId then
        return false
    end

    return abplib.friends.removeFriend(playerCitizenId, targetPlayerCitizenId)
end)
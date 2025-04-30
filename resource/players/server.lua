abplib.callback.register('abplib:HasPermissions', function(source)
    return abplib.bridge.isAdmin(source)
end)

RegisterNetEvent('playerDropped', function(reason)
    local playerId = source
    local lastCoords = GetEntityCoords(GetPlayerPed(playerId))
    local bPlayer = abplib.bridge.getPlayer(playerId)
    local citizenId = abplib.bridge.getCitizenId(bPlayer)


    TriggerClientEvent('abp:onPlayerDrop', -1, {
        playerId = playerId,
        citizenId = citizenId,
        coords = lastCoords
    }, reason)
end)
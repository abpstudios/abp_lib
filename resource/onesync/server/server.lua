abplib.callback.register('abplib.getPlayersInArea', function(playerId, distance, ignore)
    return abplib.onesync.getPlayersInArea(playerId, distance, ignore)
end)
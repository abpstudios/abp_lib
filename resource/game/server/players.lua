abplib.players = {}

abplib.players.getOnlinePlayers = function()
    return GetNumPlayerIndices()
end

exports('getOnlinePlayers', abplib.players.getOnlinePlayers)
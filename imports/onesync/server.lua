abplib.onesync = {}

---Get nearest player
---@param source number
---@param closest boolean
---@param distance number
---@param ignore number[]
---@return {} | { id: number, ped: number, coords: vector3, dist: number }[]
local function getNearbyPlayers(source, closest, distance, ignore)
    local result = {}
    local count = 0
    local playerPed
    local playerCoords

    if not distance then
        distance = 100
    end

    if type(source) == "number" then
        playerPed = GetPlayerPed(source)

        if not source then
            error("Received invalid first argument (source); should be playerId")
            return result
        end

        playerCoords = GetEntityCoords(playerPed)

        if not playerCoords then
            error("Received nil value (playerCoords); perhaps source is nil at first place?")
            return result
        end
    end

    if type(source) == "vector3" then
        playerCoords = source

        if not playerCoords then
            error("Received nil value (playerCoords); perhaps source is nil at first place?")
            return result
        end
    end

    for _, playerServerId in pairs(GetPlayers()) do
        if not ignore or not ignore[tonumber(playerServerId)] then
            local entity = GetPlayerPed(playerServerId)
            local coords = GetEntityCoords(entity)

            if not closest then
                local dist = #(playerCoords - coords)
                if dist <= distance then
                    count = count + 1
                    result[count] = { id = playerServerId, ped = NetworkGetNetworkIdFromEntity(entity), coords = coords, dist = dist }
                end
            else
                if playerServerId ~= source then
                    local dist = #(playerCoords - coords)
                    if dist <= (result.dist or distance) then
                        result = { id = playerServerId, ped = NetworkGetNetworkIdFromEntity(entity), coords = coords, dist = dist }
                    end
                end
            end
        end
    end

    return result
end

function abplib.onesync.getPlayersInArea(source, maxDistance, ignore)
    return getNearbyPlayers(source, false, maxDistance, ignore)
end


function abplib.onesync.getClosestPlayer(source, maxDistance, ignore)
    return getNearbyPlayers(source, true, maxDistance, ignore)
end

abplib.onesync.getPlayerWithLowestPing = function(players)
    local players = players or GetPlayers()
    local lowestPingPlayer = nil
    local lowestPing = math.huge -- Inicializamos con un valor muy alto

    for _, playerId in ipairs(players) do
        local ping = GetPlayerPing(playerId)
        if ping < lowestPing then
            lowestPing = ping
            lowestPingPlayer = playerId
        end
    end

    return lowestPingPlayer, lowestPing -- Devuelve el jugador con menor ping y su ping
end


return abplib.onesync
abplib.logger = {}

local ConfigServer = abplib.requireFile('@abp_lib/configServer')


RegisterNetEvent(abplib.name .. ':Logging:CreateLog', function(category, message, personalLog, playerId)
    self.GetComponent().LogToDiscord(playerId or source, category, message, personalLog)
end)

RegisterNetEvent(abplib.name .. ':Logging:CreateLogSimple', function(category, message, playerId)
    self.GetComponent().LogToDiscordSimple(playerId or source, category, message)
end)

RegisterNetEvent(abplib.name .. ':Logging:CreateStaffLog', function(message, playerId)
    local xPlayer = NEX.GetPlayer(playerId or source)
    self.GetComponent().LogToStaffChat(xPlayer.getName() .. " ejecuta una acción: " .. message)
end)


local loggerMessage = {}
loggerMessage.__index = loggerMessage

function loggerMessage:new(playerId)
    local self = setmetatable({
        playerId = playerId or 0,
        citizenId = 0,
        webhook = false,
        isConsole = true,
    }, loggerMessage)
    return self
end

function loggerMessage:parseInitiator()
    local initiator = {
        source = self.playerId,
        name = "CONSOLA",
        citizenId = "CONSOLA",
        identifier = false
    }

    if self.playerId == 0 then
        return initiator
    end

    local bPlayer = abplib.bridge.getPlayer(self.playerId)
    local citizenId = abplib.bridge.getCitizenId(bPlayer)
    local webhook = abplib.bridge.getMeta(bPlayer, 'webhook')
    if bPlayer then
        initiator = {
            source = self.playerId,
            name = GetPlayerName(self.playerId),
            identifier = bPlayer.identifier,
            citizenId = citizenId,
        }
        self.webhook = webhook and webhook or false
        self.isConsole = false
    end

    return initiator
end

abplib.logger.register = function(id, webhook)
    ConfigServer.NotificationsWebhooks[id] = webhook
end

abplib.logger.list = function()
    return ConfigServer.NotificationsWebhooks
end 

--- Log a message to the discord
---@param playerId number
---@param category string
---@param message string
---@param personal? boolean
---@return boolean
abplib.logger.discord = function(playerId, category, message, personal)
    local logMessage = loggerMessage:new(playerId)
    local Player = logMessage:parseInitiator()
    local urlToUse = ConfigServer.NotificationsWebhooks[category] or category

    if not urlToUse or urlToUse == '' then return false end

    local data = {
        content = [[**[Arkan]** >> *(]] .. (abplib.debug and 'DEV' or 'LIVE') .. [[)* : [ ]] .. Player.name .. [[ (]] .. Player.citizenId .. [[) ] >> ]] .. message,
        username = "Arkan Logger",
        avatar_url = "https://ozzypig.com/wp-content/uploads/2018/12/BanHammer-Icon-Full.png"
    }

    PerformHttpRequest(urlToUse, function(err, text, headers)
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })

    return true
end

--- Register a log in the database
--- @param playerId number
--- @param category string
--- @param message string
--- @return boolean
abplib.logger.database = function(playerId, category, message)
    local logMessage = loggerMessage:new(playerId)
    local Player = logMessage:parseInitiator()

    local id = MySQL.insert.await('INSERT INTO `nex_logger` (identifier, action, description) VALUES (?, ?, ?)', {
        Player.identifier, category, message
    })

    if not id then return false end
    return true
end

--- Get all logs from a player
--- @param targetIdentifier string
--- @param category string
--- @return table
abplib.logger.getLogs = function(targetIdentifier, category)
    local query = 'SELECT * FROM `nex_logger` WHERE identifier = ?'
    local params = { targetIdentifier }

    if category then
        query = query .. ' AND action = ?'
        table.insert(params, category)
    end

    local result = MySQL.query.await(query, params)
    return result
end

abplib.logger.discordAdvanced = function(playerId, category, message, isPersonalLog)
    local logMessage = loggerMessage:new(playerId)
    local Player = logMessage:parseInitiator()
    local urlToUse = ConfigServer.NotificationsWebhooks[category] or category

    if isPersonalLog then urlToUse = logMessage.webhook end
    
    if not urlToUse or urlToUse == '' then return false end

    local embedTitle = "**[ARKAN]** " .. (abplib.debug and '(DEV)' or '(LIVE)')
    local isPlayer = not logMessage.isConsole
    local playerPing = isPlayer and GetPlayerPing(logMessage.playerId) or 0
    local playerVerse = isPlayer and GetPlayerRoutingBucket(logMessage.playerId) or 0

    local description = string.format([[
>< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
%s
]] .. ((isPlayer) and [[
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
**SteamURL:** [Perfil de Jugador](http://steamcommunity.com/profiles/%s)
**Ping:** %s
**Verse:** %s
]] or '') .. [[
>< >< >< >< >< >< >< >< >< >< >< >< >< >< >< >< ><
]], "Acción ejecutada: ", abplib.utils.getSteamId64FromHex(Player.identifier), playerPing, playerVerse)
end

abplib.logger.staffChat = function (message)
    
end

return abplib.logger
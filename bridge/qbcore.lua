return {

    Shared = {
        getMoneyName = function()
            return 'cash'
        end,

        --- VIP Coins
        getCoinName = function()
            return 'coins'
        end,

        getBankName = function ()
            return 'bank'
        end
    },

    Client = {
        onPlayerLoad = function(_, cb)
            if not cb then return end
            RegisterNetEvent('QBCore:Client:PlayerLoaded', function() 
                return cb()
            end)
        end,

        onJobChange = function(_, cb)
            if not cb then return end
            RegisterNetEvent('QBCore:Client:OnJobUpdate', function(...)
                return cb(...)
            end)
        end,

        isAdmin = function()
            return abplib.callback.await('abp::Bridge:IsAdmin', false)
        end,

        getPlayerData = function(f)
            local pData = f.Functions.GetPlayerData()

            if not pData then return false end

            local job = pData.job
            local gang = pData.gang
            local charinfo = pData.charinfo
            local citizenId = pData.citizenid
            local metadata = pData.metadata

            return {
                job = job,
                charinfo = charinfo,
                gang = gang,
                citizenId = citizenId,
                metadata = metadata
            }
        end,

        getMeta = function(f, key)
            local playerData = f.Functions.GetPlayerData()
            return playerData.metadata[key]
        end,

        getMetadata = function(f)
            local playerData = f.Functions.GetPlayerData()
            return playerData.metadata
        end,

        notify = function(f, message, status)
            f.Functions.Notify(message, status or 'success')
        end,
    },

    Server = {

        onPlayerLoad = function(cb)
            RegisterNetEvent('QBCore:Server:PlayerLoaded', cb)
        end,

        callbacks = function()
            return {
                {
                    eventName = "abp::Bridge:IsAdmin",
                    fallback = function(source, f, ...)
                        return f.isAdmin(source)
                    end
                }
            }
        end,

        isAdmin = function(f, playerId)
            return f.Functions.HasPermission(playerId, 'admin')
        end,

        getPermissions = function(f, playerId)
            return f.Functions.GetPermission(playerId)
        end,

        addPermission = function(f, playerId, permission)
            return f.Functions.AddPermission(playerId, permission)
        end,

        notify = function(f, playerId, message, status)
            TriggerClientEvent('QBCore:Notify', playerId, message, status or 'success')
        end,

        getPlayer = function(f, playerId)
            return f.Functions.GetPlayer(playerId)
        end,

        getPlayerByCitizenId = function(f, citizenId)
            return f.Functions.GetPlayerByCitizenId(citizenId)
        end,

        save = function(f, playerId)
            return f.Player.Save(playerId)
        end,

        getPlayers = function(f, returnIndex)

            if returnIndex then
                return f.Functions.GetPlayers()
            end

            local fPlayers = f.Functions.GetQBPlayers()
            
            local bPlayers = {}

            for _, fPlayer in pairs(fPlayers) do
                if not fPlayer then
                    goto continue
                end

                local bPlayer = {
                    citizenId = fPlayer.PlayerData.citizenid,
                    source = fPlayer.PlayerData.source,
                    charinfo = fPlayer.PlayerData.charinfo,
                    name = fPlayer.PlayerData.name,
                    metadata = fPlayer.PlayerData.metadata,
                    job = fPlayer.PlayerData.job,
                }
                table.insert(bPlayers, bPlayer)

                ::continue::
            end

            return bPlayers
        end,

        getOfflinePlayerByCitizenId = function(f, citizenId)
            return f.Functions.GetOfflinePlayerByCitizenId(citizenId)
        end,

        ----- [[
        ---
        --- PLAYER DATA
        ---
        ---]]

        getCitizenId = function(_, bPlayer)
            return bPlayer.PlayerData.citizenid
        end,

        setPlayerData = function(_, bPlayer, key, value)
            return bPlayer.Functions.SetPlayerData(key, value)
        end,

        getCharinfo = function(_, bPlayer)
            return bPlayer.PlayerData.charinfo
        end,

        getPlayerName = function(_, bPlayer)
            return bPlayer.PlayerData.name
        end,

        getFirstname = function(_, bPlayer)
            return bPlayer.PlayerData.charinfo.firstname
        end,

        getLastname = function(_, bPlayer)
            return bPlayer.PlayerData.charinfo.lastname
        end,

        getGender = function(_, bPlayer)
            return bPlayer.PlayerData.charinfo.gender
        end,

        getIdentifier = function(_, bPlayer)
            return bPlayer.PlayerData.citizenid
        end,

        getPlayerLicense = function(_, bPlayer)
            return bPlayer.PlayerData.license
        end,

        getPlayerServerId = function(_, bPlayer)
            return bPlayer.PlayerData.source
        end,

        getMoney = function(_, bPlayer, account)
            return bPlayer.Functions.GetMoney(account)
        end,
        addMoney = function(_, bPlayer, account, money, reason)
            return bPlayer.Functions.AddMoney(account, money, reason)
        end,

        setMoney = function(_, bPlayer, account, money, reason)
            return bPlayer.Functions.SetMoney(account, money, reason)
        end,

        removeMoney = function(_, bPlayer, account, amount, reason)
            return bPlayer.Functions.RemoveMoney(account, amount, reason)
        end,
        getMeta = function(_, bPlayer, metaId)
            return bPlayer.PlayerData.metadata[metaId] or false
        end,

        setMeta = function(_, bPlayer, metaId, value)
            return bPlayer.Functions.SetMetaData(metaId, value)
        end,

        getPlayerJob = function(_, bPlayer)
            local pData = bPlayer.PlayerData
            return {
                name        = pData.job.name,
                label       = pData.job.label,
                grade_label = pData.job.grade.name,
                grade_level = pData.job.grade.level,
                salary      = pData.job.payment,
                onduty      = pData.job.onduty
            }
        end,

        getPlayerGang = function(_, bPlayer)
            return bPlayer.PlayerData.gang
        end,

        getJobSalary = function(_, bPlayer)
            return bPlayer.PlayerData.job.grade.payment
        end,

        getJobGrade = function(_, bPlayer)
            return bPlayer.PlayerData.job.grade
        end,

        getJobLabel = function(_, bPlayer)
            return bPlayer.PlayerData.job.label
        end,

        getJobGradeName = function(_, bPlayer)
            return bPlayer.PlayerData.job.grade.name
        end,

        getJobGradeLevel = function(_, bPlayer)
            return bPlayer.PlayerData.job.grade.level
        end,

        setJob = function(_, bPlayer, jobName, jobLevel)
            return bPlayer.Functions.SetJob(jobName, tostring(jobLevel))
        end,

        toggleDuty = function(_, bPlayer, state)
            bPlayer.Functions.SetJobDuty(state)
            TriggerEvent('QBCore:Server:SetDuty', bPlayer.PlayerData.source, bPlayer.PlayerData.job.onduty)
            TriggerClientEvent('QBCore:Client:SetDuty', bPlayer.PlayerData.source, bPlayer.PlayerData.job.onduty)
        end
    },


}
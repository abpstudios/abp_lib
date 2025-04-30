return {
    Shared = {
        getMoneyName = function()
            return 'money'
        end,

        getCoinName = function()
            return 'coins'
        end,

        getBankName = function ()
            return 'bank'
        end
    },

    Client = {
        getPlayerData = function(f)
            local pData = f.GetPlayerData()
            
            local job = {
                name = pData.job.name,
                grade = pData.job.grade,
                label = pData.job.label,
                isboss = pData.job.grade_name,
                isduty = pData.job.grade_label,
            }

            local charinfo = {
                firstname = pData.firstName,
                lastname = pData.lastName,
                birthdate = pData.dateofbirth,
                gender = pData.sex,
            }
            
            return {
                job = job,
                charinfo = charinfo
            }
        end,

        notify = function(f, message, status)
            print("[ABPLib] Setup notify on abp_lib/bridge/esx.lua :: ", message, status)
        end,
    },

    Server = {
        IsAdmin = function(f, playerId)
            return f.IsAdmin(playerId)
        end,

        getPlayer = function(f, playerId)
            return f.GetPlayerFromId(playerId)
        end,

        getIdentifier = function(_, bPlayer)
            return bPlayer.identifier
        end,

        notify = function(f, playerId, message, status)
            print("[ABPLib] Setup notify on abp_lib/bridge/esx.lua :: ", playerId, message, status)
        end,

    }
}
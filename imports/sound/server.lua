---@diagnostic disable: duplicate-set-field
abplib.sound = {}

---Play a sound
---@param playerId number
---@param soundId string
---@param soundName string
---@param vol number
abplib.sound.playSound = function(playerId, soundId, soundName, vol)
    local url = soundName:match('https://') and soundName or 'https://cfx-nui-abp_assets/audio/' .. soundName
    xSound:PlayUrl(playerId, soundId, url, vol, false)
end

abplib.sound.playSound3D = function(playerId, soundId, soundName, coords, vol)
    local url = soundName:match('https://') and soundName or 'https://cfx-nui-abp_assets/audio/' .. soundName
    xSound:PlayUrlPos(playerId, soundId, url, vol, coords, false)
end

abplib.sound.stopSound = function(soundId)
    if not xSound then return end
    xSound:Destroy(soundId)
end

---Play frontend sound
---@param playerId number
---@param sound string
---@param soundset string
abplib.sound.playGameSound = function(playerId, sound, soundset)
    TriggerClientEvent("abplib:playGameSound", playerId, sound, soundset)
end

return abplib.sound
local xSound = exports.xsound

abplib.sound = {}

---Play frontend sound
---@param sound string
---@param soundset string
abplib.sound.playGameSound = function(sound, soundset)
    PlaySoundFrontend(-1, sound, soundset, true)
end

---Play a sound
---@param soundId string
---@param soundName string
---@param vol number
abplib.sound.playSound = function(soundId, soundName, vol, loop)
    local url = soundName:match('https://') and soundName or 'https://cfx-nui-abp_assets/audio/' .. soundName
    xSound:PlayUrl(soundId, url, vol, loop or false)
end

---Play a 3D sound
---@param soundId string
---@param soundName string
---@param coords vector3
---@param vol number
abplib.sound.playSound3D = function(soundId, soundName, coords, vol)
    local url = soundName:match('https://') and soundName or 'https://cfx-nui-hub_assets/audio/' .. soundName
    xSound:PlayUrlPos(soundId, url, vol, coords, false)
end

---Stop a sound
---@param soundId string
---@param fadeOut number
abplib.sound.stopSound = function(soundId, fadeOut)
    if fadeOut and fadeOut >= 0 then
        xSound:fadeOut(soundId, fadeOut)
    else
        xSound:Destroy(soundId)
    end
end

return abplib.sound
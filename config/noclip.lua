return {
    Enable = false,
    Controls = {
        -- [[Controls: Check the controls list here : https://docs.fivem.net/game-references/controls/]]
        goUp = 85, -- [[Q]]
        goDown = 48, -- [[Z]]
        turnLeft = 34, -- [[A]]
        turnRight = 35, -- [[D]]
        goForward = 32, -- [[W]]
        goBackward = 33, -- [[S]]
        changeSpeed = 21, -- [[L-Shift]]
    },
    Speeds = {
        { label = "Muy Lento", speed = 0 },
        { label = "Normal", speed = 4 },
        { label = "Rápido", speed = 8 },
        { label = "Max Velocidad", speed = 32 },
    },
    AllowedGroups = {
        "admin",
        "god",
    }
}
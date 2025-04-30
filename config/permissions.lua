local Permissions = {

    MENU_ACCESS = 0x01,
    MENU_PLAYERMAN_ACCESS = 0x02,
    MENU_NAC_ACCESS = 0x04,
    MENU_SERVERMAN_ACCESS = 0x08,
    MENU_DEV_ACCESS = 0x10,

    MENU_PLAYERMAN_SETROLES = 0x20,
    CAN_SPECTATE = 0x40,
    CAN_SET_PERMISSIONS = 0x80,
    CAN_NOCLIP = 0x100,
}

local function combineAllPermissions()
    local combined = 0
    for _, value in pairs(Permissions) do
        combined = combined | value
    end
    return combined
end

return {
    Permissions = Permissions,

    Roles = {
        DEFAULT = {
            permissions = 0,
            label = 'Usuario',
            id = 'default',
            priority = 0,
        },
        DEVELOPER = {
            permissions = combineAllPermissions(),

            label = 'Desarrollador',
            id = 'developer',
            priority = 100000,
        },
        ADMIN = {
            permissions = Permissions.MENU_ACCESS |
            Permissions.MENU_DEV_ACCESS |
            Permissions.MENU_SERVERMAN_ACCESS |
            Permissions.MENU_PLAYERMAN_ACCESS |
            Permissions.MENU_NAC_ACCESS |
            Permissions.MENU_PLAYERMAN_SETROLES |
            Permissions.CAN_SPECTATE | 
            Permissions.CAN_SET_PERMISSIONS |
            Permissions.CAN_NOCLIP,

            label = 'Administrador',
            id = 'admin',
            priority = 1000,
        },

        BOSSMOD = {
            permissions = Permissions.MENU_ACCESS |
            Permissions.MENU_SERVERMAN_ACCESS |
            Permissions.MENU_PLAYERMAN_ACCESS |
            Permissions.MENU_PLAYERMAN_SETROLES | 
            Permissions.CAN_SPECTATE |
            Permissions.CAN_SET_PERMISSIONS |
            Permissions.CAN_NOCLIP,

            label = 'Jefe de Moderación',
            id = 'bossmod',
            priority = 800,
        },

        MOD = {
            permissions = Permissions.MENU_ACCESS |
            Permissions.MENU_SERVERMAN_ACCESS |
            Permissions.MENU_PLAYERMAN_ACCESS | 
            Permissions.CAN_SPECTATE | 
            Permissions.CAN_NOCLIP,

            label = 'Moderador',
            id = 'moderator',
            priority = 500,
        },

        SUPPORT = {
            permissions = Permissions.CAN_SPECTATE,
            label = 'Soporte',
            id = 'support',
            priority = 300,
        }
    }
    
}
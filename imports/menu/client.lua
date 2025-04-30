abplib.menu = {}

abplib.menu.registerType = function(menuType, openMenu, closeMenu)
    return exports.abp_lib:menu_registerType(menuType, openMenu, closeMenu)
end

---Open ABP Menu
---@param type string | 'default'
---@param name string
---@param data table<{title: string, align: string, elements: table}>
---@param submit? function
---@param cancel? function
---@param change? function
---@param close? function
---@return table
abplib.menu.open = function(type, name, data, submit, cancel, change, close)
    return exports.abp_lib:menu_open(type, name, data, submit, cancel, change, close)
end

abplib.menu.getOpened = function(type, namespace, name)
    return exports.abp_lib:menu_getOpened(type, namespace, name)
end

abplib.menu.getOpenMenues = function()
    return exports.abp_lib:menu_getOpenedMenus()
end

abplib.menu.closeAll = function()
    return exports.abp_lib:menu_closeAll()
end

return abplib.menu
local GRS = GetResourceState
local Settings = abplib.requireFile('config')

local inventories = Settings.bridge.inventories

local inventory = false

for _, invName in ipairs(inventories) do
    local started = GRS(invName) == 'started'
    if started then
        ---@diagnostic disable-next-line: cast-local-type
        inventory = invName
        break
    end
end

if not inventory then
    error(('Inventory bridge not found for %s'):format(inventory))
end

local inventoryFrame = exports[inventory]
local Bridge = abplib.requireFile(('@abp_lib/bridge/inventory/%s'):format(inventory))

abplib.inventory = {}

--- Not implemented functions
local function createFallback(tableType, key)
    return function()
        error(('%s function ^4%s^1 not implemented'):format(tableType, key))
    end
end

local function mapFunctionsToBridge(source, destination)
    for f, v in pairs(source) do
        destination[f] = function(...)
            return v(inventoryFrame, ...)
        end
    end
end

local function setupMetatableForBridge(bridgeTable, side)
    setmetatable(bridgeTable, {
        __index = function (_, key)
            if bridgeTable[side] and bridgeTable[side][key] then
                return function(...)
                    return bridgeTable[side][key](inventoryFrame, ...)
                end
            end

            return createFallback(side, key)
        end
    })
end


if IsDuplicityVersion() then
    ----- SERVER SIDE
    abplib.refactor.tryCatch:try(function()
        setupMetatableForBridge(Bridge, 'Server')
        mapFunctionsToBridge(Bridge.Server, abplib.inventory)
    end)
    :catch(function(err)
        error(('Error setting up shared bridge: %s'):format('Implement Server On Bridge/Standalone'))
    end):finally(function() end)
else
    ----- CLIENT SIDE
    abplib.refactor.tryCatch:try(function()
        setupMetatableForBridge(Bridge, 'Client')
        mapFunctionsToBridge(Bridge.Client, abplib.inventory)
    end)
    :catch(function(err)
        error(('Error setting up shared bridge: %s'):format('Implement Client On Bridge/Standalone'))
    end):finally(function() end)
end

abplib.inventory.getInventoryName = function ()
    return inventory
end

abplib.refactor.tryCatch:try(function()
    setupMetatableForBridge(Bridge, 'Shared')
    mapFunctionsToBridge(Bridge.Shared, abplib.inventory)
end)
:catch(function(err)
    error(('Error setting up shared bridge: %s'):format('Implement Shared On Bridge/Standalone'))
end):finally(function() end)

setmetatable(abplib.inventory, {
    __index = function (_, key)
        return createFallback('Bridge', key)
    end
})

return abplib.inventory
local GRS = GetResourceState

local framework = GRS('es_extended') == 'started' and 'esx' or 'qbcore'
local Frame = framework == 'esx' and exports["es_extended"]:getSharedObject() or exports['qb-core']:GetCoreObject()


local Standalone = abplib.requireFile('@abp_lib/bridge/standalone')
local Bridge = abplib.requireFile(('@abp_lib/bridge/%s'):format(framework))

abplib.bridge = {}

--- Not implemented functions
local function createFallback(tableType, key)
    return function()
        error(('%s function ^4%s^1 not implemented'):format(tableType, key))
    end
end

local function mapFunctionsToBridge(source, destination)
    for f, v in pairs(source) do
        destination[f] = function(...)
            return v(Frame, ...)
        end
    end
end

local function setupMetatableForBridge(bridgeTable, side)
    setmetatable(bridgeTable, {
        __index = function (_, key)
            if bridgeTable[side] and bridgeTable[side][key] then
                return function(...)
                    return bridgeTable[side][key](Frame, ...)
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
        mapFunctionsToBridge(Bridge.Server, abplib.bridge)
        mapFunctionsToBridge(Standalone.Server, abplib.bridge)
    end)
    :catch(function(err)
        error(('Error setting up shared bridge: %s'):format('Implement Server On Bridge/Standalone'))
    end):finally(function() end)
else
    ----- CLIENT SIDE
    abplib.refactor.tryCatch:try(function()
        setupMetatableForBridge(Bridge, 'Client')
        mapFunctionsToBridge(Bridge.Client, abplib.bridge)
        mapFunctionsToBridge(Standalone.Client, abplib.bridge)
    end)
    :catch(function(err)
        error(('Error setting up shared bridge: %s'):format('Implement Client On Bridge/Standalone'))
    end):finally(function() end)
end

abplib.bridge.getFrameworkName = function ()
    return framework
end

abplib.refactor.tryCatch:try(function()
    setupMetatableForBridge(Bridge, 'Shared')
    mapFunctionsToBridge(Bridge.Shared, abplib.bridge)
    mapFunctionsToBridge(Standalone.Shared, abplib.bridge)
end)
:catch(function(err)
    error(('Error setting up shared bridge: %s'):format('Implement Shared On Bridge/Standalone'))
end):finally(function() end)

setmetatable(abplib.bridge, {
    __index = function (_, key)
        return createFallback('Bridge', key)
    end
})


return abplib.bridge
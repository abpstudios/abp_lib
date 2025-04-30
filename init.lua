if not _VERSION:find('5.4') then
    error('[ABP_LIB] Activa Lua 5.4 en fxmanifest para continuar.', 2)
end

LuaRequire = require
local resourceName = GetCurrentResourceName()
local abp_lib = 'abp_lib'

if resourceName == abp_lib then return end

if abplib and abplib.name == abp_lib then
    return error(("Cannot load abp_lib more than once.\n\tRemove any duplicate entries from '@%s/fxmanifest.lua'"):format(resourceName))
end

if GetResourceState(abp_lib) ~= 'started' then
    return error('^1[ABP_LIB] Se requiere iniciar la libreria antes de usar este recurso.^0', 0)
end

local export = exports[abp_lib]
local status = export.hasLoaded()

if status ~= true then error(status, 2) end

-- Ignore invalid types during msgpack.pack (e.g. userdata)
msgpack.setoption('ignore_invalid', true)

-----------------------------------------------------------------------------------------------
-- Modules
-----------------------------------------------------------------------------------------------

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

---@diagnostic disable-next-line: lowercase-global
function noop() end

local function loadModule(self, module)
    local dir = ('imports/%s'):format(module)
    local chunk = LoadResourceFile(abp_lib, ('%s/%s.lua'):format(dir, context))
    local shared = LoadResourceFile(abp_lib, ('%s/shared.lua'):format(dir))

    if shared then
        chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
    end

    if chunk then
        local fn, err = load(chunk, ('@@abp_lib/imports/%s/%s.lua'):format(module, context))

        if not fn or err then
            return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
        end

        local result = fn()
        self[module] = result or noop
        return self[module]
    end
end

-----------------------------------------------------------------------------------------------
-- API
-----------------------------------------------------------------------------------------------

local function call(self, index, ...)
    local module = rawget(self, index)

    if not module then
        self[index] = noop
        module = loadModule(self, index)

        if not module then
            local function method(...)
                return export[index](nil, ...)
            end

            if not ... then
                self[index] = method
            end

            return method
        end
    end

    return module
end

local abplib = setmetatable({
    name = abp_lib,
    context = context,
    debug = true,
    debugLevel = 'info',
}, {
    __index = call,
    __call = call,
})


-----------------
local cacheEvents = {}

---@generic T
---@param key string
---@param func fun(...: any): T
---@param timeout? number
---@return T
---Caches the result of a function, optionally clearing it after timeout ms.
---@diagnostic disable-next-line: unused-local, lowercase-global
function abpcache(key, func, timeout) end

local cache = setmetatable({ game = GetGameName(), resource = resourceName }, {
    __index = function(self, key)
        cacheEvents[key] = {}

        AddEventHandler(('ox_lib:cache:%s'):format(key), function(value)
            local oldValue = self[key]
            local events = cacheEvents[key]

            for i = 1, #events do
                Citizen.CreateThreadNow(function()
                    events[i](value, oldValue)
                end)
            end

            self[key] = value
        end)

        return rawset(self, key, export.cache(nil, key) or false)[key]
    end,

    __call = function(self, key, func, timeout)
        local value = rawget(self, key)

        if value == nil then
            value = func()

            rawset(self, key, value)

            if timeout then SetTimeout(timeout, function() self[key] = nil end) end
        end

        return value
    end,
})

_ENV.abpcache = cache
_ENV.abplib = abplib

-----------------

if context == 'client' then
    abpcache.playerId = PlayerId()
    abpcache.serverId = GetPlayerServerId(cache.playerId)
else

end

function abplib.hasLoaded() return true end

-- Replace lua print with arkan library
--print = abplib.print

for i = 1, GetNumResourceMetadata(abpcache.resource, 'abp_lib') do
    local name = GetResourceMetadata(abpcache.resource, 'abp_lib', i - 1)

    if not rawget(lib, name) then
        local module = loadModule(lib, name)

        if type(module) == 'function' then pcall(module) end
    end
end
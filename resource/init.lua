LuaRequire = require
local debug_getinfo = debug.getinfo
function noop() end

abplib = setmetatable({
    name = 'abp_lib',
    context = IsDuplicityVersion() and 'server' or 'client',
    debug = true,
    debugLevel = 'info'
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)

        if debug_getinfo(2, 'S').short_src:find('@abp_lib/resource') then
            exports(key, fn)
        end
    end,

    __index = function(self, key)
        local dir = ('imports/%s'):format(key)
        local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, self.context))
        local shared = LoadResourceFile(self.name, ('%s/shared.lua'):format(dir))

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local fn, err = load(chunk, ('@@abp_lib/%s/%s.lua'):format(key, self.context))

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end

            rawset(self, key, fn() or noop)

            return self[key]
        end
    end,
})

abpcache = {
    resource = abplib.name,
    game = GetGameName(),
}

function abplib.hasLoaded() return true end
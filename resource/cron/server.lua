local Jobs = {}
local LastTime = {}


local runAt  = function(h, m, cb)
    table.insert(Jobs, {
        h = h,
        m = m,
        cb = cb
    })

    return true
end

local onTime = function(d, h, m)
    for i = 1, #Jobs, 1 do
        if Jobs[i].h == h and Jobs[i].m == m then
            Jobs[i].cb(d, h, m)
        end
    end
end

---Create cron
---@param h number
---@param m number
---@param cb function
---@return boolean
abplib.createCron = function(h, m, cb)
    return runAt(h, m, cb)
end

CronTick = function()
    local time = abplib.cron.getTime()

    if time.h ~= LastTime.h or time.m ~= LastTime.m then
        onTime(time.d, time.h, time.m)
        LastTime = time
    end

    SetTimeout(60000, function()
        CronTick()
    end)
end

LastTime = abplib.cron.getTime()
CronTick()

print('--> CRON STARTED [' .. os.date('%H:%M', os.time()) .. ']')
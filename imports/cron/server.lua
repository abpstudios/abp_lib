abplib.cron = {}

abplib.cron.getTime = function()
    local timestamp = os.time()
    local d         = os.date('*t', timestamp).wday
    local h         = tonumber(os.date('%H', timestamp))
    local m         = tonumber(os.date('%M', timestamp))

    return { d = d, h = h, m = m }
end


abplib.cron.create = abplib.createCron


return abplib.cron
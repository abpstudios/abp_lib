abplib.streaming = {}

abplib.streaming.loadModel = function(model, time)
    if not IsModelValid(model) or not IsModelInCdimage(model) then
        return false
    end

    if HasModelLoaded(model) then
        return true
    end

    RequestModel(model)

    local timeout = time or 2000

    while not HasModelLoaded(model) do
        if timeout <= 0 then
            return false
        end

        timeout = timeout - 100
        Wait(100)
    end

    return true
end

return abplib.streaming
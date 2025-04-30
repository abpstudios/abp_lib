abplib.date = {}

function abplib.date.getTimestamp()
    return os.time()
end

function abplib.date.isCurrentTimestampGreaterOrEqual(timeStamp)
    return os.time() >= timeStamp
end

function abplib.date.isCurrentTimestampGreaterOrEqualDb(timeStamp)
    local convertedTimeStamp = math.floor(timeStamp / 1000)
    return os.time() >= convertedTimeStamp
end

function abplib.date.dbTimestampToLuaTimestamp(timeStamp)
    return math.floor(timeStamp / 1000)
end

function abplib.date.getDateTime()
    return os.date('%Y-%m-%d %H:%M:%S')
end

function abplib.date.getDate()
    return os.date('%Y-%m-%d')
end

function abplib.date.getTime()
    return os.date('%H:%M:%S')
end

function abplib.date.getHumanDate()
    return os.date('%d/%m/%Y')
end

function abplib.date.getHumanTime()
    return os.date('%H:%M')
end

function abplib.date.getHumanDateTime()
    return os.date('%d/%m/%Y %H:%M')
end

function abplib.date.getHumanDateTimeSeconds()
    return os.date('%d/%m/%Y %H:%M:%S')
end

function abplib.date.getHumanDateTimeMilliseconds()
    return os.date('%d/%m/%Y %H:%M:%S') .. '.' .. os.date('%3N')
end

function abplib.date.isCurrentDateGreaterOrEqual(dateTimeStr)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateTimeStr:match(pattern)
    local targetTime = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
    local currentTime = os.time()

    return currentTime >= targetTime
end

function abplib.date.getSecondsUntilDate(dateTimeStr)
    local pattern = "(%d+)-(%d+)-(%d+)%s(%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateTimeStr:match(pattern)
    local targetTime = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
    local currentTime = os.time()
    local difference = targetTime - currentTime

    return math.max(0, difference)
end

function abplib.date.addHoursToDate(dateTimeStr, hoursToAdd)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateTimeStr:match(pattern)
    local dateTable = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
    local timeInSeconds = os.time(dateTable)
    local addedTime = timeInSeconds + (hoursToAdd * 60 * 60)

    return os.date("%Y-%m-%d %H:%M:%S", addedTime)
end

function abplib.date.addMinutesToDate(dateTimeStr, minutesToAdd)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateTimeStr:match(pattern)
    local dateTable = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
    local timeInSeconds = os.time(dateTable)
    local addedTime = timeInSeconds + (minutesToAdd * 60)

    return os.date("%Y-%m-%d %H:%M:%S", addedTime)
end

function abplib.date.addSecondsToDate(dateTimeStr, secondsToAdd)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = dateTimeStr:match(pattern)
    local dateTable = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
    local timeInSeconds = os.time(dateTable)
    local addedTime = timeInSeconds + secondsToAdd

    return os.date("%Y-%m-%d %H:%M:%S", addedTime)
end

function abplib.date.getHumanTimeFromSeconds(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = math.floor(seconds % 60)

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function abplib.date.getHumanTimeFromMinutes(minutes)
    local hours = math.floor(minutes / 60)
    local minutes = math.floor(minutes % 60)

    return string.format("%02d:%02d", hours, minutes)
end

function abplib.date.getHumanTimeFromMilliseconds(milliseconds)
    local seconds = math.floor(milliseconds / 1000)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = math.floor(seconds % 60)
    local milliseconds = math.floor(milliseconds % 1000)

    return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
end

function abplib.date.formatTime(timeString, returnAsTable)
	local p = promise.new()
	abplib.refactor.tryCatch
		:try(function()
			-- Verificar si el string está bien formado usando patrones
			local valid = timeString:match("^%d*d?%d*h?%d*m?$")
			if not valid then
				error("El formato del string es incorrecto.")
			end
		
			-- Extraer valores de días, horas y minutos usando patrones
			local days = tonumber(timeString:match("(%d+)d")) or 0
			local hours = tonumber(timeString:match("(%d+)h")) or 0
			local minutes = tonumber(timeString:match("(%d+)m")) or 0
		
			-- Asegurar que al menos uno de los valores esté presente
			if days == 0 and hours == 0 and minutes == 0 then
				error("Debe especificar al menos un valor para días, horas o minutos.")
			end
		
			-- Obtener fecha y hora actuales
			local currentTime = os.time()
			local currentDate = os.date("*t", currentTime)
		
			-- Condición especial para los minutos si solo se especifica minutos en el string
			if timeString:match("^%d+m$") and minutes < 10 then
				error("Los minutos deben ser al menos 10 minutos más que los minutos actuales.")
			end
		
			-- Calcular la fecha y hora final
			local finalDate = {
				year = currentDate.year,
				month = currentDate.month,
				day = currentDate.day + days,
				hour = currentDate.hour + hours,
				min = currentDate.min + minutes,
				sec = currentDate.sec
			}

			local finalDateTable = finalDate

			-- Ajustar el tiempo final considerando desbordamiento de horas, minutos y días
			---@diagnostic disable-next-line: cast-local-type
			finalDate = os.date("*t", os.time(finalDate))
			
			---@diagnostic disable-next-line: param-type-mismatch, cast-local-type
			finalDate = os.date("%c", os.time(finalDate))

			p:resolve(returnAsTable and finalDateTable or finalDate)
		end)
		:catch(function(err)
			abplib.print("[Date Error]", err)
			p:resolve(false)
		end)
		:finally(function() end)

	return Citizen.Await(p)
end

abplib.date.createDate = function(day, month, year, hour, minute, second)
    return os.time({year = year, month = month, day = day, hour = hour, min = minute, sec = second})
end

abplib.date.getDaysInMonth = function(month, year)
    local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local days = daysInMonth[month]
    if month == 2 and abplib.date.isLeapYear(year) then
        days = 29
    end
    return days
end

abplib.date.isGreaterThat = function(date1, date2)
    --- Compare dates with day, month, year, hours and minutes
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+)"
    local year1, month1, day1, hour1, min1 = date1:match(pattern)
    local year2, month2, day2, hour2, min2 = date2:match(pattern)
    
    local date1Time = os.time({year = year1, month = month1, day = day1, hour = hour1, min = min1})
    local date2Time = os.time({year = year2, month = month2, day = day2, hour = hour2, min = min2})

    return date1Time > date2Time
end

abplib.date.now = function()
    return os.time()
end

abplib.date.addHoursToTimestamp = function(timestamp, hours)
    return timestamp + (hours * 60 * 60)
end

abplib.date.addMinutesToTimestamp = function(timestamp, minutes)
    return timestamp + (minutes * 60)
end

abplib.date.addSecondsToTimestamp = function(timestamp, seconds)
    return timestamp + seconds
end


abplib.date.nowDate = function()
    return os.date('%Y-%m-%d %H:%M:%S')
end



return abplib.date
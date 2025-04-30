---@diagnostic disable: duplicate-set-field, cast-local-type
local PlaySoundFrontend = PlaySoundFrontend
local xSound = exports.xsound
abplib.utils = {}

--  ______   __  __                        __
-- /      \ /  |/  |                      /  |
-- /$$$$$$  |$$ |$$/   ______   _______   _$$ |_
-- $$ |  $$/ $$ |/  | /      \ /       \ / $$   |
-- $$ |      $$ |$$ |/$$$$$$  |$$$$$$$  |$$$$$$/
-- $$ |   __ $$ |$$ |$$    $$ |$$ |  $$ |  $$ | __
-- $$ \__/  |$$ |$$ |$$$$$$$$/ $$ |  $$ |  $$ |/  |
-- $$    $$/ $$ |$$ |$$       |$$ |  $$ |  $$  $$/
--  $$$$$$/  $$/ $$/  $$$$$$$/ $$/   $$/    $$$$/


if abplib.context == 'client' then
	---Create a floating notification
	---@param msg any
	---@param coords any
	local function floatingText(msg, coords)
		AddTextEntry('nexFloatingHelpNotification', msg)
		---@diagnostic disable-next-line: missing-parameter
		SetFloatingHelpTextWorldPosition(1, coords)
		SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
		BeginTextCommandDisplayHelp('nexFloatingHelpNotification')
		EndTextCommandDisplayHelp(2, false, false, -1)
	end

	abplib.utils.floatingNotification = floatingText

	---Create a bottom notification
	---@param msg string
	---@param time number
	abplib.utils.bottomNotification = function(msg, time)
		ClearPrints()
		SetTextEntry_2("STRING")
		AddTextComponentString(msg)
		EndTextCommandPrint(time, true)
	end

	---Create a floating help notification over the specified ped
	---@param msg string
	---@param duration number
	---@param justFunc boolean
	---@param ped number
	abplib.utils.createThinking = function(msg, duration, justFunc, ped)
		local playerPed = ped or PlayerPedId()

		if justFunc then
			local position = GetEntityCoords(playerPed)
			floatingText(msg, position + vector3(0, 0, 1.0))
		else
			local timer = 0
			CreateThread(function()
				while true do
					local position = GetEntityCoords(playerPed)
					floatingText(msg, position + vector3(0, 0, 1.0))

					timer = timer + 25

					if timer >= duration then
						break
					end

					Wait(1)
				end
			end)
		end
	end


else
	--      ______
	--     /      \
	--    /$$$$$$  |  ______    ______   __     __  ______    ______
	--    $$ \__$$/  /      \  /      \ /  \   /  |/      \  /      \
	--    $$      \ /$$$$$$  |/$$$$$$  |$$  \ /$$//$$$$$$  |/$$$$$$  |
	--     $$$$$$  |$$    $$ |$$ |  $$/  $$  /$$/ $$    $$ |$$ |  $$/
	--    /  \__$$ |$$$$$$$$/ $$ |        $$ $$/  $$$$$$$$/ $$ |
	--    $$    $$/ $$       |$$ |         $$$/   $$       |$$ |
	--     $$$$$$/   $$$$$$$/ $$/           $/     $$$$$$$/ $$/


	abplib.utils.getIdentifier = function(source, idtype)
		if GetConvarInt('sv_fxdkMode', 0) == 1 then return 'license:fxdk' end
		return GetPlayerIdentifierByType(source, idtype or 'steam')
	end


end

--   /$$$$$$  /$$                                           /$$
--  /$$__  $$| $$                                          | $$
-- | $$  \__/| $$$$$$$   /$$$$$$   /$$$$$$   /$$$$$$   /$$$$$$$
-- |  $$$$$$ | $$__  $$ |____  $$ /$$__  $$ /$$__  $$ /$$__  $$
--  \____  $$| $$  \ $$  /$$$$$$$| $$  \__/| $$$$$$$$| $$  | $$
--  /$$  \ $$| $$  | $$ /$$__  $$| $$      | $$_____/| $$  | $$
-- |  $$$$$$/| $$  | $$|  $$$$$$$| $$      |  $$$$$$$|  $$$$$$$
--  \______/ |__/  |__/ \_______/|__/       \_______/ \_______/

abplib.utils.normalizeHeading = function(angle)
    angle = angle % 360
    if angle < 0 then
        angle = angle + 360
    end
    return angle
end

abplib.utils.getSteamId64FromHex = function(hex_id)
	if not hex_id then return "" end
	local len = string.len(hex_id)
	local dec = 0
	for i = 1, len do
		local val = string.sub(hex_id, i, i)
		if val == "a" or val == "A" then
			val = 10 * 16 ^ tonumber(len - i)
		elseif val == "b" or val == "B" then
			val = 11 * 16 ^ tonumber(len - i)
		elseif val == "c" or val == "C" then
			val = 12 * 16 ^ tonumber(len - i)
		elseif val == "d" or val == "D" then
			val = 13 * 16 ^ tonumber(len - i)
		elseif val == "e" or val == "E" then
			val = 14 * 16 ^ tonumber(len - i)
		elseif val == "f" or val == "F" then
			val = 15 * 16 ^ tonumber(len - i)
		else
			val = tonumber(val) * 16 ^ tonumber(len - i)
		end
		dec = dec + math.ceil(val)
	end
	return dec
end

abplib.utils.secondsToClock = function(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds / 3600));
		mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
		secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
		return hours .. ":" .. mins .. ":" .. secs
	end
end


abplib.utils.hexToRGB = function(hex)
	hex = hex:gsub("#", "")
    return {
		r = tonumber("0x" .. hex:sub(1, 2)),
		g = tonumber("0x" .. hex:sub(3, 4)),
        b = tonumber("0x" .. hex:sub(5, 6))
	}
end

return abplib.utils

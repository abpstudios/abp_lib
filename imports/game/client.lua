local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

function EnumerateObjects() return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject) end
function EnumeratePeds() return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) end
function EnumerateVehicles() return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) end
function EnumeratePickups() return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup) end


abplib.game = {}

abplib.game.draw3D = function(coords, text, size, font)

    if not size then size = 1.0 end
	if not font then font = 0 end

    local x, y, z = table.unpack(coords)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
	local distance = #(coords - camCoords)
    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0, 0.55 * scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)

        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

abplib.game.draw2d = function(text, position, scale, font)
    if not scale then scale = vec2(0.15, 0.15) end
    if not font then font = 8 end
    
    SetTextFont(font)
    SetTextScale(scale.x, scale.y)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawText(position.x, position.y)
end

abplib.game.getObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

abplib.game.getPeds = function(onlyOtherPeds)
	local peds, myPed = {}, PlayerPedId()

	for ped in EnumeratePeds() do
		if ((onlyOtherPeds and ped ~= myPed) or not onlyOtherPeds) then
			table.insert(peds, ped)
		end
	end

	return peds
end

abplib.game.getVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

abplib.game.getVehicleInDirection = function()
	local playerPed      = PlayerPedId()
	local playerCoords   = GetEntityCoords(playerPed)
	local inDirection    = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
	local rayHandle      = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end

abplib.game.getClosestEntity = function(entities, isPlayerEntities, coords, modelFilter)
	local closestEntity, closestEntityDistance, filteredEntities = -1, -1, nil

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	if modelFilter then
		filteredEntities = {}

		for k, entity in pairs(entities) do
			if modelFilter[GetEntityModel(entity)] then
				table.insert(filteredEntities, entity)
			end
		end
	end

	for k, entity in pairs(filteredEntities or entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if closestEntityDistance == -1 or distance < closestEntityDistance then
			closestEntity, closestEntityDistance = isPlayerEntities and k or entity, distance
		end
	end

	return closestEntity, closestEntityDistance
end

abplib.game.getClosestObject = function(coords, modelFilter) 
    return abplib.game.getClosestEntity(abplib.game.getObjects(), false, coords, modelFilter)
end
abplib.game.getVehiclesInArea = function(coords, maxDistance) 
	return EnumerateEntitiesWithinDistance(abplib.game.getVehicles(), false, coords, maxDistance)
end

abplib.game.isSpawnPointClear = function(coords, maxDistance)
	return #abplib.game.getVehiclesInArea(coords, maxDistance) == 0
end

abplib.game.spawnVehicle = function(modelName, coords, heading, isNetwork)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	local modelLoaded = abplib.streaming.loadModel(model)
	if not modelLoaded then return false end

	local network = isNetwork and isNetwork or true
	local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, network, false)
	local networkId = NetworkGetNetworkIdFromEntity(vehicle)

	SetNetworkIdCanMigrate(networkId, true)
	SetVehicleHasBeenOwnedByPlayer(vehicle, true)
	SetEntityAsMissionEntity(vehicle, true, true)
	SetVehRadioStation(vehicle, 'OFF')
	SetVehicleNeedsToBeHotwired(vehicle, false)
	SetModelAsNoLongerNeeded(model)

	SetEntityCollision(vehicle, false, true)
	FreezeEntityPosition(vehicle, true)

	RequestCollisionAtCoord(coords.x, coords.y, coords.z)
	-- we can get stuck here if any of the axies are "invalid"
	local timeout = 0
	while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 2000 do
		Wait(100)
		timeout = timeout + 100
	end

	SetEntityCollision(vehicle, true, true)
	FreezeEntityPosition(vehicle, false)

	if DecorIsRegisteredAsType("Player_Vehicle", 3) then
		DecorSetInt(vehicle, "Player_Vehicle", -1)
	end

	return vehicle
end

abplib.game.spawnLocalVehicle = function(model, coords, heading)
	return abplib.game.spawnVehicle(model, coords, heading, true)
end

abplib.game.getPlayers = function(onlyOtherPlayers, returnKeyValue, returnPeds)
	local players, myPlayer = {}, PlayerId()

	for _, player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) and ((onlyOtherPlayers and player ~= myPlayer) or not onlyOtherPlayers) then
			if returnKeyValue then
				players[GetPlayerServerId(player)] = ped
			else
				table.insert(players, returnPeds and ped or GetPlayerServerId(player))
			end
		end
	end

	return players
end

abplib.game.getPlayersInArea = function(coords, maxDistance, onlyOthersPlayers) 
	return EnumerateEntitiesWithinDistance(abplib.game.getPlayers(onlyOthersPlayers, true, true), true, coords, maxDistance)
end

return abplib.game
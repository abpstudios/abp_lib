abplib.vector = {}
abplib.vector.randomPositionInRange = function(basePosition, limitDistance, randomizeZ)
	local angle = math.random() * (2 * math.pi)
	local distance = math.random() * limitDistance

	local offsetX = math.cos(angle) * distance
	local offsetY = math.sin(angle) * distance
	local offsetZ = randomizeZ and (math.random() * 10.0 - 5.0) or 0.0

	return vector3(basePosition.x + offsetX, basePosition.y + offsetY, basePosition.z + offsetZ)
end

abplib.vector.getRandomPosition = function(height)
    -- Genera una posición aleatoria dentro de un rango específico en el mapa
    local x = math.random(-2000, 2000)
    local y = math.random(-2000, 2000)
    local z = height or 45.0 -- Altura por defecto (ajustar según tu mapa)
    return vector3(x, y, z)
end

-- Función para obtener una posición aleatoria en un radio específico
abplib.vector.isFlatEmpty = function(position, radius, minHeight, maxSlope, objectSize, checkWater, ignoreObjects)
	-- Obtener la altura del terreno en la posición actual
	local success, groundZ = GetGroundZFor_3dCoord(position.x, position.y, position.z + 1000.0, false)

	if not success then
		return false -- Si no se puede obtener la altura del terreno, consideramos que no es una posición válida
	end

	-- Verificar si la altura del terreno es mayor que el minHeight
	if groundZ < minHeight then
		return false -- La posición es demasiado baja
	end

	-- Si es necesario, verificar si hay agua en la posición (opcional)
	if checkWater and TestProbeAgainstWater(position.x, position.y, position.z + 1000.0, position.x, position.y, groundZ) then
		return false -- Hay agua en la posición
	end

	-- Verificar la inclinación del terreno (opcional)
	if maxSlope then
		local slopeVector = vector3(position.x + 1.0, position.y, groundZ)
		local successSlope, groundZSlope = GetGroundZFor_3dCoord(slopeVector.x, slopeVector.y, slopeVector.z + 1000.0, false)
		if successSlope then
			local slope = math.abs(groundZ - groundZSlope)
			if slope > maxSlope then
				return false -- La pendiente es demasiado inclinada
			end
		end
	end

	-- Verificar colisiones con objetos en la zona dentro del radio
	if not ignoreObjects then
		-- Generar múltiples puntos en el radio dado para comprobar si están vacíos
		local numChecks = 8 -- Número de puntos a verificar alrededor del área
		for i = 1, numChecks do
			-- Calcular el ángulo y la posición para cada punto a chequear
			local angle = (i / numChecks) * math.pi * 2
			local offsetX = math.cos(angle) * radius
			local offsetY = math.sin(angle) * radius
			local checkPos = vector3(position.x + offsetX, position.y + offsetY, groundZ)

			-- Realizar un raycast para comprobar si hay objetos en esta posición
			local startCoords = vector3(checkPos.x, checkPos.y, checkPos.z + 1.0)
			local endCoords = vector3(checkPos.x, checkPos.y, checkPos.z - 1.0)

			local rayHandle = StartShapeTestCapsule(startCoords.x, startCoords.y, startCoords.z, endCoords.x, endCoords.y, endCoords.z, objectSize, 10, 0, 7)
			local retval, hit, hitPosition, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

			if hit == 1 then
				return false -- Si cualquier punto tiene un objeto, no es válido
			end
		end
	end

	-- Si pasó todas las comprobaciones, es una posición válida
	return true
end

return abplib.vector
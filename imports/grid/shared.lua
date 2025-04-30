abplib.grid = {}

-- Function: abplib.grid.generate
-- Generates a grid of vectors based on the input data
---@param gridData {coords: vector3, x: number, y: number, size: number, rotation: number, fillDensity?:number, shape?:string, radius?:number, segments?:number, skew?:number}
---@return vector3[]
abplib.grid.generate = function(gridData)
    local worldLocation = gridData.coords
    local gridX = gridData.x
    local gridY = gridData.y
    local size = gridData.size
    local shape = gridData.shape or 'grid'

    local gridArray = {}
    local rotationAngle = math.rad(gridData.rotation)

    if shape == 'circle' then
        local radius = gridData.radius or (size * math.min(gridX, gridY) / 2) -- Radio del círculo
        local segments = gridData.segments or (gridX * gridY) -- Número de puntos en el borde
        local fillDensity = gridData.fillDensity or 5 -- Controla la densidad del relleno (más alto = más puntos)

        -- Genera los puntos del borde del círculo
        for r = 0, radius, radius / fillDensity do
            for i = 0, segments - 1 do
                local angle = (i / segments) * 2 * math.pi -- Distribuye puntos alrededor del círculo
                local x = r * math.cos(angle)
                local y = r * math.sin(angle)

                local x_rot = x * math.cos(rotationAngle) - y * math.sin(rotationAngle)
                local y_rot = x * math.sin(rotationAngle) + y * math.cos(rotationAngle)

                local finalVector = vec3(x_rot + worldLocation.x, y_rot + worldLocation.y, worldLocation.z)
                table.insert(gridArray, finalVector)
            end
        end
    elseif shape == 'rhombus' then
        local skew = gridData.skew or 0.5 -- Factor de inclinación entre filas
        
        for i = 0, (gridX - 1) do
            local x = i * size
            for i2 = 0, (gridY - 1) do
                local y = i2 * size
                -- Aplica un desplazamiento en X basado en el índice de fila para crear el romboide
                local skewOffset = i2 * size * skew

                local x_rot = (x + skewOffset) * math.cos(rotationAngle) - y * math.sin(rotationAngle)
                local y_rot = (x + skewOffset) * math.sin(rotationAngle) + y * math.cos(rotationAngle)

                local finalVector = vec3(x_rot + worldLocation.x, y_rot + worldLocation.y, worldLocation.z)
                table.insert(gridArray, finalVector)
            end
        end
    elseif shape == 'triangle' then
        for i = 0, (gridY - 1) do
            local y = i * size
            local rowLength = gridX - i -- Disminuye la longitud de cada fila para formar un triángulo

            for j = 0, (rowLength - 1) do
                local x = j * size + (i * size / 2) -- Desplaza cada fila un poco para centrar el triángulo

                local x_rot = x * math.cos(rotationAngle) - y * math.sin(rotationAngle)
                local y_rot = x * math.sin(rotationAngle) + y * math.cos(rotationAngle)

                local finalVector = vec3(x_rot + worldLocation.x, y_rot + worldLocation.y, worldLocation.z)
                table.insert(gridArray, finalVector)
            end
        end
    else
        for i=0, (gridX-1) do
            local x = i * size
            for i2=0, (gridY-1) do
            local y = i2 * size

            local x_rot = x * math.cos(rotationAngle) - y * math.sin(rotationAngle)
            local y_rot = x * math.sin(rotationAngle) + y * math.cos(rotationAngle)

            local finalVector = vec3(x_rot+worldLocation.x, y_rot+worldLocation.y, worldLocation.z)
            table.insert(gridArray, finalVector)
            end
        end
    end


    return gridArray
end

abplib.grid.generateQuaternion = function(gridData)
    local points = gridData.points -- Lista de puntos en el formato {vec3(x, y, z), ...}
    local density = gridData.density or 20 -- Controla la densidad de puntos
    local randomOffset = gridData.randomOffset or 0 -- Máxima variación aleatoria en posición
    local rotationAngle = math.rad(gridData.rotation or 0)

    -- Calcular el área del polígono utilizando la fórmula de área de un polígono simple
    local area = 0
    for i = 1, #points do
        local j = (i % #points) + 1
        area = area + (points[i].x * points[j].y - points[j].x * points[i].y)
    end
    area = math.abs(area) / 2

    -- Calcular el número de puntos que caben en el área, ajustando el tamaño
    local pointsCount = gridData.pointsCount or math.floor(area / (density * 10))
    local size = gridData.size
    if not size then
        -- Ajustar el tamaño en función del área y la densidad
        local desiredPoints = pointsCount -- Aproximadamente cuántos puntos queremos
        local boundingBoxArea = (points[1].x - points[2].x) * (points[1].y - points[4].y) -- Área de la caja delimitadora
        size = math.sqrt(boundingBoxArea / desiredPoints)
    end

    local gridArray = {}

    -- Calcular los límites de la caja de contorno del polígono
    local minX, minY = points[1].x, points[1].y
    local maxX, maxY = points[1].x, points[1].y
    for _, point in ipairs(points) do
        if point.x < minX then minX = point.x end
        if point.y < minY then minY = point.y end
        if point.x > maxX then maxX = point.x end
        if point.y > maxY then maxY = point.y end
    end

    -- Función para verificar si un punto está dentro del polígono (método del rayo)
    local function isPointInPolygon(x, y)
        local inside = false
        local j = #points
        for i = 1, #points do
            local xi, yi = points[i].x, points[i].y
            local xj, yj = points[j].x, points[j].y
            if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
                inside = not inside
            end
            j = i
        end
        return inside
    end

    -- Generar los puntos en la cuadrícula con el tamaño calculado y aplica personalización
    for x = minX, maxX, size do
        for y = minY, maxY, size do
            -- Rota el punto y agrega variación aleatoria si se habilitó
            local x_with_rotation = x * math.cos(rotationAngle) - y * math.sin(rotationAngle)
            local y_with_rotation = x * math.sin(rotationAngle) + y * math.cos(rotationAngle)
            local x_final = x_with_rotation + math.random() * randomOffset - randomOffset / 2
            local y_final = y_with_rotation + math.random() * randomOffset - randomOffset / 2

            -- Solo agrega el punto si está dentro del polígono
            if isPointInPolygon(x_final, y_final) then
                local finalVector = vec3(x_final, y_final, points[1].z) -- Usa la misma altura (z)
                table.insert(gridArray, finalVector)
            end
        end
    end

    -- Si el número de puntos generados es bajo, incrementar la densidad para cubrir más áreas
    if #gridArray < pointsCount then
        local increaseDensity = math.ceil(pointsCount / #gridArray)
        return abplib.grid.generateQuaternion({
            points = points,
            density = increaseDensity,
            randomOffset = gridData.randomOffset,
            rotation = gridData.rotation,
            size = size
        })
    end

    return gridArray
end

abplib.grid.generateSimpleQuaternion = function(gridData)
    local points = gridData.points
    local size = gridData.size or 1
    local gridArray = {}

    if #points < 3 then
        print("Error: Necesitas al menos 3 puntos para generar una cuadrícula.")
        return gridArray
    end

    local minX, minY = points[1].x, points[1].y
    local maxX, maxY = points[1].x, points[1].y

    for _, point in ipairs(points) do
        if point.x < minX then minX = point.x end
        if point.y < minY then minY = point.y end
        if point.x > maxX then maxX = point.x end
        if point.y > maxY then maxY = point.y end
    end

    local function isPointInPolygon(x, y)
        local inside = false
        local j = #points
        for i = 1, #points do
            local xi, yi = points[i].x, points[i].y
            local xj, yj = points[j].x, points[j].y
            if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
                inside = not inside
            end
            j = i
        end
        return inside
    end

    for x = minX, maxX, size do
        for y = minY, maxY, size do
            if isPointInPolygon(x, y) then
                local finalVector = vec3(x, y, points[1].z)
                table.insert(gridArray, finalVector)
            end
        end
    end

    return gridArray
end

if abplib.context == 'client' then
    -- Function: abplib.grid.draw
    ---Draws the grid on the client side
    ---@param gridArray vector3[]
    ---@return vector3[]
    abplib.grid.transformZToGround = function(gridArray, minusZ)
        for k, v in pairs(gridArray) do
            local _, groundZ = GetGroundZExcludingObjectsFor_3dCoord(v.x, v.y, v.z, false)
            gridArray[k] = vec3(v.x, v.y, groundZ - (minusZ or 0))
        end

        return gridArray
    end
end

return abplib.grid
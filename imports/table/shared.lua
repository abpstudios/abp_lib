abplib.table = {}

abplib.table.dump = function(table, nb)
    if nb == nil then
        nb = 0
    end

    if type(table) == 'table' then
        local s = ''
        for i = 1, nb + 1, 1 do
            s = s .. "    "
        end

        s = '{\n'
        for k, v in pairs(table) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            for i = 1, nb, 1 do
                s = s .. "    "
            end
            s = s .. '[' .. k .. '] = ' .. abplib.table.dump(v, nb + 1) .. ',\n'
        end

        for i = 1, nb, 1 do
            s = s .. "    "
        end

        return s .. '}'
    else
        return tostring(table)
    end
end

abplib.table.sizeOf = function(t)
	local count = 0

	for _, _ in pairs(t) do
		count = count + 1
	end

	return count
end

abplib.table.contains = function(t, e)
	for _, val in pairs(t) do
		if val == e then
			return true
		end
	end
end

abplib.table.containsKey = function(t, e)
    for key, _ in pairs(t) do
        if key == e then
            return true
        end
    end
end

abplib.table.forEach = function(t, cb)
    for k, v in pairs(t) do
        cb(k, v)
    end
end

abplib.table.deepCopy = function(t)
    local u = {}
    for k, v in pairs(t) do
        u[k] = v
    end

    return setmetatable(u, getmetatable(t))
end

abplib.table.copy = function(t)
    local u = {}
    for k, v in pairs(t) do
        u[k] = v
    end

    return u
end

abplib.table.map = function(t, fn)
    local auxTable = {}
    for k, v in pairs(t) do
      auxTable[k] = fn(v, k)
    end

    return auxTable
end

return abplib.table
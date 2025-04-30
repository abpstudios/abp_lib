local Charset = {}

for i = 48, 57 do table.insert(Charset, string.char(i)) end
for i = 65, 90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end


abplib.string = {}

abplib.string.randomToken = function(startWith)
	local abc = { "a", "b", "z", "r", "g" }
	return tostring(abplib.string.randomString(5) ..
		(startWith or "-N-") ..
		GetGameTimer() ..
		"-E-" ..
		abplib.string.randomString(16) ..
		abc[math.random(1, #abc)] ..
		abc[math.random(1, #abc)] ..
		abc[math.random(1, #abc)] .. "-X-" .. (GetGameTimer() + 7 * 1200) .. abc[math.random(1, #abc)])
end

abplib.string.split = function(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end


abplib.string.randomString = function(length)
	math.randomseed(GetGameTimer())

	if length > 0 then
		return abplib.string.randomString(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

abplib.string.trim = function(inputstr)
    return (inputstr:gsub("^%s*(.-)%s*$", "%1"))
end

abplib.string.removeTildes = function(inputstr)
	return (inputstr:gsub("~.-~", ""))
end

return abplib.string
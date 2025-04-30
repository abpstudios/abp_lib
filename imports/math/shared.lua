abplib.math = {}
abplib.math.round = function(value, numDecimalsPlaces)
	local mult = 10 ^ (numDecimalsPlaces or 0)
	return math.floor(value * mult + 0.5) / mult
end

abplib.math.groupDigits = function(value, pattern)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1' .. (pattern or '.')):reverse()) .. right
end

abplib.math.trim = function(value)
	return value:match("^%s*(.-)%s*$")
end

abplib.math.isBetween = function(value, min, max)
	return value >= min and value <= max
end

return abplib.math
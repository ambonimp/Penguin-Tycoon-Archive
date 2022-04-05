local Format = {}

local prefixes = {
	[2] = "K", [3] = "M", [4] = "B", [5] = "T"
}

function Format:FormatAbbreviated(n)
	if n ~= nil then
		n = math.floor(n)

		local NewNum
		local Str = tostring(n)
		local Length = string.len(Str)
		local Rounded = tonumber(string.sub(Str, 1, 3))
		local PrefixNumber = math.ceil(Length/3)
		local prefix = prefixes[PrefixNumber]
		if Length >= 4 then -- If it's in the thousands, then format it.
			if Length%3 == 1 then
				NewNum = tostring(Rounded/100)..prefix
			end
			if Length%3 == 2 then
				NewNum = tostring(Rounded/10)..prefix
			end
			if Length%3 == 0 then
				NewNum = tostring(Rounded/1)..prefix
			end
		else
			NewNum = n
		end
		return NewNum
	end
end

function Format:FormatComma(n)
	local formatted = math.floor(n)
	local k

	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end

	return formatted
end



--- Time Formatting ---
function Format:FormatTimeDHM(Time)
	local days = math.floor(Time / 86400)
	local hours = math.floor(Time / 3600) - days * 24
	local minutes = math.floor(Time / 60) - days * 1440 - hours * 60
	local totalMinutes = (days * 1440 + hours * 60 + minutes)
	local seconds = Time - totalMinutes * 60

	if string.len(tostring(hours)) == 1 then
		hours = "0"..hours
	end
	if string.len(tostring(minutes)) == 1 then
		minutes = "0"..minutes
	end
	if string.len(tostring(seconds)) == 1 then
		seconds = "0"..seconds
	end

	return days.."D "..hours.."H "..minutes.."M "
end

function Format:FormatTimeHMS(Time)
	local hours = math.floor(Time / 3600)
	local minutes = math.floor(Time / 60) - hours * 60
	local totalMinutes = (hours * 60 + minutes)
	local seconds = Time - totalMinutes * 60

	if string.len(tostring(hours)) == 1 then
		hours = "0"..hours
	end
	if string.len(tostring(minutes)) == 1 then
		minutes = "0"..minutes
	end
	if string.len(tostring(seconds)) == 1 then
		seconds = "0"..seconds
	end

	return hours.."H "..minutes.."M "..seconds.."S"
end


return Format
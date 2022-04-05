local RunService = game:GetService("RunService")

local logger = {
	_infoLogEnabled = false,
	_infoLogAdvancedEnabled = false,
	_debugEnabled = true -- RunService:IsStudio(),
}

function logger:setDebugLog(enabled)
	self._debugEnabled = enabled
end

function logger:setInfoLog(enabled)
	self._infoLogEnabled = enabled
end

function logger:setVerboseLog(enabled)
	self._infoLogAdvancedEnabled = enabled
end

function logger:i(format)
	if not self._infoLogEnabled then
		return
	end

	local m = "DiveSDK > Info: " .. format
	print(m)
end

function logger:w(format)
	local m = "DiveSDK > Warning: " .. format
	warn(m)
end

function logger:e(format)
	spawn(function()
		local m = "DiveSDK > Error: " .. format
		error(m, 0)
	end)
end

function logger:d(format)
	if not self._debugEnabled then
		return
	end
	print("DiveSDK > Debug: ", format)
end

function logger:ii(format)
	if not self._infoLogAdvancedEnabled then
		return
	end

	local m = "DiveSDK > Verbose: " .. format
	print(m)
end

return logger
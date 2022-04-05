local Teleporting = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Functions ---
Remotes.Teleport.OnServerInvoke = function(Player, PlaceId, GameId)
	local TPOptions = Instance.new("TeleportOptions")
	if GameId then
		TPOptions.ServerInstanceId = GameId
	end

	local Success, Error = pcall(function()
		return Services.TeleportService:TeleportAsync(PlaceId, {Player}, TPOptions)
	end)

	return Success, Error
end


return Teleporting
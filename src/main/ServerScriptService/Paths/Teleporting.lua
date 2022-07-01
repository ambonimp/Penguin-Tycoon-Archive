local Workspace = game:GetService("Workspace")
local Teleporting = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Functions ---
Remotes.TeleportExternal.OnServerInvoke = function(Player, PlaceId, GameId)
	local TPOptions = Instance.new("TeleportOptions")
	if GameId then
		TPOptions.ServerInstanceId = GameId
	end

	local Success, Error = pcall(function()
		return Services.TeleportService:TeleportAsync(PlaceId, {Player}, TPOptions)
	end)

	return Success, Error
end

Remotes.TeleportInternal.OnServerInvoke = function(Client, To)
	local Character = Client.Character

	if Character then
		local SpawnPart
		if game.Players:FindFirstChild(To) then
			SpawnPart = Workspace.Tycoons[game.Players:FindFirstChild(To):GetAttribute("Tycoon")].Spawn
		elseif workspace.Islands:FindFirstChild(To) then
			SpawnPart = workspace.Islands:FindFirstChild(To).Spawn
		end

		if SpawnPart then
			local CFrame = SpawnPart.CFrame + Vector3.new(0, 3, 0)
			Client:RequestStreamAroundAsync(CFrame.Position)
			Character:SetPrimaryPartCFrame(CFrame)
		end

	end

end

return Teleporting
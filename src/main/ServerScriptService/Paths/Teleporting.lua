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

	local PlayersBeingTeleported
	local PartyId = Player:GetAttribute("Party")
	if PartyId and Player.UserId == PartyId then -- Player is in a party and they are it's leader
		PlayersBeingTeleported = Modules.PartyUtil.GetPartyMembers(PartyId)

		for i = 1, #PlayersBeingTeleported do -- Using this kind of loop because player's can be removed
			local Player = PlayersBeingTeleported[i]

			local Data = Modules.PlayerData.sessionData[Player.Name]
			if Data then
				Data.TeleportedParty = PartyId
			else
				table.remove(PlayersBeingTeleported, i)
			end

		end

	else
		PlayersBeingTeleported = {Player}
	end

	local Success, Error = pcall(function()
		return Services.TeleportService:TeleportAsync(PlaceId, PlayersBeingTeleported, TPOptions)
	end)

	return Success, Error
end

Remotes.TeleportInternal.OnServerInvoke = function(Client, To)
	local Character = Client.Character

	if Character then
		local SpawnPart
		if game.Players:FindFirstChild(To) then
			SpawnPart = workspace.Tycoons[game.Players:FindFirstChild(To):GetAttribute("Tycoon")].Spawn
			Client:SetAttribute("World", 1)

		elseif workspace.Islands:FindFirstChild(To) then
			SpawnPart = workspace.Islands:FindFirstChild(To).Spawn
		elseif "Woodcutting World" then
			SpawnPart = workspace.Tycoons[Client:GetAttribute("Tycoon")].Tycoon["New Island!#32"].Spawn
			Client:SetAttribute("World", 2)

		end

		if SpawnPart then
			local CFrame = SpawnPart.CFrame + Vector3.new(0, 3, 0)
			Client:RequestStreamAroundAsync(CFrame.Position)
			Character:SetPrimaryPartCFrame(CFrame)
		end

	end

end

return Teleporting
local Save = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Other Variables ---
local AUTOSAVE_INTERVAL = 20

Save.LastSaved = {}
Save.IsSaving = {}


--- Saving Functions ---
function Save:SavePlayerData(player)
	local playerName = player.Name
	local playerData = Modules.PlayerData.sessionData[playerName]
	playerData["Playtime"][2] = os.time()
	Modules.PlayerData.sessionData[playerName]["LastPlayTime"] = os.time()
-- Prevent Errors / False Saving
	if not playerData then
		return warn(playerName .. "'s data couldn't be saved cause it wasnt initialized!")
	elseif self.IsSaving[playerName] then
		return warn(playerName .. "'s data is already being saved!")
	end

-- Attempt to save if it's all good
	self.IsSaving[playerName] = true

	local now = tick()
	local timeUntilNextSave = self.LastSaved[playerName] and self.LastSaved[playerName] + 6 - now or 0

	if timeUntilNextSave > 0 then
		wait(timeUntilNextSave)
	end

	local success = Modules.PlayerData.DataStoreRetry(function()
		return Modules.PlayerData.PlayerDataStore:SetAsync(player.UserId, playerData)
	end)

	self.IsSaving[player.Name] = false

	if success then
		self.LastSaved[player.Name] = tick()
	else
		warn("Couldn't save " .. player.Name .. "'s data!")
	end
end


--- Auto-Save ---
function AutoSave()
	while true do
		wait(AUTOSAVE_INTERVAL)
		for i, Player in pairs(game.Players:GetPlayers()) do
			if Modules.PlayerData.sessionData[Player.Name] ~= nil and Player ~= nil then
				Save:SavePlayerData(Player)
			end
		end
	end
end
coroutine.wrap(function()
	AutoSave()
end)()

-- Handles player leaving
game.Players.PlayerRemoving:Connect(function(Player)
	if workspace:FindFirstChild(Player.Name) then
		workspace[Player.Name]:Destroy()
	end
	
	Save:SavePlayerData(Player)

	if not game.Players:FindFirstChild(Player.Name) then
		Modules.PlayerData.sessionData[Player.Name] = nil
		Save.LastSaved[Player.Name] = nil
		Save.IsSaving[Player.Name] = nil
	end
end)

-- Handles game shutdown
game:BindToClose(function()
	for index, Player in pairs(game.Players:GetPlayers()) do
		Save:SavePlayerData(Player)
	end
end)

return Save
local Leaderboards = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Paths.Dependency:FindFirstChild(script.Name)
--- Variables ---
local DATASTORE_RETRIES = 3
local LOOP_INTERVAL = 5

local function dataStoreRetry(dataStoreFunction)
	local tries = 0	
	local success = true
	local data = nil
	repeat
		tries = tries + 1
		success = pcall(function() data = dataStoreFunction() end)
		if not success then wait(1) end
	until tries == DATASTORE_RETRIES or success
	if not success then
		error("Could not access DataStore! Warn players that their data might not get saved!")
	end
	return success, data
end

local leaderboards = {
	["Total Money"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Total Money_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Total Money"];
		smallestFirst = false;};
	["Total Gems"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Total Gems_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Total Gems"];
		smallestFirst = false;};
	["Hearts"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Hearts_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Hearts"];
		smallestFirst = false;};
	["Skate Race Record"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Skate Race Record_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Skate Race Record"];
		smallestFirst = true;};
	["Soccer"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Soccer_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Soccer"];
		smallestFirst = false;};
	["Falling Tiles"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Falling Tiles_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Falling Tiles"];
		smallestFirst = false;};
	["Candy Rush"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Candy Rush_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Candy Rush"];
		smallestFirst = false;};
	["Ice Cream Extravaganza"] = {
		DataStore = Services.DataStoreService:GetOrderedDataStore("Ice Cream Extravaganza_v-RELEASE"),
		Leaderboard = workspace.Leaderboards["Ice Cream Extravaganza"];
		smallestFirst = false;};
}

local function LoadPenguin(userId, penguin)
	coroutine.wrap(function()
		local success, data = Modules.PlayerData.getData(userId)

		if success and data then
			local PenguinInfo = data["My Penguin"]
			Modules.Penguins:LoadPenguin(penguin, PenguinInfo)
		end
	end)()
end

--- Functions ---
function Leaderboards:beginLeaderboardUpdate()
	while true do
		--	-- Datastore variables:
		local numberToShow = 100
		local minValue = 0
		local maxValue = 10e50

		for Stat, lbInfo in pairs(leaderboards) do
			for i, Player in pairs(game.Players:GetChildren()) do--Loop through players
				local Data = Modules.PlayerData.sessionData[Player.Name]

				if Player.UserId > 0 and Data ~= nil then--Prevent errors
					local PlrStat = Data["Stats"][Stat] or Data[Stat]
					if PlrStat then
						if Stat == "Skate Race Record" and PlrStat < Modules.EventsConfig["Skate Race"].FastestPossible*100 then
							pcall(function()
								Data["Stats"][Stat] = 12000
								lbInfo.DataStore:SetAsync(Player.UserId, 12000)
							end)
						else
							PlrStat = math.floor(PlrStat)
							pcall(function()
								lbInfo.DataStore:UpdateAsync(Player.UserId,function(oldVal)
									return tonumber(PlrStat) --Set new value
								end)
							end)
						end
					end
				end
			end

			local pages = nil
			pcall(function()
				pages = lbInfo.DataStore:GetSortedAsync(lbInfo.smallestFirst, numberToShow, minValue, maxValue)
			end)

			if pages then
				local top = pages:GetCurrentPage()

				-- Reset player list
				Dependency.PlayerList:ClearAllChildren()
				Dependency.UIListLayout:Clone().Parent = Dependency.PlayerList

				-- Load players into playerlist
				for rank, player in ipairs(top) do
					local userid = player.key
					local username = "[Failed To Load]"
					pcall(function()
						username = game.Players:GetNameFromUserIdAsync(userid)
					end)

					local Value = player.value
					local ValueFormatted

					if Stat == "Total Playtime" then
						ValueFormatted = Modules.Format:FormatTimeDHM(Value)
					elseif Stat == "Skate Race Record" then
						ValueFormatted = Value/100
					else
						ValueFormatted = Modules.Format:FormatAbbreviated(Value)
					end

					local PlrCard = Dependency.PlayerTemplate:Clone()
					PlrCard.Rank.Text = rank.."."
					PlrCard.PlrName.Text = username
					PlrCard.Value.Text = ValueFormatted
					PlrCard.Parent = Dependency.PlayerList
					PlrCard.LayoutOrder = rank
					PlrCard.Name = rank

					if rank <= 3 and rank >= 1 then
						local penguin = lbInfo.Leaderboard["Penguin#"..rank]
						LoadPenguin(userid, penguin)
					end
				end

				-- Paste playerlist into leaderboards
				if lbInfo.Leaderboard:FindFirstChild("Display") and lbInfo.Leaderboard.Display:FindFirstChild("GUI") then
					if lbInfo.Leaderboard.Display.GUI:FindFirstChild("PlayerList") then
						lbInfo.Leaderboard.Display.GUI.PlayerList:Destroy()
					end

					Dependency.PlayerList:Clone().Parent = lbInfo.Leaderboard.Display.GUI
				end

				wait(LOOP_INTERVAL)
			end
		end
		wait(LOOP_INTERVAL*4)
	end
end

coroutine.wrap(function()
	Leaderboards:beginLeaderboardUpdate()
end)()


return Leaderboards
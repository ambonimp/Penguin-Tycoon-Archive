-- Handles the OrderedDataStore leaderboards (top 100 lists)

local Leaderboards = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Paths.Dependency:WaitForChild(script.Name)
--- Variables ---
local DATASTORE_RETRIES = 3
local LOOP_INTERVAL = 10

local function dataStoreRetry(dataStoreFunction)
	local tries = 0	
	local success = true
	local data = nil
	repeat
		tries = tries + 1
		success = pcall(function() data = dataStoreFunction() end)
		if not success then task.wait(1) end
	until tries == DATASTORE_RETRIES or success
	if not success then
		error("Could not access DataStore! Warn players that their data might not get saved!")
	end
	return success, data
end

local LeaderboardDataStores = {
	["Total Money"] = Services.DataStoreService:GetOrderedDataStore("Total Money_v-RELEASE");
	["Total Playtime"] = Services.DataStoreService:GetOrderedDataStore("Total Playtime-RELEASE");
	["Youtube Minigame Score"] = Services.DataStoreService:GetOrderedDataStore("Youtube Minigame Score_v-RELEASE");
}

local LeaderboardModels = {
	["Total Money"] = {};
	["Total Playtime"] = {};
	["Youtube Minigame Score"] = {};
}


-- Since each tycoon has it's own leaderboard, this adds the physical leaderboard to the table so it can be updated
function Leaderboards:LeaderboardAdded(Model)
	local Stat = Model:GetAttribute("Stat")
	if Stat then
		table.insert(LeaderboardModels[Stat], Model)
	end
end


--- Functions ---

-- infinite loop to continuously update all leaderboards
function Leaderboards:beginLeaderboardUpdate()
	while true do
		Remotes.LeaderboardUpdated:FireAllClients()

		--	-- Datastore variables:
		local smallestFirst = false
		local numberToShow = 100
		local minValue = 0
		local maxValue = 10e50

		for Stat, Datastore in pairs(LeaderboardDataStores) do
			for i, Player in pairs(game.Players:GetChildren()) do--Loop through players
				local Data = Modules.PlayerData.sessionData[Player.Name]
				
				if Player.UserId > 0 and Data ~= nil then--Prevent errors
					local PlrStat = math.floor(Data["Stats"][Stat] or Data[Stat])
					
					if PlrStat then
						pcall(function()
							Datastore:UpdateAsync(Player.UserId,function(oldVal)
								return tonumber(PlrStat) --Set new value
							end)
						end)
					end
				end
			end
			
			local pages = nil
			pcall(function()
				pages = Datastore:GetSortedAsync(smallestFirst, numberToShow, minValue, maxValue)
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
				end

				-- Paste playerlist into leaderboards
				for i, Leaderboard in pairs(LeaderboardModels[Stat]) do
					if Leaderboard:FindFirstChild("Display") and Leaderboard.Display:FindFirstChild("GUI") then
						if Leaderboard.Display.GUI:FindFirstChild("PlayerList") then
							Leaderboard.Display.GUI.PlayerList:Destroy()
						end

						Dependency.PlayerList:Clone().Parent = Leaderboard.Display.GUI
					end
				end

				task.wait(LOOP_INTERVAL)
			end
		end
	end
end

coroutine.wrap(function()
	Leaderboards:beginLeaderboardUpdate()
end)()


return Leaderboards
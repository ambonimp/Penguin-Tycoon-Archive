local Players = game:GetService("Players")
local Leaderboards = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Variables ---
local LOOP_INTERVAL = 8 * 60

local MIN_VALUE = 0
local MAX_VALUE = 10e50

local MAX_LIST_SIZE = 3

local Usernames = {}

local LastRichestPlayer

local function LoadPenguinModel(UserId, Penguin)
	local s,m = pcall(function()
		local Success, Data = Modules.PlayerData.getData(UserId)
		if Success and Data then
			local PenguinInfo = Data["My Penguin"]
			Modules.Penguins:LoadPenguin(Penguin, PenguinInfo)
		end
	end)
end


function IsValueValid(Stat, Store)
	local Value = Store.value
	if Stat == "Skate Race Record" then
		if Value < Modules.EventsConfig["Skate Race"].FastestPossible*100 then
			return false
		end
	elseif Stat == "Sled Race" then
		if Value < 3000 then
			return false
		end
	end

	return true
end


task.spawn(function()
	local PlaceIds = Paths.Modules.PlaceIds
	for i,Island in pairs (workspace.MinigameIslands:GetChildren()) do
		local Teleport = Island:WaitForChild("Teleport"):WaitForChild("ProximityPrompt")

		Teleport:SetAttribute("TeleportId",PlaceIds[Island.Name])
	end

	while true do

		for i,Island in pairs (workspace.MinigameIslands:GetChildren()) do
			local Leaderboards = Island.Leaderboards:GetChildren()

			for i,Leaderboard in pairs (Leaderboards) do
				if Modules.LeaderboardDetails[Leaderboard.Name] then
					local Stat = Leaderboard.Name
					local Details = Modules.LeaderboardDetails[Leaderboard.Name]

					local DataStore = Services.DataStoreService:GetOrderedDataStore(Details.DataStore)


					local Pages
					local succ, err = pcall(function()
						Pages = DataStore:GetSortedAsync(Details.smallestFirst, 100, MIN_VALUE, MAX_VALUE)
					end)
					if not warn then warn("PAGES ISSUE", Stat, err) end

					if Pages then
						local Removed = 0

						local PageIndex = 0
						local Page = Pages:GetCurrentPage()

						-- Load players into playerlist
						for ListIndex = 1, MAX_LIST_SIZE do
							local Rank = ListIndex - Removed
							PageIndex += 1
							local Player = Page[PageIndex]
							if Player then
								local UserId = Player.key

								local UserName = Usernames[UserId]
								if not UserName then
									UserName = "Failed To Load"

									if pcall(function()
										UserName = game.Players:GetNameFromUserIdAsync(UserId)
									end) then
										Usernames[UserId] = UserName
									end
								end


								if Rank <= 3 and Rank >= 1 then
									local PenguinModel = Leaderboard["Penguin#" .. Rank]
									Leaderboard.Podiums["Penguin#" .. Rank].PlayerName.SurfaceGui.TextLabel.Text = UserName
									LoadPenguinModel(UserId, PenguinModel)
								end

								if ListIndex % 100 == 0 and not Pages.IsFinished then
									Pages:AdvanceToNextPageAsync()
									Page = Pages:GetCurrentPage()

									PageIndex = 0
								end

							end
						end
					end
				end
			end
			task.wait(10)
		end

		
		warn("LEADERBOARDS DONE UPDATING")
		task.wait(LOOP_INTERVAL)
	end

end)

task.spawn(function()
	while true do
		task.wait(60 * 60)
		Usernames = {}
	end

end)


return Leaderboards
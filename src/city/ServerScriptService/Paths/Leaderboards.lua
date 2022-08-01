local Players = game:GetService("Players")
local Leaderboards = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

--- Variables ---
local LOOP_INTERVAL = 8 * 60

local MIN_VALUE = 0
local MAX_VALUE = 10e50

local MAX_LIST_SIZE = 200

local Usernames = {}

local LastRichestPlayer

local function LoadPenguinModel(UserId, Penguin, Scale)
	coroutine.wrap(function()
		local Success, Data = Modules.PlayerData.getData(UserId)

		if Success and Data then
			local PenguinInfo = Data["My Penguin"]
			if Scale then
				Modules.Penguins:LoadPenguin(Penguin, PenguinInfo, "SCALE", Scale)
			else
				Modules.Penguins:LoadPenguin(Penguin, PenguinInfo)
			end
		end

	end)()
end

function ShowRichestInServer()
	local RichestPlayer
	local RichestNetworth = -1

	for _, Player in ipairs (game.Players:GetPlayers()) do
		local Leaderstats = Player:FindFirstChild("leaderstats")
		if Leaderstats then
			local Networth = Leaderstats:FindFirstChild("Networth")
			if Networth then
				Networth = Networth.Value
				if Networth > RichestNetworth then
					RichestNetworth = Networth
					RichestPlayer = Player
				end
			end

		end

	end

	if RichestPlayer and not (LastRichestPlayer and LastRichestPlayer.Name == RichestPlayer.Name) then
		if LastRichestPlayer then
			LastRichestPlayer:Destroy()
		end

		local Model = Services.SStorage.Leader:Clone()
		Model.Name = RichestPlayer.Name
		Model.Parent = workspace.KingPenguin

		LoadPenguinModel(RichestPlayer.UserId, Model, 8.45540498)

		Model:SetPrimaryPartCFrame(workspace.KingPenguin.CF.CFrame)
		workspace.KingPenguin.PlayerName.SurfaceGui.TextLabel.Text = RichestPlayer.Name

		LastRichestPlayer = Model

	end

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
	task.wait(8)
	while true do
		ShowRichestInServer()
		task.wait(20)
	end
end)

task.spawn(function()
	for Stat in pairs(Modules.LeaderboardDetails) do
		local PlayerList = Dependency.PlayerList:Clone()
		PlayerList.Parent = workspace.Leaderboards[Stat].Display.GUI

		for i = 1, MAX_LIST_SIZE do
			local Lbl = Dependency.PlayerTemplate:Clone()
			Lbl.LayoutOrder = i
			Lbl.Name = i
			Lbl.Visible = false
			Lbl.Parent = PlayerList
		end

	end

	while true do
		warn("LEADERBOARD UPDATE")
		Remotes.LeaderboardUpdated:FireAllClients()

		-- Update
		for Stat, Details in pairs(Modules.LeaderboardDetails) do
			local Leaderboard = workspace.Leaderboards[Stat]
			local DataStore = Services.DataStoreService:GetOrderedDataStore(Details.DataStore)

			for _, Player in ipairs(game.Players:GetPlayers()) do -- Loop through players
				local UserId = Player.UserId
				local Data = Modules.PlayerData.sessionData[Player.Name]

				if UserId > 0 and Data then --Prevent errors
					local PlrStat = Data["Stats"][Stat] or Data[Stat]

					if PlrStat then
						-- Filter
						if Stat == "Skate Race Record" then
							if PlrStat < Modules.EventsConfig["Skate Race"].FastestPossible * 100 then
								Data["Stats"][Stat] = 12000
							end
						elseif Stat == "Sled Race" then
							if PlrStat < 100 then -- I made a mistake and saved doubles, this should fix that.
								Data["Stats"][Stat] *= 100
							end
							if Data["Stats"][Stat] < 3000 then
								Data["Stats"][Stat] = 6000
							end
						end

						-- Leaderboards don't take doubles
						PlrStat = math.floor(Data["Stats"][Stat] or Data[Stat])
						pcall(function()
							return DataStore:SetAsync(Player.UserId, PlrStat)
						end)
					end

				end

			end

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

					local Lbl = Leaderboard.Display.GUI.PlayerList[Rank]
					local Player = Page[PageIndex]
					if Player then
						-- Don't display invalid values
						local Value = Player.value
						if not IsValueValid(Stat, Player) then
							Removed += 1
							continue
						end


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


						Lbl.Visible = true
						Lbl.Rank.Text = Rank .. "."
						Lbl.Value.Text = if Details.Format then Details.Format(Value) else Modules.Format.FormatAbbreviated(Value)
						Lbl.PlrName.Text = UserName

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

					else
						Lbl.Visible = false
					end

				end

				for i = 1, Removed do
					Leaderboard.Display.GUI.PlayerList[MAX_LIST_SIZE + 1 - i].Visible = false
				end

			end
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
local SkateRace = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Event Variables ---
local EVENT_NAME = script.Name

local WINNER_REWARDS = {15, 10, 5}
local PARTICIPATION_REWARD = 1


local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Config = Modules.EventsConfig[EVENT_NAME]

local Map, SpawnPoints




--- Event Functions ---
local function RewardGems(Player, Amount)
	Modules.Income:AddGems(Player,  Amount, EVENT_NAME)
end

local function RelayToParticipants(...)
	for _, PlayerName in ipairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerName.Name)
		if Player then
			Remotes.SledRace:FireClient(Player, ...)
		end
	end
end

local function SortPlayerPositions(Rankings)
	-- Sort position rankings
	table.sort(Rankings, function(a, b) return a.Position > b.Position end)
	for i, playerData in ipairs(Rankings) do
		playerData.Rank = i-- + #Winners
	end

	return Rankings
end

local function ToggleGemRewardUI(toggle)
	for i, v in pairs(Map.Winners.UIs:GetChildren()) do
		v.GemReward.Enabled = toggle
	end

end


function SkateRace:InitiateEvent(Event)
	Map = workspace.Event["Event Map"]
	SpawnPoints = Map.PlayerSpawns:GetChildren()

	EventValues.Timer.Value = Config.Duration
	EventValues.Timer:SetAttribute("Enabled", true)

	Remotes.Events:FireAllClients("Initiate Event", Event)
end

function SkateRace:SpawnPlayers(ChosenBugName, ChosenBugNum)
	for i, Participant in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Participant.Name)
		local SpawnPos = SpawnPoints[i].CFrame * CFrame.new(0, 3, 0)

		if Player then
			Remotes.Lighting:FireClient(Player, "Skate Race")

			local Character = Modules.Character:Spawn(Player, SpawnPos)
			Character.Humanoid.JumpPower = 0
			Character.Humanoid.WalkSpeed = 0

			Modules.Collisions.SetCollision(Character, false)

			Character.Humanoid.Died:Connect(function()
				Participant:Destroy()
			end)

			Player:SetAttribute("Minigame","Skate Race")
		end

	end

end

function SkateRace:StartEvent()
	local StartTime = tick()
	local TimeLeft = Config.Duration

	local Laps = {}
	local CompletedRace = {}
	local Rankings = {}


	-- Give speed back to players
	for _, Participant in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Participant.Name)
		if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.WalkSpeed = 35
		end
	end

	-- Activate Event
	local Active = true

	Remotes.Events:FireAllClients("Event Started")
	EventValues.TextToDisplay.Value = "RACE!!"
	task.wait(1)


	-- Setup things
	local WaypointsTouched = {}
	local WaypointPositions = {}
	for _, Waypoint in pairs(Map.Waypoints:GetChildren()) do
		WaypointPositions[tonumber(Waypoint.Name)] = Waypoint.Position
	end

	-- Detect progress (Waypoints)
	task.spawn(function()
		while Active do
			Rankings = {}
			for index, Participant in pairs(Participants:GetChildren()) do
				local Player = game.Players:FindFirstChild(Participant.Name)

				if Player then
					local Hrp = Player.Character.HumanoidRootPart

					if not WaypointsTouched[Player] then WaypointsTouched[Player] = {} end

					local PlayerPosition = Hrp.Position

					local LastWaypoint, LastWaypointDistance = Map.Waypoints["1"], math.huge
					local NextWaypoint, NextWaypointDistance = false, math.huge


					-- Get last waypoint
					for Waypoint, Position in pairs(WaypointPositions) do
						local Distance = math.abs((PlayerPosition - Position).Magnitude)
						if Distance < LastWaypointDistance then
							LastWaypoint = Map.Waypoints[Waypoint]
							LastWaypointDistance = Distance
						end

					end

					local Next = tonumber(LastWaypoint.Name) + 1
					if WaypointPositions[LastWaypoint.Name + 1] then
						NextWaypoint = Map.Waypoints[Next]
						NextWaypointDistance = (PlayerPosition - WaypointPositions[Next]).Magnitude
					end

					-- Player is being LastWaypoint
					local Last = tonumber(LastWaypoint.Name) - 1
					if WaypointPositions[Last] then
						if (PlayerPosition - WaypointPositions[Last]).Magnitude < NextWaypointDistance then
							NextWaypoint = LastWaypoint
							NextWaypointDistance = (PlayerPosition - NextWaypoint.Position).Magnitude

							LastWaypoint = Map.Waypoints[Last]
							LastWaypointDistance = (PlayerPosition - LastWaypoint.Position).Magnitude
						end
					else
						if #WaypointsTouched[Player] >= 40 then NextWaypoint = Map.Waypoints["47"] end
					end

					if tonumber(LastWaypoint.Name) > 5 and tonumber(LastWaypoint.Name)/2 > #WaypointsTouched[Player] then
						LastWaypoint = Map.Waypoints["1"]
					end


					-- Set
					local PlayerLap = Laps[Player]
					if not PlayerLap then
						Laps[Player] = 1
						PlayerLap = 1
					end

					Rankings[index] = {
						Player = Player,
						Position = PlayerLap * 10000 + (LastWaypoint.Name * 100) + LastWaypointDistance,
						Lap = PlayerLap
					}

					-- Set the waypoint as touched by the player so they're able to complete the lap
					if not WaypointsTouched[Player][tonumber(LastWaypoint.Name)] then
						WaypointsTouched[Player][tonumber(LastWaypoint.Name)] = true
					end

				end

			end

			-- Update race leaderboard live
			SortPlayerPositions(Rankings)
			Remotes.Events:FireAllClients("Update Event", Rankings)

			task.wait(0.2)
		end
	end)

	-- Laps / Finishing
	local TouchDb = {}

	Map.LapHitbox.Touched:Connect(function(Part)
		local Character = Part.Parent
		local Player = game.Players:GetPlayerFromCharacter(Character)

		if Part.Name == "HumanoidRootPart" and Part.Parent:FindFirstChild("Humanoid") and Player and not TouchDb[Character] then
			TouchDb[Character] = true

			if not WaypointsTouched[Player] then
				WaypointsTouched[Player] = {}
			end

			-- If they have touched all the waypoints (minus a few for lag or anomalies)
			if #WaypointsTouched[Player] >= 44 then -- Total waypoints 47
				-- Player has finished the race
				if Laps[Player] == Modules.EventsConfig["Skate Race"].Laps then
					local Time = Config.Duration - TimeLeft

					-- Mini anti exploit
					if Time < Modules.EventsConfig["Skate Race"].FastestPossible then
						Player:Kick("Potential Lag Issues")
						Laps[Player] = nil
						WaypointsTouched[Player] = nil

					else
						local PlayerName = Player.Name
						local Ranking = #CompletedRace + 1

						-- Scoreboard
						CompletedRace[Ranking] = {
							PlayerName = PlayerName,
							Score = Time
						}

						-- Record setting
						local Data = Modules.PlayerData.sessionData[PlayerName]
						if Data then
							local StatTime = math.floor(Time * 100) / 100
							local Record =  Data["Stats"]["Skate Race Record"]
							if Record then
								if Record > StatTime then
									Data["Stats"]["Skate Race Record"] = StatTime
								end
							else
								Data["Stats"]["Skate Race Record"] = StatTime
							end

						end

					end

					Character.Humanoid.WalkSpeed = 0

				end

				Laps[Player] += 1 -- Add a lap (even if they finished so it can be used to check winners in live rankings)
				WaypointsTouched[Player] = nil

			end

			task.wait(1)
			TouchDb[Character] = nil
		end

	end)



	-- Start the event
	EventValues.TextToDisplay.Value = "Reach the finish line"
	repeat
		TimeLeft -= task.wait()
		EventValues.Timer.Value = math.floor(TimeLeft)
	until #Participants:GetChildren() <= #CompletedRace or TimeLeft <= 0

	Active = false

	local Winners = {}
	for i, Ranked in ipairs(CompletedRace) do
		local PlayerName = Ranked.PlayerName
		local Player = game.Players:FindFirstChild(PlayerName)

		if Player then
			if i <= 3 then
				if i == 1 then
					Modules.Quests.GiveQuest(Player, "Win", "Minigame", "Skate Race", 1)
					Modules.Quests.GiveQuest(Player, "Win"," Minigame", "All", 1)

					local Stats = Modules.PlayerData.sessionData[PlayerName].Stats
					if Stats["Skate Race Wins"] then
						warn("COOL")
						Stats["Skate Race Wins"] += 1
					else
						warn("NICE")
						Stats["Skate Race Wins"] = 1
					end

				end

				table.insert(Winners, PlayerName)

				-- Put character on pedestal
				local Character = Modules.Character:MoveTo(Player, Map.Winners["Spawn".. i].CFrame)
				if Character:FindFirstChild("HumanoidRootPart") then
					Character.Humanoid.WalkSpeed = 0
				end

				RewardGems(Player, WINNER_REWARDS[i])

			else
				RewardGems(Player, PARTICIPATION_REWARD)

			end

		end
	end

	if #Winners > 0 then
		for _, Participant in ipairs(Participants:GetChildren()) do
			local Player = game.Players:FindFirstChild(Participant.Name)
			Remotes.SkateRace:FireClient(Player, "Finished", CompletedRace, Map.Winners.CameraAngle.CFrame)
		end

		ToggleGemRewardUI(true)
		task.delay(10, ToggleGemRewardUI, false)

		return Winners
	else
		return nil
	end

end

return SkateRace
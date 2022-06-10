local SkateRace = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local EVENT_NAME = script.Name

local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Config = Modules.EventsConfig[EVENT_NAME]




--- Event Functions ---
local function SortPlayerPositions(Rankings, Winners)
	-- Sort position rankings
	table.sort(Rankings, function(a, b) return a.Position > b.Position end)

	for i, playerData in ipairs(Rankings) do
		playerData.Rank = i-- + #Winners
	end
	
	-- Sort winner rankings
	table.sort(Winners, function(a, b) return a.Time < b.Time end)

	for i, playerData in ipairs(Rankings) do
		for winnerIndex, winnerData in ipairs(Winners) do
			if winnerData.Player == playerData.Player then
				playerData.Rank = winnerIndex
				playerData.Time = winnerData.Time
			end
		end
	end
	
	return Rankings
end

function SkateRace:SpawnPlayers(ChosenBugName, ChosenBugNum)
	local Map = workspace.Event["Event Map"]
	local Spawns = Map.Spawns
	
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		local SpawnPos = Spawns["Spawn"..index].CFrame * CFrame.new(0, 3, 0)
		
		if player then
			Remotes.Lighting:FireClient(player, "Skate Race")
			
			local Character = Modules.Character:Spawn(player, SpawnPos)
			Character.Humanoid.JumpPower = 0
			Character.Humanoid.WalkSpeed = 0
			
			Modules.Collisions.SetCollision(Character, false)
			
			Character.Humanoid.Died:Connect(function()
				playerName:Destroy()
			end)

			player:SetAttribute("Minigame","Skate Race")

		end

	end

end

function SkateRace:InitiateEvent(Event)
	EventValues.Timer.Value = Config.Duration
	EventValues.Timer:SetAttribute("Enabled", true)

	Remotes.Events:FireAllClients("Initiate Event", Event)
end

function SkateRace:StartEvent()
	local Map = workspace.Event["Event Map"]
	
	-- Activate Event
	Map.Active.Value = true
	
	
	-- Give speed back to players
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 35
		end
	end

	Remotes.Events:FireAllClients("Event Started")
	
	local StartTime = tick()
	local FinishTime = StartTime + Modules.EventsConfig["Skate Race"].Duration
	
	
	EventValues.TextToDisplay.Value = "RACE!!"
	wait(1)


	-- Setup things
	
	local WaypointPositions = {}
	for i, Waypoint in pairs(Map.Waypoints:GetChildren()) do
		WaypointPositions[tonumber(Waypoint.Name)] = Waypoint.Position
	end

	local PlayerLaps = {}
	local Winners = {}
	local Rankings = {}
	
	
	-- Setup Lap Touchpart
	local WaypointsTouched = {}
	local TouchDb = {}
	
	Map.LapHitbox.Touched:Connect(function(Part)
		if Part.Name == "HumanoidRootPart" and Part.Parent:FindFirstChild("Humanoid") and game.Players:FindFirstChild(Part.Parent.Name) and not TouchDb[Part.Parent] then
			TouchDb[Part] = true
			
			local player = game.Players[Part.Parent.Name]
			local character = Part.Parent
			
			if not WaypointsTouched[player] then WaypointsTouched[player] = {} end
			
			-- If they have touched all the waypoints (minus a few for lag or anomalies)
			if #WaypointsTouched[player] >= 44 then -- Total waypoints 47
				if not PlayerLaps[player] then PlayerLaps[player] = 1 end
				
				if PlayerLaps[player] == Modules.EventsConfig["Skate Race"].Laps then
				-- Player has finished the race
					local PlayerTime = math.floor((tick() - StartTime) * 100)/100
					
					-- mini anti exploit
					
					local data = Modules.PlayerData.sessionData[player.Name] 
					if data then
						local PlayerTime = PlayerTime * 100
						if (not data["Stats"]["Skate Race Record"]) or (data["Stats"]["Skate Race Record"] and data["Stats"]["Skate Race Record"] > PlayerTime and PlayerTime > Modules.EventsConfig["Skate Race"].FastestPossible) then
							data["Stats"]["Skate Race Record"] = math.floor(PlayerTime)
						end
					end
					
					if PlayerTime < Modules.EventsConfig["Skate Race"].FastestPossible then 
						player:Kick("Potential Lag Issues") 
						PlayerLaps[player] = nil 
						WaypointsTouched[player] = nil 
						
					else
						Winners[#Winners+1] = {Player = player, Time = PlayerTime}
					end
					
					PlayerLaps[player] += 1 -- Add a lap (even if they finished so it can be used to check winners in live rankings)
					
					character.Humanoid.WalkSpeed = 0
					
				elseif PlayerLaps[player] < Modules.EventsConfig["Skate Race"].Laps then
				-- Next lap
					PlayerLaps[player] += 1 
					
				end

				WaypointsTouched[player] = nil
			end
			
			task.wait(1)
			TouchDb[Part] = nil
		end
	end)
	
	local lastUpdated = tick()
	
	-- Start the event
	EventValues.TextToDisplay.Value = "Reach the finish line"
	repeat
		task.wait()
		
		local TimeLeft = math.floor((FinishTime - tick())*10)/10
		EventValues.Timer.Value = TimeLeft

		if not string.match(tostring(TimeLeft), "%.") then
			TimeLeft = tostring(TimeLeft)..".0"

		--elseif string.len(string.split(tostring(TimeLeft), ".")[2]) == 1 then -- for .00 second intervals rather than .0
		--	TimeLeft = tostring(TimeLeft).."0"
		end
		
		for i = 1, select(2, tostring(TimeLeft):gsub("1", "")), 1 do
			TimeLeft = tostring(TimeLeft).." "
		end
		
		
		if tick() > lastUpdated + 0.2 then
			lastUpdated = tick()
			
			-- Update race leaderboard live
			Rankings = {}
			
			for index, Participant in pairs(Participants:GetChildren()) do
				local player = game.Players:FindFirstChild(Participant.Name)
				
				if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					if not WaypointsTouched[player] then WaypointsTouched[player] = {} end
					
					local PlayerPosition = player.Character.HumanoidRootPart.Position
					
					local Waypoint1, Waypoint1Distance = Map.Waypoints["1"], 1000
					local Waypoint2, Waypoint2Distance = false, 1000
					
					for Waypoint, Position in pairs(WaypointPositions) do
						local Distance = math.abs((PlayerPosition - Position).magnitude)

						if Distance < Waypoint1Distance then
							Waypoint1 = Map.Waypoints[Waypoint]
							Waypoint1Distance = Distance
						end
					end
					
					if WaypointPositions[Waypoint1.Name + 1] then
						Waypoint2 = Map.Waypoints[Waypoint1.Name + 1]
						Waypoint2Distance = math.abs((PlayerPosition - WaypointPositions[Waypoint1.Name + 1]).magnitude)
					end
					
					if WaypointPositions[Waypoint1.Name - 1] then
						if math.abs((PlayerPosition - WaypointPositions[Waypoint1.Name - 1]).magnitude) < Waypoint2Distance then
							Waypoint2 = Waypoint1
							Waypoint2Distance = math.abs((PlayerPosition - Waypoint2.Position).magnitude)
							
							Waypoint1 = Map.Waypoints[Waypoint1.Name - 1]
							Waypoint1Distance = math.abs((PlayerPosition - Waypoint1.Position).magnitude)
						end
					else
						
						if #WaypointsTouched[player] >= 40 then Waypoint2 = Map.Waypoints["47"] end
					end
					
					if tonumber(Waypoint1.Name) > 5 and tonumber(Waypoint1.Name)/2 > #WaypointsTouched[player] then
						Waypoint1 = Map.Waypoints["1"]
					end
					
					local WaypointPosition = (Waypoint1.Name * 100) + Waypoint1Distance
					local PlayerLap = PlayerLaps[player] or 1
					
					Rankings[index] = {Player = player, Position = PlayerLap * 10000 + WaypointPosition, Lap = PlayerLap}
					--print(player.DisplayName, "Total Distance:", PlayerLap * 10000 + WaypointPosition, "Waypoints:", Waypoint1, Waypoint2, Waypoint2Distance)
					
					-- Set the waypoint as touched by the player so they're able to complete the lap
					if not WaypointsTouched[player][tonumber(Waypoint1.Name)] then
						WaypointsTouched[player][tonumber(Waypoint1.Name)] = true
					end
				end
			end
			
			SortPlayerPositions(Rankings, Winners)
			Remotes.Events:FireAllClients("Update Event", Rankings)
		end
		
	until #Participants:GetChildren() == 0 or #Participants:GetChildren() == #Winners or tick() > FinishTime

	SortPlayerPositions(Rankings, Winners)
	Remotes.Events:FireAllClients("Update Event", Rankings)
	
	if #Winners > 0 then
		local Top3 = {"", "", ""}
		
		for i, playerInfo in pairs(Rankings) do
			if playerInfo.Rank <= 3 then
				Top3[playerInfo.Rank] = playerInfo.Player.Name
				
				local Character = Modules.Character:MoveTo(playerInfo.Player, Map.Winners["Spawn"..playerInfo.Rank].CFrame)
				
				if Character:FindFirstChild("HumanoidRootPart") then
					Character.Humanoid.WalkSpeed = 0
				end
				
				if playerInfo.Rank == 1 and #Winners >= 2 then
					Modules.Quests.GiveQuest(playerInfo.Player,"Win","Minigame","Skate Race",1)
					Modules.Quests.GiveQuest(playerInfo.Player,"Win","Minigame","All",1)
					Modules.Income:AddGems(playerInfo.Player, 15, "Skate Race")
				elseif playerInfo.Rank == 2 then
					Modules.Income:AddGems(playerInfo.Player, 10, "Skate Race")
				elseif playerInfo.Rank == 3 then
					Modules.Income:AddGems(playerInfo.Player, 5, "Skate Race")
				end
			else
				Modules.Income:AddGems(playerInfo.Player, 1, "Skate Race")
			end

		end
		
		for i, Participant in pairs(Participants:GetChildren()) do
			local player = game.Players:FindFirstChild(Participant.Name)
			if player then
				Remotes.Events:FireClient(player, "Skate Race Winners Camera", Map.Winners.CameraAngle.CFrame,Rankings)
			end
		end
		
		for i, v in pairs(Map.Winners.UIs:GetChildren()) do
			v.GemReward.Enabled = true
		end
		
		local WinnerText = "#1 - "..Top3[1]..", #2 - "..Top3[2]..", #3 - "..Top3[3]
		
		return Top3, WinnerText
	end

	return false
end

return SkateRace
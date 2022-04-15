local Events = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local previousEvent = nil
local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

local EventModules = {}
for i, v in pairs(script:GetChildren()) do
	EventModules[v.Name] = require(v)
end



--- Variables ---
Events.CurrentState = "Intermission"
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local TotalVotes = Services.RStorage.Modules.EventsConfig.Votes
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local AllEvents = require(Services.RStorage.Modules.EventsConfig).Events

local ChosenEvent = nil
local PlayerVotes = {}



--- Functions ---
local function ResetEvent()
	EventValues.CurrentEvent.Value = "None"
	Participants:ClearAllChildren()
	workspace.Event:ClearAllChildren()
	ChosenEvent = nil
	PlayerVotes = {}
	Voted = {}
	for i, v in pairs(TotalVotes:GetChildren()) do
		v.Value = 0
	end
	for i,value in pairs (EventValues.Voting:GetChildren()) do
		value.Value = 0
	end
end


local function Intermission()
	Events.CurrentState = "Intermission"
	for i = Modules.EventsConfig.INTERMISSION_INTERVAL, 0, -1 do
		EventValues.TextToDisplay.Value = "Intermission: "..i
		wait(1)
	end
end


local function ChooseEvents()
	
	local AllEvents = {}
	for i, v in pairs(Modules.EventsConfig.Events) do table.insert(AllEvents, v) end
	if previousEvent and table.find(AllEvents,previousEvent) then
		table.remove(AllEvents,table.find(AllEvents,previousEvent))
	end
	local Options = {}
	for i = 1, 3, 1 do
		local Num = Random.new():NextInteger(1, #AllEvents)
		local Choice = AllEvents[Num]
		table.remove(AllEvents, Num)
		Options["Option"..i] = Choice
	end
	Voted = {
		["Option1"] = {},
		["Option2"] = {},
		["Option3"] = {},
	}
	
	return Options
end


local function InitiateVoting(Options)
	Events.CurrentState = "Voting"
	Remotes.Events:FireAllClients("Voting", Options)

	for i = Modules.EventsConfig.VOTE_TIMER, 0, -0.1 do
		EventValues.StartingTimer.Value = math.floor(i)
		EventValues.TextToDisplay.Value = "Voting! ("..math.floor(i)..")"
		task.wait(0.1)
	end
end


local function GetChosenEvent(Options)
	local HighestNum = 0
	local ChosenOption = false
	for i,value in pairs (EventValues.Voting:GetChildren()) do
		TotalVotes:FindFirstChild(value.Name).Value = value.Value
	end
	for i, v in pairs(TotalVotes:GetChildren()) do
		if v.Value >= HighestNum then
			HighestNum = v.Value
			ChosenOption = v.Name
		end
	end
	for i = 1,Modules.EventsConfig[Options[ChosenOption]].MaxPlayers do
		local x = Voted[ChosenOption][i]
		if x then
			local Value = Instance.new("StringValue")
			Value.Name = x
			Value.Parent = Participants
		end
	end
	return Options[ChosenOption]
end


local function SendInvites(ChosenEvent)
	Events.CurrentState = "Starting"
	Remotes.Events:FireAllClients("Event Prompt", ChosenEvent)

	for i = Modules.EventsConfig.ACCEPT_TIMER, 0, -0.1 do
		EventValues.StartingTimer.Value = math.floor(i)
		EventValues.TextToDisplay.Value = "Accept to join! ("..math.floor(i)..")".." - "..#Participants:GetChildren().."/"..Modules.EventsConfig[ChosenEvent].MaxPlayers.." Player(s)"
		task.wait(0.1)
	end
end


local function StartingCountdown(ChosenEvent)
	Events.CurrentState = "Countdown"

	-- Insert Event Map
	local Map = Services.SStorage.EventMaps[ChosenEvent]:Clone()
	Map.Name = "Event Map"
	Map.Parent = workspace.Event
	for index, playerName in pairs(Participants:GetChildren()) do
		local player = game.Players:FindFirstChild(playerName.Name)
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player:SetAttribute("Minigame",ChosenEvent)
		end
	end
	-- Initiate Event
	EventModules[ChosenEvent]:InitiateEvent(ChosenEvent)

	-- Spawn Players in
	EventModules[ChosenEvent]:SpawnPlayers()

	-- Starting Counter
	for i = 3, 1, -1 do
		EventValues.TextToDisplay.Value = "Starting in: "..i

		if #Participants:GetChildren() <= 0 then
			break
		end
		task.wait(1)
	end
end


local function StartEvent(ChosenEvent)
	local Winners = false
	local DisplayText = false

	if #Participants:GetChildren() >= Modules.EventsConfig[ChosenEvent].MinPlayers then
		-- Start the event
		Events.CurrentState = "Started"
		
		for _, participant in pairs(Participants:GetChildren()) do
			-- Fires a bindable event to notify server that this event has occured with given data
			-- Used normally to integrate with Game Analytics / Dive / Playfab
			local player = game.Players:FindFirstChild(participant.Name)
			local success, msg = pcall(function()
				EventHandler:Fire("minigameStart", player, {
					minigame = ChosenEvent
				})
			end)
		end	
		
		-- Start it
		Winners, DisplayText = EventModules[ChosenEvent]:StartEvent(ChosenEvent)
	end
	
	return Winners, DisplayText
end

local pEvent = 2
local function EventLoop()
	while true do
		-- Reset Previous Event Completely
		ResetEvent()
		
		
		-- Intermission
		Intermission()
		--Voting:
		
		-- Choose 3 Events to vote from
		local Options = ChooseEvents()
		

		-- Initiate voting for everyone
		InitiateVoting(Options)
		
		
		-- Get chosen event
		ChosenEvent = GetChosenEvent(Options)--]]

		--random event
		--[[pEvent = pEvent + 1
		local nextEvent = AllEvents[pEvent]
		if nextEvent == nil then
			pEvent = 1
			nextEvent = AllEvents[pEvent]
		end
		
		ChosenEvent = nextEvent--]]
		previousEvent = ChosenEvent
		
		EventValues.CurrentEvent.Value = ChosenEvent
		

		-- Invite all players to join
		SendInvites(ChosenEvent)
		

		-- Start the event if the min amount of players is met
		if #Participants:GetChildren() >= Modules.EventsConfig[ChosenEvent].MinPlayers and #Participants:GetChildren() <= Modules.EventsConfig[ChosenEvent].MaxPlayers then
			workspace:SetAttribute("Minigame",true)
			StartingCountdown(ChosenEvent)
			
			local Winners, DisplayText = StartEvent(ChosenEvent)
			
			if Winners then
				for _, winner in pairs(Winners) do
					-- Fires a bindable event to notify server that this event has occured with given data
					-- Used normally to integrate with Game Analytics / Dive / Playfab
					local player = game.Players:FindFirstChild(winner)
					local success, msg = pcall(function()
						EventHandler:Fire("minigameWon", player, {
							minigame = ChosenEvent
						})
					end)
				end	
				
				local WinnersText = ""
				for i, v in pairs(Winners) do
					if i == #Winners then
						WinnersText = WinnersText..v
					else
						WinnersText = WinnersText..v..", "
					end
				end

				if DisplayText then
					EventValues.TextToDisplay.Value = DisplayText
				else
					EventValues.TextToDisplay.Value = "Winner(s): "..WinnersText.."!"
				end

				wait(2) -- Give time to flex n stuff
			elseif DisplayText then
				EventValues.TextToDisplay.Value = DisplayText
			else
				EventValues.TextToDisplay.Value = "Nobody Wins!"
			end
			
			if ChosenEvent == "Soccer" then
				wait(4)
			else
				wait(2)
			end
			
			Remotes.Events:FireAllClients("Event Ended",ChosenEvent)
			for i,player in pairs (game.Players:GetPlayers()) do
				player:SetAttribute("Minigame","none")
			end
			-- End the event
			workspace:SetAttribute("Minigame",false)
			for index, playerName in pairs(Participants:GetChildren()) do
				local player = game.Players:FindFirstChild(playerName.Name)
				Modules.Character:Spawn(player)
			end
			

		end
	end
end

-- Players accepting - joining the event (only while it's starting)
Remotes.Events.OnServerEvent:Connect(function(player, task, info)
	if task == "Voting" and Events.CurrentState == "Voting" then
		if PlayerVotes[player] then
			EventValues.Voting[PlayerVotes[player]].Value -= 1
			table.remove(Voted[PlayerVotes[player]],table.find(Voted[PlayerVotes[player]],player.Name))
			if info ~= PlayerVotes[player] then
				EventValues.Voting[info].Value += 1
				PlayerVotes[player] = info
				table.insert(Voted[info],player.Name)
			else
				PlayerVotes[player] = nil
			end
		else
			EventValues.Voting[info].Value += 1
			PlayerVotes[player] = info
			table.insert(Voted[info],player.Name)
		end

	elseif task == "Accept Prompt" and Events.CurrentState == "Starting" and not Participants:FindFirstChild(player.Name) and #Participants:GetChildren() < Modules.EventsConfig[ChosenEvent].MaxPlayers then
		local Value = Instance.new("StringValue")
		Value.Name = player.Name
		Value.Parent = Participants

	elseif task == "Exit Event" and Participants:FindFirstChild(player.Name) then
		Participants[player.Name]:Destroy()
		if Events.CurrentState == "Started" or Events.CurrentState == "Countdown" then
			Modules.Character:Spawn(player)
		end
	end
end)

-- If player leaves and is in the participants, remove them
game.Players.PlayerRemoving:Connect(function(player)
	if Participants:FindFirstChild(player.Name) then
		Participants[player.Name]:Destroy()
	end
end)

coroutine.wrap(function()
	EventLoop()
end)()

return Events
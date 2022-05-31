local Events = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local Players = game:GetService("Players")
local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

--- Variables ---
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local EventValues = Services.RStorage.Modules.EventsConfig.Values

local ChosenEvent = Modules.EventsConfig.Names[game.PlaceId]
local EventModule = require(script:FindFirstChild(ChosenEvent))
local EventConfig = Modules.EventsConfig[ChosenEvent]

local Map


--- Functions ---
local function Intermission()
	for i = Modules.EventsConfig.INTERMISSION_INTERVAL, 0, -1 do
		EventValues.TextToDisplay.Value = "Intermission: "..i
		task.wait(1)
	end
end

local function WaitForPlayers()
	local PlayerReq = EventConfig.MinPlayers
	local Ready = #Players:GetPlayers() >= PlayerReq

	if not Ready then
		local function UpdateWait()
			local PlayerCount = #Players:GetPlayers()
			if PlayerCount < PlayerReq then
				EventValues.TextToDisplay.Value = string.format("Waiting for %s more player(s)", PlayerReq - PlayerCount)
			else
				Ready = true
			end
		end

		local Conn1, Conn2
		Conn1 = Players.PlayerAdded:Connect(function()
			UpdateWait()
		end)
		Conn2 = Players.PlayerRemoving:Connect(function()
			UpdateWait()
		end)

		UpdateWait()
		repeat
			task.wait(1)
		until Ready

		Conn1:Disconnect()
		Conn2:Disconnect()

	end

end

local function StartingCountdown(ChosenEvent)
	for _, Value in pairs(Participants:GetChildren()) do
		local Player = game.Players:FindFirstChild(Value.Name)
		if Player and Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player:SetAttribute("Minigame", ChosenEvent)
		else
			Value:Destroy()
		end

	end

	-- Initiate Event
	local s, m = pcall(function()
		EventModule:InitiateEvent(ChosenEvent)
	end)

	if not s then
		warn(m)
	end

	-- Spawn Players in
	EventModule:SpawnPlayers()

	-- Starting Counter
	for i = 3, 1, -1 do
		EventValues.TextToDisplay.Value = "Starting in: "..i

		if #Participants:GetChildren() < EventConfig.MinPlayers then
			return false
		end

		task.wait(1)
	end

	return true
end


local function StartEvent()
	local Winners = false
	local DisplayText = false

	if #Participants:GetChildren() >= EventConfig.MinPlayers then
		-- Start the event

		for _, participant in pairs(Participants:GetChildren()) do
			-- Fires a bindable event to notify server that this event has occured with given data
			-- Used normally to integrate with Game Analytics / Dive / Playfab
			local player = game.Players:FindFirstChild(participant.Name)
			local s, m = pcall(function()
				EventHandler:Fire("minigameStart", player, {
					minigame = ChosenEvent
				})
			end)

		end

		-- Start it
		Winners, DisplayText = EventModule:StartEvent(ChosenEvent)

	end

	return Winners, DisplayText

end

local function EventLoop()
	while true do
		-- Wait for players
		WaitForPlayers()

		-- Intermission
		Intermission()

		EventValues.CurrentEvent.Value = ChosenEvent

		-- Get participants
		for _, Player in ipairs(Players:GetPlayers()) do
			local Value = Instance.new("StringValue")
			Value.Name = Player.Name
			Value.Parent = Participants
		end

		-- Start the event if the min amount of players is met
		if #Participants:GetChildren() >= EventConfig.MinPlayers and #Participants:GetChildren() <= EventConfig.MaxPlayers then
			workspace:SetAttribute("Minigame", true)
			local Winners, DisplayText

			if StartingCountdown(ChosenEvent) then
				-- Player did not leave mid countdown and you still have enough participants  to play the match
				local s,m = pcall(function()
					Winners, DisplayText = StartEvent()
				end)

				if s == false then
					warn(m)
				end

			end

			local s,m = pcall(function()
				if Winners then
					for _, winner in pairs(Winners) do
						-- Fires a bindable event to notify server that this event has occured with given data
						-- Used normally to integrate with Game Analytics / Dive / Playfab
						local player = game.Players:FindFirstChild(winner)
						local s, m = pcall(function()
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

					task.wait(2) -- Give time to flex n stuff
				elseif DisplayText then
					EventValues.TextToDisplay.Value = DisplayText
				else
					EventValues.TextToDisplay.Value = "Nobody Wins!"
				end

				if ChosenEvent == "Soccer" then
					task.wait(4)
				else
					task.wait(2)
				end

				-- End event
				EventValues.CurrentEvent.Value = "None"
				workspace:SetAttribute("Minigame",false)

				for _, Player in pairs (game.Players:GetPlayers()) do
					Player:SetAttribute("Minigame","none")

					-- Back to lobby
					local Partipated = Participants:FindFirstChild(Player.Name)
					if Partipated then
						Modules.Character:Spawn(Player)
					end

				end

				Participants:ClearAllChildren()

				Remotes.Events:FireAllClients("Event Ended")

			end)

			if s == false then
				warn(m)
			end

		end

	end

end

-- If player leaves and is in the participants, remove them
game.Players.PlayerRemoving:Connect(function(player)
	if Participants:FindFirstChild(player.Name) then
		Participants[player.Name]:Destroy()
	end
end)

-- coroutine.wrap(function()
task.spawn(function()
	-- Load map
	Map = Services.SStorage.EventMaps[ChosenEvent]:Clone()
	Map.Name = "Event Map"
	Map.Parent = workspace.Event

	-- Position spectator's box above map
	local SpectatorBox = workspace.SpectatorBox
	-- Get spawn offsets from box, then use offsets to get new positions  relative to box's new position above map
	local Offsets = {}
	for _, SpawnLocation in ipairs(workspace.Spawns:GetChildren()) do
		Offsets[SpawnLocation] = SpectatorBox.PrimaryPart.CFrame:ToObjectSpace(SpawnLocation.CFrame)
	end
	-- Move
	local NewCFrame = Map.SpectatorBox.CFrame
	SpectatorBox:SetPrimaryPartCFrame(NewCFrame)

	for BasePart, Offset in pairs(Offsets) do
		BasePart.CFrame = NewCFrame:ToWorldSpace(Offset)
	end

	-- Start loop
	EventLoop()

end)

return Events
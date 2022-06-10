local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GroupReward = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local funcLib = Paths.Modules.FuncLib

local PlaceIds =  require(Services.RStorage.Modules.PlaceIds)

local ChosenEvent = Modules.EventsConfig.Names[game.PlaceId]
local EventModule = require(script[ChosenEvent])


local announcementRemote = Remotes:WaitForChild("Announcement")


--- Events Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants

local EventInfoUI = Paths.UI.Top.EventInfo

local StartingTextOn = false

local Player = Players.LocalPlayer


--- Events UI Functions ---
local function ChangeTimerText(Remainder)
	EventInfoUI.Timer.Time.Text = string.format("%02i:%02i", Remainder/60%60, Remainder%60)
end

local function ChangeDisplayText(Text)
	if workspace:GetAttribute("Minigame") and not Participants:FindFirstChild(Player.Name) then
		Text = "Minigame in progress"
	end

	EventInfoUI.TextToDisplay.Text = Text

	if Text == "Starting in: 3" then
		Paths.Audio.Countdown:Play()
	end

	if string.match(Text, "Starting in") then-- or Text == "GO!!" then
		if Participants:FindFirstChild(Paths.Player.Name) then
			if not StartingTextOn then
				StartingTextOn = true
				EventInfoUI.ExitEvent.Visible = false
				EventInfoUI.TextToDisplay:TweenSizeAndPosition(UDim2.new(1, 0, 0.7, 0), UDim2.new(0, 0, 1, 0), "In", "Quart", 0.5, true)
			end

		end

	else
		if StartingTextOn then
			StartingTextOn = false

			if EventValues.Timer:GetAttribute("Enabled") then
				EventInfoUI.Timer.Visible = true
			end

			EventInfoUI.TextToDisplay:TweenSizeAndPosition(UDim2.new(1, 0, 0.35, 0), UDim2.new(0, 0, 0, 0), "In", "Quart", 0.5, true)

		end
	end

end

local function JoinedEvent(Participant)
	if Participant.Name ~= Paths.Player.Name then return end

	EventInfoUI.ExitEvent.Visible = false

	Paths.UI.Left.GemDisplay.Visible = false
	Paths.UI.Left.Buttons.Visible = false

	Paths.UI.Bottom.Visible = false
	Paths.UI.BLCorner.Visible = false

end

local function LeftEvent()
	EventInfoUI.ExitEvent.Visible = true
	EventInfoUI.Timer.Visible = false

	Paths.UI.Left.GemDisplay.Visible = true
	Paths.UI.Left.Buttons.Visible = true

	Paths.UI.Bottom.Visible = true
	Paths.UI.BLCorner.Visible = true
	

	for _, v in pairs(Paths.UI.Left.EventUIs:GetChildren()) do
		v.Visible = false
	end

	for _, v in pairs(Paths.UI.Right.EventUIs:GetChildren()) do
		v.Visible = false
	end
end



--- Connecting Functions ---
ChangeTimerText(EventValues.Timer.Value)
EventValues.Timer.Changed:Connect(ChangeTimerText)

ChangeDisplayText(EventValues.TextToDisplay.Value)
EventValues.TextToDisplay.Changed:Connect(ChangeDisplayText)

for _, Participant in ipairs(Participants:GetChildren()) do
	JoinedEvent(Participant)
end
Participants.ChildAdded:Connect(JoinedEvent)
Participants.ChildRemoved:Connect(function(Participant)
	if Participant.Name == Paths.Player.Name then
		local handler = EventModule.LeftEvent -- By dying or reseting
		if handler then
			handler()
		end

		if workspace:GetAttribute("Minigame") then
			ChangeDisplayText()
			Modules.Spectate.EventStarted()
		end

		LeftEvent()
	end

end)

Remotes.Events.OnClientEvent:Connect(function(Action, ...)
	if Action == "Initiate Event" then
		local handler = EventModule.InitiateEvent
		if handler then
			handler(EventModule, ...)
		end
		
		Modules.EventsUI:EventStarted()

	elseif Action == "Event Started" then
		local handler = EventModule.EventStarted
		if handler then
			handler(EventModule, ...)
		end

		Modules.Spectate.EventStarted()
		
	elseif Action == "Update Event" then
		local handler = EventModule.UpdateEvent
		if handler then
			handler(EventModule, ...)
		end
	elseif Action == "Event Ended" then
		local handler = EventModule.EventEnded
		if handler then
			handler(EventModule, ...)
		end

		Modules.Spectate.EventEnded()
	end

end)

announcementRemote.OnClientEvent:Connect(function(player, item)
	if item == nil then
		item = player
		player = game.Players.LocalPlayer
	end
	if item.Type == "Poofie" then
		funcLib.SendMessage(
			item.Name.." just hatched an ultra rarity "..item.RealName.."!",
			Color3.new(0.917647, 0.0862745, 0.027451)
		)
	end

end)



EventInfoUI.ExitEvent.MouseButton1Down:Connect(function()
	Remotes.Teleport:InvokeServer(PlaceIds["Penguin City"])
end)




return GroupReward
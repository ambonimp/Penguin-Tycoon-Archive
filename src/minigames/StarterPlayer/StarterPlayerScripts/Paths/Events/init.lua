local GroupReward = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local funcLib = Paths.Modules.FuncLib
local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local EventModules = {}
for i, v in pairs(script:GetChildren()) do
	if v.Name ~= "Spectate" then
		EventModules[v.Name] = require(v)
	end
end

local announcementRemote = Remotes:WaitForChild("Announcement")


--- Events Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants

local EventInfoUI = Paths.UI.Top.EventInfo
local EventVotingUI = Paths.UI.Top.EventVoting
local EventPromptUI = Paths.UI.Top.EventPrompt
local EventUIs = Paths.UI.Right.EventUIs

local CurrentVote = false
local StartingTextOn = false



--- Events UI Functions ---
local function ChangeDisplayText(Text)
	if Participants:FindFirstChild(Paths.Player.Name) == nil then
		Paths.UI.Top.Soccer.Visible = false
	end
	EventInfoUI.EventInfoText.Text = Text
	if Text == "Starting in: 3" then
		Paths.Audio.Countdown:Play()
	end
	if string.match(Text, "Starting in") then-- or Text == "GO!!" then
		if Participants:FindFirstChild(Paths.Player.Name) then
			if not StartingTextOn then
				Paths.UI.Left.Customization.Visible = false
				Paths.UI.Left.GemDisplay.Visible = false
				Paths.UI.Left.Buttons.Visible = false

				Paths.UI.Bottom.Visible = false
				Paths.UI.BLCorner.Visible = false
				
				StartingTextOn = true
				EventInfoUI.ExitEvent.Visible = false
				EventInfoUI.EventInfoText:TweenSizeAndPosition(UDim2.new(1, 0, 0.7, 0), UDim2.new(0, 0, 1, 0), "In", "Quart", 0.5, true)
			end
			--Top.EventInfo.EventInfoText.Size = 
			--Top.EventInfo.EventInfoText.Position = 

			--EventInfoUI.EventInfoText.EventTutorial.Text = Modules.EventsConfig[CurrentEvent]["Tutorial"]
		end
	else
		if StartingTextOn then
			StartingTextOn = false
			EventInfoUI.EventInfoText:TweenSizeAndPosition(UDim2.new(1, 0, 0.35, 0), UDim2.new(0, 0, 0, 0), "In", "Quart", 0.5, true)
		end
		--Top.EventInfo.EventInfoText.Size = UDim2.new(1, 0, 0.35, 0)
		--Top.EventInfo.EventInfoText.Position = UDim2.new(0, 0, 0, 0)

		--EventInfoUI.EventInfoText.EventTutorial.Text = ""
	end
end


local function ChangeCountdownText(Countdown)
	EventVotingUI.Title.Text = "Vote for an event! ("..Countdown..")"
	EventPromptUI.Starting.Text = "is starting! ("..Countdown..")"
end


local function InitiateVoting(Options) -- {["Option#"] = "Event"}
	CurrentVote = false
	for i, Option in pairs(EventVotingUI.Options:GetChildren()) do
		if Option:IsA("ImageButton") then
			Option.EventName.Text = Modules.EventsConfig[Options[Option.Name]]["Display Name"]
			Option.Votes.Text = "0"
			Option.EventImage.Image = "rbxassetid://"..Modules.EventsConfig[Options[Option.Name]].ImageID
		end
	end
	for i, v in pairs(EventValues.Voting:GetChildren()) do
		EventVotingUI.Options[v.Name].BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		EventVotingUI.Options[v.Name].EventImage.Size = UDim2.new(1, -2, 1, -2)
	end
	
	--Chosen = false
	EventVotingUI.Position = UDim2.new(0.5, 0, 0.05, 0)
	EventVotingUI.Visible = true
end


local function StartingPrompt(Event)
	EventPromptUI.EventName.Text = Modules.EventsConfig[Event]["Display Name"]
	EventPromptUI.EventImage.Image = "rbxassetid://"..Modules.EventsConfig[Event].ImageID
	EventPromptUI.Position = UDim2.new(0.5, 0, 0.05, 0)
	
	EventVotingUI.Visible = false
	
	if Participants:FindFirstChild(game.Players.LocalPlayer.Name) == nil then
		EventPromptUI.Visible = true
	end
	task.wait(Modules.EventsConfig.ACCEPT_TIMER)
	EventPromptUI.Visible = false
end



local function JoinedEvent(Event)
	EventInfoUI.ExitEvent.Visible = true
end

local function EventStarted()
	Paths.UI.Left.GemDisplay.Visible = false
	Paths.UI.Left.Buttons.Visible = false

	Paths.UI.Bottom.Visible = false
	Paths.UI.BLCorner.Visible = false
end

local function LeftEvent()
	Paths.UI.Left.GemDisplay.Visible = true
	Paths.UI.Left.Buttons.Visible = true

	Paths.UI.Bottom.Visible = true
	Paths.UI.BLCorner.Visible = true
	
	EventInfoUI.ExitEvent.Visible = false
	for i, v in pairs(Paths.UI.Right.EventUIs:GetChildren()) do
		v.Visible = false
	end
end



--- Event Accepting and Voting ---
EventPromptUI.Ignore.MouseButton1Down:Connect(function()
	EventPromptUI.Visible = false
end)
EventPromptUI.Accept.MouseButton1Down:Connect(function()
	Remotes.Events:FireServer("Accept Prompt")
	EventPromptUI.Visible = false
end)

for i, Option in pairs(EventVotingUI.Options:GetChildren()) do
	if Option:IsA("ImageButton") then
		Option.MouseButton1Down:Connect(function()
			Remotes.Events:FireServer("Voting",Option.Name)
		end)
	end
end

for i,value in pairs (EventValues.Voting:GetChildren()) do
	value.Changed:Connect(function()
		EventVotingUI.Options:FindFirstChild(value.Name).Votes.Text = value.Value
	end)
end

EventVotingUI.Confirm.MouseButton1Click:Connect(function()
	EventVotingUI.Visible = false
end)



--- Connecting Functions ---
EventValues.TextToDisplay.Changed:Connect(function(Text)
	ChangeDisplayText(Text)
end)
EventValues.StartingTimer.Changed:Connect(function(Countdown)
	ChangeCountdownText(Countdown)
end)

Participants.ChildAdded:Connect(function(Participant)
	if Participant.Name == Paths.Player.Name then
		JoinedEvent()
	end
end)

Participants.ChildRemoved:Connect(function(Participant)
	if Participant.Name == Paths.Player.Name then
		LeftEvent()
	end
end)

EventInfoUI.ExitEvent.MouseButton1Down:Connect(function()
	Remotes.Events:FireServer("Exit Event")
end)

Remotes.Events.OnClientEvent:Connect(function(Action, Info, Info2)
	if Action == "Voting" then
		InitiateVoting(Info)
	elseif Action == "Event Chosen" then
		
	elseif Action == "Event Prompt" then
		StartingPrompt(Info)
		
	elseif Action == "Initiate Event" then
		EventModules[Info].InitiateEvent()
		
	elseif Action == "Event Started" then
		EventModules[Info]:EventStarted()
		Modules.Spectate.EventStarted()
		
	elseif Action == "Update Event" then
		EventModules[Info]:UpdateEvent(Info2)
		
	elseif Action == "Event Ended" then
		EventModules[Info]:EventEnded()
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


return GroupReward
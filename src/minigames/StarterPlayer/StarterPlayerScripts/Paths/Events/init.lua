local GroupReward = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local funcLib = Paths.Modules.FuncLib
local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local PlaceIds =  require(Services.RStorage.Modules.PlaceIds)


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


local function JoinedEvent()
	EventInfoUI.ExitEvent.Visible = false

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
	
	EventInfoUI.ExitEvent.Visible = true

	for i, v in pairs(Paths.UI.Left.EventUIs:GetChildren()) do
		v.Visible = false
	end

	for i, v in pairs(Paths.UI.Right.EventUIs:GetChildren()) do
		v.Visible = false
	end

end



--- Connecting Functions ---
ChangeDisplayText(EventValues.TextToDisplay.Value)
EventValues.TextToDisplay.Changed:Connect(function(Text)
	ChangeDisplayText(Text)
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
	Remotes.Teleport:InvokeServer(PlaceIds["Penguin City"])
end)

Remotes.Events.OnClientEvent:Connect(function(Action, Info, Info2)
	if Action == "Initiate Event" then
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
local SkateRace = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Votes = Services.RStorage.Modules.EventsConfig.Votes

local EventInfoUI = Paths.UI.Top.EventInfo
local EventVotingUI = Paths.UI.Top.EventVoting
local EventPromptUI = Paths.UI.Top.EventPrompt
local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs["Skate Race"]



--- Event Functions ---
function SkateRace:EventStarted()
	if Participants:FindFirstChild(Paths.Player.Name) then
		local Map = workspace.Event["Event Map"]

		EventInfoUI.ExitEvent.Visible = true
		EventUI.Visible = true
	end
end


function SkateRace.InitiateEvent()
	
end

function SkateRace.EventEnded()

end

--- Event Updating ---
function SkateRace:UpdateEvent(Info)
	for i, v in pairs(EventUI.PlayerList:GetChildren()) do
		if v:IsA("Frame") then
			v.PlaceNumber.Visible = false
			v.PlayerName.Text = ""
		end
	end
	
	for i, playerInfo in pairs(Info) do
		if EventUI.PlayerList:FindFirstChild("#"..playerInfo.Rank) then
			EventUI.PlayerList["#"..playerInfo.Rank].PlayerName.Text = playerInfo.Player.DisplayName
			EventUI.PlayerList["#"..playerInfo.Rank].PlaceNumber.Visible = true
			
			if playerInfo.Time then
				EventUI.PlayerList["#"..playerInfo.Rank].PlayerName.Text = playerInfo.Time.."s - "..playerInfo.Player.DisplayName
			end
		end
		
		if playerInfo.Player == Paths.Player or playerInfo.Player.Name == Modules.Spectate.CurrentlySpectating then
			EventUI.Player.Lap.Text = "Lap "..playerInfo.Lap.."/"..Modules.EventsConfig["Skate Race"].Laps
			EventUI.Player.PlaceNumber.Text = "#"..playerInfo.Rank
			
			if playerInfo.Time then
				EventUI.Player.Lap.Text = playerInfo.Time.."s - Lap "..playerInfo.Lap.."/"..Modules.EventsConfig["Skate Race"].Laps
			end
		end
	end
end


Remotes.Events.OnClientEvent:Connect(function(Action, CF)
	if Action == "Skate Race Winners Camera" or Action == "Soccer Winners Camera" then
		Paths.UI.BLCorner.Visible = true
		Paths.UI.Bottom.Visible = true
		Modules.Camera:AttachTo(CF)
	end
end)


return SkateRace
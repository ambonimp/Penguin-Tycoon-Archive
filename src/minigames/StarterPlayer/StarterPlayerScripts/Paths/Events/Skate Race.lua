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
local FinishedUI = Paths.UI.Center.RaceFinished

local toText = {
	[1] = "1ST",
	[2] = "2ND",
	[3] = "3RD",
	[4] = "4TH",
	[5] = "5TH",
	[6] = "6TH",
	[7] = "7TH",
	[8] = "8TH",
	[9] = "9TH",
	[10] = "10TH",
	[11] = "11TH",
	[12] = "12TH",
	[13] = "13TH",
	[14] = "14TH",
	[15] = "15TH",
	[16] = "16TH",
	[17] = "17TH",
	[18] = "18TH",
	[19] = "19TH",
	[20] = "20TH",
}

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

			FinishedUI.Title.Text = "YOU PLACED "..toText[playerInfo.Rank]
		end

		if FinishedUI.Placement:FindFirstChild(playerInfo.Rank) then
			local frame = FinishedUI.Placement:FindFirstChild(playerInfo.Rank)
			frame.PlayerName.Text = playerInfo.Player.Name..": "
			if playerInfo.Time then
				frame.Score.Text = playerInfo.Time
			else
				frame.Score.Text = "DNF"
			end
			if playerInfo.Player.Name == game.Players.LocalPlayer.Name then
				frame.BackgroundColor3 = Color3.new(0.901960, 0.843137, 0.058823)
			else
				frame.BackgroundColor3 = Color3.new(1, 1, 1)
			end
		end
	end
end

Remotes.Events.OnClientEvent:Connect(function(Action, CF,data)
	if Action == "Skate Race Winners Camera" or Action == "Soccer Winners Camera" then
		Paths.UI.BLCorner.Visible = true
		Paths.UI.Bottom.Visible = true
		Modules.Camera:AttachTo(CF)
	end
	if Action == "Skate Race Winners Camera" and data then
		task.wait(6)
		for i,playerInfo in pairs (data) do
			if playerInfo.Player.Name == game.Players.LocalPlayer.Name then
				Paths.Modules.Buttons:UIOn(FinishedUI,true)
				break
			end
		end
		
	end
end)


return SkateRace
local SkateRace = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local Participants = Services.RStorage.Modules.EventsConfig.Participants

local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs["Skate Race"]
local FinishedUI = Paths.UI.Center.GeneralEventFinished


--- Event Functions ---
function SkateRace:EventStarted()
	if Participants:FindFirstChild(Paths.Player.Name) then
		EventUI.Visible = true
	end
end


--- Event Updating ---
function SkateRace:UpdateEvent(Info)
	for _, v in pairs(EventUI.PlayerList:GetChildren()) do
		if v:IsA("Frame") then
			v.PlaceNumber.Visible = false
			v.PlayerName.Text = ""
		end
	end
	
	for _, PlayerInfo in pairs(Info) do
		if EventUI.PlayerList:FindFirstChild("#"..PlayerInfo.Rank) then
			EventUI.PlayerList["#"..PlayerInfo.Rank].PlayerName.Text = PlayerInfo.Player.DisplayName
			EventUI.PlayerList["#"..PlayerInfo.Rank].PlaceNumber.Visible = true
			
			if PlayerInfo.Time then
				EventUI.PlayerList["#"..PlayerInfo.Rank].PlayerName.Text = PlayerInfo.Time.."s - "..PlayerInfo.Player.DisplayName
			end
		end
		
		if PlayerInfo.Player == Paths.Player or PlayerInfo.Player.Name == Modules.Spectate.CurrentlySpectating then
			EventUI.Player.Lap.Text = "Lap "..PlayerInfo.Lap.."/"..Modules.EventsConfig["Skate Race"].Laps
			EventUI.Player.PlaceNumber.Text = "#"..PlayerInfo.Rank
			
			if PlayerInfo.Time then
				EventUI.Player.Lap.Text = PlayerInfo.Time.."s - Lap "..PlayerInfo.Lap.."/"..Modules.EventsConfig["Skate Race"].Laps
			end
		end

	end

end

Remotes.SkateRace.OnClientEvent:Connect(function(Event,...)
	local Params = table.pack(...)

	if Event == "Finished" then
		Modules.Camera:AttachTo(Params[2])

		task.wait(4)
        Modules.EventsUI:UpdateRankings(Params[1])
	end

end)

Remotes.Events.OnClientEvent:Connect(function(Action, CF,data)
	if Action == "Skate Race Winners Camera" or Action == "Soccer Winners Camera" then
		Modules.Camera:AttachTo(CF)
	end
end)


return SkateRace
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local SkateRace = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes




--- Event Variables ---
local EVENT_NAME = script.Name

local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Config = Modules.EventsConfig[EVENT_NAME]
local Assets = Services.RStorage.Assets[EVENT_NAME]


local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs[EVENT_NAME]
local FinishedUI = Paths.UI.Center.GeneralEventFinished


local GpsConn, LapConn

--- Event Functions ---
function SkateRace:EventStarted()

	if Participants:FindFirstChild(Paths.Player.Name) then
		EventUI.Visible = true
	end

	-- GPS
	local Map = workspace.Event["Event Map"]
	local LapHitbox = Map.LapHitbox

	local CurrentWP = 1
    local Waypoints = {}
	for _, Waypoint in ipairs(Map.Waypoints:GetChildren()) do
		Waypoints[tonumber(Waypoint.Name)] = Waypoint
	end
	table.insert(Waypoints, LapHitbox)



	local Character = Paths.Player.Character
	local PrimaryPart = Character:WaitForChild("HumanoidRootPart")

	local Sign = Assets.GPS:Clone()
	Sign.CFrame = PrimaryPart.CFrame + Vector3.new(0, 4, 0)
	Sign.Parent = Character

	local AlignPosition = Sign.AlignPosition
	local AlignOrientation = Sign.AlignOrientation

	GpsConn = RunService.RenderStepped:Connect(function()
		local CharPos = PrimaryPart.Position
		local WPCFrame = Waypoints[CurrentWP].CFrame

		--[[
			If angle between character position reaches a certain threshold
			Aka the point where it's not longer pointing forward
			Make it point to the next waypoint
		]]--
		if CurrentWP ~= #Waypoints then
			local Offset = WPCFrame:PointToObjectSpace(CharPos)
			local Theta = math.atan2(Offset.Z, Offset.X)

			if Theta <= 0 or math.min(Theta, math.pi - Theta) < math.rad(70) then
				-- One more check to make sure you don't skip some
				local DistanceToLast =  Waypoints[math.max(1, CurrentWP-1)].CFrame:PointToObjectSpace(CharPos).Magnitude
				local DistanceToCurrent = Offset.Magnitude
				if DistanceToCurrent <= DistanceToLast then
					CurrentWP += 1
				end
			end

			-- print(math.min(math.floor(math.deg(Theta)), math.floor(math.deg(math.pi - Theta))))
		end

		local Pos = CharPos + Vector3.new(0, 4, 0)
		local Dir = WPCFrame.Position * Vector3.new(1, 0, 1) + Vector3.new(0, Pos.Y, 0)

		AlignPosition.Position = Pos
		AlignOrientation.CFrame = CFrame.new(Pos, Dir)

	end)

	LapConn = LapHitbox.Touched:Connect(function()
		if CurrentWP == #Waypoints then
			CurrentWP = 1
		end
	end)

end

function SkateRace:LeftEvent()
	if GpsConn then GpsConn:Disconnect() end
	if LapConn then LapConn:Disconnect() end
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
			EventUI.Player.Lap.Text = "Lap "..PlayerInfo.Lap.."/"..Config.Laps
			EventUI.Player.PlaceNumber.Text = "#"..PlayerInfo.Rank
			
			if PlayerInfo.Time then
				EventUI.Player.Lap.Text = PlayerInfo.Time.."s - Lap "..PlayerInfo.Lap.."/"..Config.Laps
			end
		end

	end

end

Remotes.SkateRace.OnClientEvent:Connect(function(Event,...)
	local Params = table.pack(...)

	if Event == "Finished" then
		Modules.Camera:AttachTo(Params[2])

		SkateRace:LeftEvent()

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
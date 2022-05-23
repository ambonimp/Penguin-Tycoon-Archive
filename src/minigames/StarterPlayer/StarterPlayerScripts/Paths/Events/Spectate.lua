local Spectate = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI



--- Spectate Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants

local EventInfoUI = Paths.UI.Top.EventInfo
local EventVotingUI = Paths.UI.Top.EventVoting
local EventPromptUI = Paths.UI.Top.EventPrompt
local EventUIs = Paths.UI.Right.EventUIs

local isSpectating = false
Spectate.CurrentlySpectating = false
local CurrentlySpectatingNum = 1

local CurrentCamera = workspace.CurrentCamera



--- Spectate Functions ---
-- Events
function Spectate.EventStarted()
	if not Participants:FindFirstChild(Paths.Player.Name) then
		EventInfoUI.Spectate.Visible = true
		EventInfoUI.ExitEvent.Visible = false
	end
end

function Spectate.EventEnded()
	EventInfoUI.Spectate.Visible = false
	EventInfoUI.ExitEvent.Visible = false
	
	Spectate.ExitSpectateMode()
end



--- Entering and exiting spectate mode ---
function Spectate.EnterSpectateMode()
	if not isSpectating and #Participants:GetChildren() > 0 and not Participants:FindFirstChild(Paths.Player.Name) and EventValues.CurrentEvent.Value ~= "None" and workspace:GetAttribute("Minigame") then
		isSpectating = true
		
		Modules.Lighting:ChangeLighting(EventValues.CurrentEvent.Value)
		
		Spectate.UpdatePlayer()

		EventInfoUI.SpectateInfo.Visible = true
		EventInfoUI.StopSpectating.Visible = true
		EventInfoUI.Spectate.Visible = false
		EventInfoUI.ExitEvent.Visible = false
		
		if EventUIs:FindFirstChild(EventValues.CurrentEvent.Value) then
			EventUIs[EventValues.CurrentEvent.Value].Visible = true
		end
		if EventValues.CurrentEvent.Value == "Soccer" then
			Paths.UI.Top.Soccer.Visible = true
			EventInfoUI.EventInfoText.Visible = false
			EventInfoUI.SpectateInfo.Position = UDim2.new(0.5, 0,0.95, 0)
			EventInfoUI.StopSpectating.Position = UDim2.new(0.5, 0,0.95, 0)
		else
			EventInfoUI.SpectateInfo.Position = UDim2.new(0.5, 0,0.45, 0)
			EventInfoUI.StopSpectating.Position = UDim2.new(0.5, 0,0.45, 0)
		end
	end
end

function Spectate.ExitSpectateMode()
	EventInfoUI.EventInfoText.Visible = true
	Paths.UI.Top.Soccer.Visible = false
	EventInfoUI.StopSpectating.Visible = false
	EventInfoUI.SpectateInfo.Visible = false
	for i, v in pairs(EventUIs:GetChildren()) do v.Visible = false end
	
	if isSpectating and EventValues.CurrentEvent.Value ~= "None" then
		isSpectating = false
		Modules.Camera:ResetToCharacter()

		Modules.Lighting:ChangeLighting("Night Skating")
		EventInfoUI.Spectate.Visible = true
	end
end

function Spectate.UpdatePlayer()
	if not Participants:FindFirstChild(Paths.Player.Name) and workspace:GetAttribute("Minigame") and isSpectating then
		local PlayerToSpectate = Participants:GetChildren()[CurrentlySpectatingNum]
		local CharacterToSpectate = nil

		if PlayerToSpectate then
			CharacterToSpectate = workspace:FindFirstChild(PlayerToSpectate.Name)
		end

		if CharacterToSpectate then
			Spectate.CurrentlySpectating = PlayerToSpectate.Name
			EventInfoUI.SpectateInfo.Player.Text = PlayerToSpectate.Name

			CurrentCamera.CameraSubject = CharacterToSpectate.Humanoid
			CurrentCamera.CameraType = Enum.CameraType.Follow
		end
	end
end

--- Connecting functions
EventValues.CurrentEvent.Changed:Connect(function(value)
	if value == "None" then
		Spectate.EventEnded()
	end
end)

Participants.ChildRemoved:Connect(function(plr)
	if workspace:GetAttribute("Minigame") then
		if Spectate.CurrentlySpectating == plr.Name then
			if CurrentlySpectatingNum < #Participants:GetChildren() then
				CurrentlySpectatingNum += 1
			elseif CurrentlySpectatingNum > 1 then
				CurrentlySpectatingNum -= 1
			else
				CurrentlySpectatingNum = 1
			end
			Spectate.UpdatePlayer()
		end

		if #Participants:GetChildren() == 0 then
			Spectate.ExitSpectateMode()
		end
	else
		Spectate.ExitSpectateMode()
	end
end)

EventInfoUI.SpectateInfo.Forward.MouseButton1Down:Connect(function()
	if CurrentlySpectatingNum >= #Participants:GetChildren() then
		CurrentlySpectatingNum = 1
	else
		CurrentlySpectatingNum += 1
	end
	
	Spectate.UpdatePlayer()
end)

EventInfoUI.SpectateInfo.Back.MouseButton1Down:Connect(function()
	if CurrentlySpectatingNum <= 1 then
		CurrentlySpectatingNum = #Participants:GetChildren()
	else
		CurrentlySpectatingNum -= 1
	end
	
	Spectate.UpdatePlayer()
end)



--- Buttons ---
EventInfoUI.Spectate.MouseButton1Down:Connect(function()
	if workspace.Event:FindFirstChildOfClass("Model") then
		Spectate.EnterSpectateMode()
	end
end)


EventInfoUI.StopSpectating.MouseButton1Down:Connect(function()
	Spectate.ExitSpectateMode()
end)

workspace:GetAttributeChangedSignal("Minigame"):Connect(function()
	if workspace:GetAttribute("Minigame") == false then
		Spectate.ExitSpectateMode()
	end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
	repeat wait() until game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
end)

--- Initiate ---
if #Participants:GetChildren() > 0 and not Participants:FindFirstChild(Paths.Player.Name) and EventValues.CurrentEvent.Value ~= "None" then
	Spectate.EventStarted()
end
--[[
game.Players.LocalPlayer:GetAttributeChangedSignal("Minigame"):Connect(function()
	if game.Players.LocalPlayer:GetAttribute("Minigame") == "none" then
		Spectate.ExitSpectateMode()
	end
end)]]


return Spectate
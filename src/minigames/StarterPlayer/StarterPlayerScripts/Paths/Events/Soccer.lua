local Soccer = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local EventInfoUI = Paths.UI.Top.EventInfo
local EventValues = Services.RStorage.Modules.EventsConfig.Values

local setConnection = false
local JumpAnim 
local jumpID = "rbxassetid://9282632702"--9243965764"
local anim = Instance.new("Animation")
anim.AnimationId = jumpID

local SoccerUI = Paths.UI.Top.Soccer
local RedTeam = SoccerUI.RedTeam
local BlueTeam = SoccerUI.BlueTeam

function Soccer:InitiateEvent(Event)
	if setConnection then return end
	setConnection = true
	local Character = game.Players.LocalPlayer.Character
	if Services.RStorage.Modules.EventsConfig.Participants:FindFirstChild(game.Players.LocalPlayer.Name) then
		workspace.CurrentCamera.CFrame = CFrame.new(Character.PrimaryPart.CFrame.Position+(-Character.PrimaryPart.CFrame.LookVector*15),Character.PrimaryPart.CFrame.Position)
	end
	
	
	local function addGoal(team,score)
		if team == "Red" then
			RedTeam.Amount.Text = score
			SoccerUI.RedGoal.Visible = true
			SoccerUI.RedGoal:TweenSize(
				UDim2.new(0.175, 0, 0.3, 0),  -- endSize (required)
				Enum.EasingDirection.Out,    -- easingDirection (default Out)
				Enum.EasingStyle.Bounce,      -- easingStyle (default Quad)
				.25,                          -- time (default: 1)
				true
			)
			wait(2.5)
			if SoccerUI.RedGoal.Visible then
				SoccerUI.RedGoal:TweenSize(
					UDim2.new(0.175, 0, 0, 0),  -- endSize (required)
					Enum.EasingDirection.In,    -- easingDirection (default Out)
					Enum.EasingStyle.Linear,      -- easingStyle (default Quad)
					.05,                          -- time (default: 1)
					true
				)
				wait(.05)
				SoccerUI.RedGoal.Visible = false
			end
		elseif team == "Blue" then
			BlueTeam.Amount.Text = score
			SoccerUI.BlueGoal.Visible = true
			SoccerUI.BlueGoal:TweenSize(
				UDim2.new(0.175, 0, 0.3, 0),  -- endSize (required)
				Enum.EasingDirection.Out,    -- easingDirection (default Out)
				Enum.EasingStyle.Bounce,      -- easingStyle (default Quad)
				.25,                          -- time (default: 1)
				true
			)
			wait(2.5)
			if SoccerUI.BlueGoal.Visible then
				SoccerUI.BlueGoal:TweenSize(
					UDim2.new(0.175, 0, 0, 0),  -- endSize (required)
					Enum.EasingDirection.In,    -- easingDirection (default Out)
					Enum.EasingStyle.Linear,      -- easingStyle (default Quad)
					.05,                          -- time (default: 1)
					true
				)
				wait(.05)
				SoccerUI.BlueGoal.Visible = false
			end
		end
	end
	spawn(function()
		repeat wait(.1) until Character:GetAttribute("Team")
		if Character:GetAttribute("Team") == "Red" then
			RedTeam.Team.Visible = true
		else
			BlueTeam.Team.Visible = true
		end
	end)
	
	if game:GetService("GuiService"):IsTenFootInterface() == false then
		SoccerUI.Position = UDim2.fromOffset(0,-36)
	end
	EventValues.SoccerTime.Changed:Connect(function()
		SoccerUI.Timer.Text = EventValues.SoccerTime.Value
	end)
	
	EventValues.ScoreBlue.Changed:Connect(function()
		if EventValues.ScoreBlue.Value > 0 then
			addGoal("Blue",EventValues.ScoreBlue.Value)
		end
	end)
	
	EventValues.ScoreRed.Changed:Connect(function()
		if EventValues.ScoreRed.Value > 0 then
			addGoal("Red",EventValues.ScoreRed.Value)
		end
	end)
	
	local function addAnim()
		repeat wait() until Character:WaitForChild("Humanoid"):IsDescendantOf(workspace)
		local new= anim:Clone()
		new.Parent = Character:WaitForChild("Humanoid")
		JumpAnim = Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(new)
	end
	
	local justJumped = false
	game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
		Character = char
		addAnim()
	end)
	
	
	addAnim()
	game:GetService("UserInputService").JumpRequest:Connect(function()
		if game.Players.LocalPlayer:GetAttribute("Minigame") == "Soccer" and justJumped == false and Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid").WalkSpeed > 1 then
			justJumped = true
			JumpAnim:Play(.2,5,1.75)
			wait(.15)
			Paths.Audio.Dive:Play()
			Character.PrimaryPart.Velocity = (Character.PrimaryPart.CFrame.LookVector + Vector3.new(0,.0375,0)) * 100
			wait(.5)
			JumpAnim:Stop(.5)
			wait(.8)
			justJumped = false
		end
	end)
end

function Soccer:EventStarted()
	BlueTeam.Team.Visible = false
	RedTeam.Team.Visible = false
	BlueTeam.Amount.Text = "0"
	RedTeam.Amount.Text = "0"
	if game.Players.LocalPlayer:GetAttribute("Minigame") ~= "Soccer" then EventInfoUI.EventInfoText.Visible = true return end
	SoccerUI.Visible = true
	EventInfoUI.EventInfoText.Visible = false
	if game.Players.LocalPlayer.Character:GetAttribute("Team") == "Red" then
		RedTeam.Team.Visible = true
	else
		BlueTeam.Team.Visible = true
	end
end

function Soccer.EventEnded()
	EventInfoUI.EventInfoText.Visible = true
	SoccerUI.Visible = false
end

Remotes.SoccerEvent.OnClientEvent:Connect(function(kind,team)
	if workspace.Event:FindFirstChildOfClass("Model") then
		if kind == "Scored" and game.Players.LocalPlayer:GetAttribute("Minigame") == "Soccer" then
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:GetAttribute("Team") == team then 
				if team == "Red" then
					workspace.Event:FindFirstChildOfClass("Model").BlueConfetti.Cheering:Play()
				else
					workspace.Event:FindFirstChildOfClass("Model").RedConfetti.Cheering:Play()
				end
			elseif game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:GetAttribute("Team") ~= team then 
				if team == "Red" then
					workspace.Event:FindFirstChildOfClass("Model").RedConfetti.Oof:Play()
				else
					workspace.Event:FindFirstChildOfClass("Model").BlueConfetti.Oof:Play()
				end
			end
		elseif kind == "hit" then
			local ball = team
			if ball then
				ball.Dive:Play()
			end
		end
	end
end)


return Soccer
local Soccer = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local EventInfoUI = Paths.UI.Top.EventInfo
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants


local setConnection = false
local JumpAnim
local jumpID = "rbxassetid://9282632702"--9243965764"
local anim = Instance.new("Animation")
anim.AnimationId = jumpID

local SoccerUI = Paths.UI.Top.Soccer
local RedTeam = SoccerUI.RedTeam
local BlueTeam = SoccerUI.BlueTeam

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character






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
		task.wait(2.5)
		if SoccerUI.RedGoal.Visible then
			SoccerUI.RedGoal:TweenSize(
				UDim2.new(0.175, 0, 0, 0),  -- endSize (required)
				Enum.EasingDirection.In,    -- easingDirection (default Out)
				Enum.EasingStyle.Linear,      -- easingStyle (default Quad)
				.05,                          -- time (default: 1)
				true
			)
			task.wait(.05)
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
		task.wait(2.5)
		if SoccerUI.BlueGoal.Visible then
			SoccerUI.BlueGoal:TweenSize(
				UDim2.new(0.175, 0, 0, 0),  -- endSize (required)
				Enum.EasingDirection.In,    -- easingDirection (default Out)
				Enum.EasingStyle.Linear,      -- easingStyle (default Quad)
				.05,                          -- time (default: 1)
				true
			)
			task.wait(.05)
			SoccerUI.BlueGoal.Visible = false
		end

	end

end


-- Events
function Soccer:InitiateEvent(Event)
	if setConnection then return end
	setConnection = true

	if Participants:FindFirstChild(Player.Name) then
		workspace.CurrentCamera.CFrame = CFrame.new(Character.PrimaryPart.CFrame.Position+(-Character.PrimaryPart.CFrame.LookVector*15),Character.PrimaryPart.CFrame.Position)
	end

	task.spawn(function()
		repeat task.wait(.1) until Character:GetAttribute("Team")
		if Character:GetAttribute("Team") == "Red" then
			RedTeam.Team.Visible = true
		else
			BlueTeam.Team.Visible = true
		end
	end)

end

function Soccer:EventStarted()
	BlueTeam.Team.Visible = false
	RedTeam.Team.Visible = false
	BlueTeam.Amount.Text = "0"
	RedTeam.Amount.Text = "0"

	-- Incase player resets during countdown
	if Participants:FindFirstChild(Player.Name) then
		SoccerUI.Visible = true
		EventInfoUI.TextToDisplay.Visible = false

		if Player.Character:GetAttribute("Team") == "Red" then
			RedTeam.Team.Visible = true
		else
			BlueTeam.Team.Visible = true
		end

	end

end

function Soccer:LeftEvent()
	EventInfoUI.TextToDisplay.Visible = true
	SoccerUI.Visible = false
end

Remotes.SoccerEvent.OnClientEvent:Connect(function(event,team)
	if workspace.Event:FindFirstChildOfClass("Model") then
		local character = Player.Character

		if event == "Scored" then
			if character and character:GetAttribute("Team") == team then
				if team == "Red" then
					workspace.Event:FindFirstChildOfClass("Model").BlueConfetti.Cheering:Play()
				else
					workspace.Event:FindFirstChildOfClass("Model").RedConfetti.Cheering:Play()
				end
			elseif character and Player.Character:GetAttribute("Team") ~= team then
				if team == "Red" then
					workspace.Event:FindFirstChildOfClass("Model").RedConfetti.Oof:Play()
				else
					workspace.Event:FindFirstChildOfClass("Model").BlueConfetti.Oof:Play()
				end
			end

		elseif event == "hit" then
			local ball = team

			if ball then
				ball.Dive:Play()
			end

		end

	end

end)





-- Interface
if game:GetService("GuiService"):IsTenFootInterface() == false then
	SoccerUI.Position = UDim2.fromOffset(0,-36)
end

EventValues.SoccerTime.Changed:Connect(function()
	SoccerUI.Timer.Text = EventValues.SoccerTime.Value
end)


EventValues.ScoreBlue.Changed:Connect(function()
	if EventValues.ScoreBlue.Value > 0 then
		addGoal("Blue", EventValues.ScoreBlue.Value)
	end
end)

EventValues.ScoreRed.Changed:Connect(function()
	if EventValues.ScoreRed.Value > 0 then
		addGoal("Red",EventValues.ScoreRed.Value)
	end
end)



-- Jumping
local function LoadJumpAnimation()
	repeat task.wait() until Character:WaitForChild("Humanoid"):IsDescendantOf(workspace)

	local new = anim:Clone()
	new.Parent = Character:WaitForChild("Humanoid")
	JumpAnim = Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(new)
end

if Character then LoadJumpAnimation() end

Player.CharacterAdded:Connect(function(char)
	Character = char
	LoadJumpAnimation()
end)

local justJumped = false
game:GetService("UserInputService").JumpRequest:Connect(function()
	if Participants:FindFirstChild(Player.Name) and not justJumped and Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid").WalkSpeed > 1 then
		justJumped = true
		JumpAnim:Play(.2,5,1.75)
		task.wait(.15)
		Paths.Audio.Dive:Play()
		Character.PrimaryPart.Velocity = (Character.PrimaryPart.CFrame.LookVector + Vector3.new(0,.0375,0)) * 100
		task.wait(.5)
		JumpAnim:Stop(.5)
		task.wait(.8)
		justJumped = false

	end

end)


return Soccer
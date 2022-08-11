local Soccer = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local EVENT_NAME = script.Name

local Config = Modules.EventsConfig[EVENT_NAME]
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Assets = Services.RStorage.Assets[EVENT_NAME]

local EventInfoUI = Paths.UI.Top.EventInfo


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






local function addGoal(team, score)
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
	Character = Player.Character

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

Remotes.SoccerEvent.OnClientEvent:Connect(function(Event, ...)
	Character = Player.Character

	local Params = table.pack(...)
	if Event == "Scored" then
		local Team = Params[1]
		local Scorer = Params[2]

		if Participants:FindFirstChild(Player.Name) then
			local sound = Character:GetAttribute("Team") == Team and "Cheering" or "Oof"
			workspace.Event:FindFirstChildOfClass("Model")[Team .. "Confetti"][sound]:Play()
		end

		if Scorer then
			local Notif = Assets.ScoreNotif:Clone()
			Notif.Text = string.format('<font color="#fcc203"> %s </font> just scored for the <font color="%s">%s team</font>', Scorer, Team == "Red" and "#ff3b3b" or "#3b9aff", string.lower(Team))
			Notif.Parent = SoccerUI
			Notif:TweenPosition(UDim2.fromScale(0.5, 0.8), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 1, false, function()
				task.wait(4)
				Notif:Destroy()
			end)
		end

		local Score = EventValues["Score" .. Team].Value
		if Score > 0 then
			addGoal(Team, Score)
		end

	elseif Event == "Hit" then
		local Ball = Params[1]
		if Ball then
			Ball.Dive:Play()
		end
	end


end)





EventValues.SoccerTime.Changed:Connect(function()
	SoccerUI.Timer.Text = EventValues.SoccerTime.Value
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
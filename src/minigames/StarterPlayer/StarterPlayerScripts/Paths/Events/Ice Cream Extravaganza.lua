local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local IceCreamExtravaganza = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local EVENT_NAME = script.Name
local SHAODW_TRANSPARENCY = 0.75


local Config = Modules.EventsConfig[EVENT_NAME]
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants


local Timer =  Paths.UI.Top[EVENT_NAME]

local Scoreboard =  Paths.UI.Left.EventUIs[EVENT_NAME]
local ScoreDisplay =  Paths.UI.Right.EventUIs[EVENT_NAME]
local FinishedUI = Paths.UI.Center.GeneralEventFinished

local Assets = Services.RStorage.Assets[EVENT_NAME]


-- Variables
local Player = game.Players.LocalPlayer

local Map = workspace.Event:WaitForChild("Event Map")
local DropShadows
local CollectSounds

local EventFinished = false

local Rand = Random.new()

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



-- Utility Functions --
local function GetCFrame(model)
	local primary = model.PrimaryPart
	local primaryCf = primary.CFrame
	local cache = {}

	for _,child in ipairs(model:GetDescendants()) do
		if (child:IsA("BasePart") and child ~= primary) then
			cache[child] = primaryCf:ToObjectSpace(child.CFrame)
		end
	end

	return function(desiredCf)
		primary.CFrame = desiredCf
		for part,offset in pairs(cache) do
			part.CFrame = desiredCf * offset
		end
	end

end

local function TweenModel(model, tweenInfo, goal, onStep) -- cframe
	local start = os.clock()
	local length = tweenInfo.Time

	local cframer = GetCFrame(model)

	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Name = "Tween"
	cframeValue.Value = model.PrimaryPart.CFrame
	cframeValue.Parent = model

	cframeValue.Changed:Connect(function(new)
		cframer(new)
		-- Run a handler pass it the tween's completion percentage
		onStep((os.clock() - start)/ length)
	end)

	local tween = Services.TweenService:Create(cframeValue, tweenInfo, {Value = goal})

	tween.Completed:Connect(function()
		cframeValue:Destroy()
	end)

	tween:Play()
	return tween
end

local function ScoreChangedParticle(Particle)
	if not Particle then return end

	local InitSize = Particle.Size
	local FinalSize = UDim2.fromScale(0, 0)
	local Position = UDim2.fromScale(Rand:NextNumber(0.35, 0.65), Rand:NextNumber(0.35, 0.65))

	Particle = Particle:Clone()
	Particle.Size = FinalSize
	Particle.Position = Position
	Particle.Visible = true
	Particle.Parent = Paths.UI.Center


	local Offset = Rand:NextNumber(-0.05, 0.05)
	local Sign = math.sign(Offset)

	local Tween = Paths.Services.TweenService:Create(Particle, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
	   Size = InitSize + UDim2.fromScale(0.025, 0.025),
	   Rotation = Offset / 3,
	   Position = UDim2.fromScale(Position.X.Scale + Offset, Position.Y.Scale - Rand:NextNumber(0.07, 0.12))
   })

   Tween.Completed:Connect(function()
		local Tween2 = Paths.Services.TweenService:Create(Particle, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.2), {
			Size = UDim2.fromScale(0, 0),
			Rotation = Particle.Rotation + Sign * 180,
			Position = Particle.Position + UDim2.fromScale(Offset * 5, Rand:NextNumber(0.05, 0.15))
	   })

	   Tween2.Completed:Connect(function()
			Particle:Destroy()
	   end)

	   Tween2:Play()
	end)

	Tween:Play()

end




--- Event Functions ---
function IceCreamExtravaganza:EventStarted()
	EventFinished = false

	DropShadows = {}

	-- Incase player resets during countdown
	if Participants:FindFirstChild(Player.Name) then

		-- Change countdown ui
		Timer.Visible = true
		Scoreboard.Visible = true
		ScoreDisplay.Visible = true

		for _, ListItem in ipairs(Scoreboard.PlayerList:GetChildren()) do
			if ListItem:IsA("TextLabel") then
				ListItem.Visible = false
			end
		end

		CollectSounds = {}
		for _, Sound in ipairs(Assets.CollectSounds:GetChildren()) do
			Sound = Sound:Clone()
			Sound.Parent = Players.LocalPlayer.Character

			CollectSounds[Sound.Name] = Sound
		end

	end

end

function IceCreamExtravaganza:LeftEvent()
	-- Change countdown ui
	Timer.Visible = false

	Scoreboard.Visible = false
	ScoreDisplay.Visible = false

end

Remotes.IceCreamExtravaganza.OnClientEvent:Connect(function(Event, ...)
    local Params = table.pack(...)
    if Event == "DropCreated" then
        local Id = Params[1]
        local Position = Params[2]
        local Model = Params[3]

		local Start = CFrame.new(Position) * CFrame.fromEulerAnglesYXZ(0, math.random(0, math.pi), 0)
		local _, Size = Model:GetBoundingBox()


		local FloorPosition = Map.PrimaryPart.Position + Map.PrimaryPart.Size * Vector3.new(0, 0.5, 0) -- Position of top surface of floor
        local DropHeight = ((Position - FloorPosition) - Size * Vector3.new(0, 0.5, 0)) * Vector3.new(0, 1, 0)


		-- Visuals
        local Drop = Model:Clone()
        Drop.PrimaryPart.Anchored = true
        Drop:SetPrimaryPartCFrame(Start)
        Drop.Parent = workspace

		local Hitbox = Instance.new("Part")
		Hitbox.CastShadow = false
		Hitbox.CanCollide = false
		Hitbox.Transparency = 1
		Hitbox.Anchored = true
		Hitbox.Size = Size
		Hitbox.CFrame = Start
		Hitbox.Parent = Drop

		local Shadow = Assets.DropShadow:Clone()
		Shadow.Decal.Transparency = 1
		Shadow.Position = Vector3.new(Position.X, FloorPosition.Y, Position.Z) + Shadow.Size * Vector3.new(0, 0.5, 0)
		Shadow.Parent = Workspace


		-- Nessecary for when you join the server and event starts, but has been fired by the time client finishes loading and starts listening
		DropShadows = DropShadows or {}

		-- Create a queue of shadows at this position. Only the first is visible and it's size is updated
		local ShadowSize = Vector3.new(Size.X, 0.1, Size.X) + Vector3.new(2, 0, 2)
		local ShadowsAtPosition = DropShadows[Position]
		if not ShadowsAtPosition then
			ShadowsAtPosition = {}
			DropShadows[Position] = ShadowsAtPosition
		end
		table.insert(ShadowsAtPosition, Id)


		-- Play drop animation
        local Info = TweenInfo.new(DropHeight.Y / Config.DropVelocity, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    	local Tween = TweenModel(Drop, Info, Start - DropHeight, function(Progress)
			if ShadowsAtPosition[1] == Id then
				Progress =  math.pow(2, Progress - 0.25) - 0.6--math.log(Progress + 1, 20) * 2  + 0.5-- The farther away the part, the smmaller the shadow

				Shadow.Decal.Transparency = SHAODW_TRANSPARENCY
				Shadow.Size = ShadowSize * Vector3.new(Progress, 1, Progress) -- Want shadows to stay square

			end
		end)

    	Tween.Completed:Connect(function()
    	   Shadow:Destroy()
    		Drop:Destroy()

            table.remove(ShadowsAtPosition, table.find(ShadowsAtPosition, Id))
    	end)

		local Connection
    	Connection = Hitbox.Touched:Connect(function(hit)
    	   if EventFinished then return end

    		local Character = hit.Parent
    		local Hum = Character:FindFirstChildOfClass("Humanoid")

    		if Hum then
                -- Notifiy server that scoop has been collected
				if Character.Name == Player.Name then
					local Type = Model.Parent.Name
					-- Play sound
					CollectSounds[Type ~= "Obstacle" and "Good" or "Bad"]:Play()

					-- Emit particle
					local Particle = Assets.ScoreParticles:FindFirstChild(Type)
					if Type == "Regular" then
						Particle.TextColor3 = Model.PrimaryPart.Color
					end
					ScoreChangedParticle(Particle)

					-- Notify server
					Remotes.IceCreamExtravaganza:FireServer("ScoopCollected", Id)

				end

    			Tween:Cancel()
    			Connection:Disconnect()
    		end

    	end)

    	Tween:Play()
	elseif Event == "Update" then
		local Rankings = Params[1]

		for _, ListItem in ipairs(Scoreboard.PlayerList:GetChildren()) do
			if ListItem:IsA("TextLabel") then
				local RankedHere = Rankings[tonumber(ListItem.Name)]

				if RankedHere then
					local PlayerName = RankedHere.PlayerName
					local Score = RankedHere.Score

					if PlayerName == Player.Name then
						ScoreDisplay.Score.Text = "Score: " .. Score
					end

					ListItem.Visible = true
					ListItem.Text =  PlayerName .. ": " .. Score

				end

			end

		end

	elseif Event == "Finished" then
		EventFinished = true

		local Rankings = Params[1]
		local MyRanking

		for i = 1, Config.MaxPlayers do
			local Placement = FinishedUI.Placement:FindFirstChild(i)
			local Ranked = Rankings[i]

			if Ranked then
				Placement.Visible = true
				Placement.PlayerName.Text = Ranked.PlayerName..":"
				Placement.Score.Text = Ranked.Score

				if Ranked.PlayerName == Player.Name then
					MyRanking = i
					Placement.BackgroundColor3 = Color3.new(0.901960, 0.843137, 0.058823)
				else
					Placement.BackgroundColor3 = Color3.new(1, 1, 1)
				end

			else
				Placement.Visible = false
			end

		end

		if MyRanking then
			FinishedUI.Visible = true
			Paths.Modules.Buttons:UIOn(FinishedUI,true)

			FinishedUI.Title.Text = "YOU PLACED ".. toText[MyRanking]
		end

    end

end)

EventValues.IceCreamTimer.Changed:Connect(function()
	local Remainder = EventValues.IceCreamTimer.Value
	Timer.Timer.Text =  string.format("%02i:%02i", Remainder/60%60, Remainder%60)
end)

return IceCreamExtravaganza
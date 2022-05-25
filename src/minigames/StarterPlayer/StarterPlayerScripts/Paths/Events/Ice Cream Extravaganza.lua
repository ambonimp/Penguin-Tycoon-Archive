local Players = game:GetService("Players")
local IceCreamExtravaganza = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local EVENT_NAME = script.Name

local Config = Modules.EventsConfig[EVENT_NAME]
local EventValues = Services.RStorage.Modules.EventsConfig.Values

local EventInfoUI = Paths.UI.Top.EventInfo
local Timer =  Paths.UI.Top[EVENT_NAME]

local Scoreboard =  Paths.UI.Left.EventUIs[EVENT_NAME]
local ScoreDisplay =  Paths.UI.Right.EventUIs[EVENT_NAME]
local FinishedUI = Paths.UI.Center.GeneralEventFinished


-- Variables

local Map = workspace.Event:WaitForChild("Event Map")
local CollectSound

local Player = game:GetService("Players").LocalPlayer

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

local function TweenModel(model, tweenInfo, goal) -- cframe
	local cframer = GetCFrame(model)

	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Name = "Tween"
	cframeValue.Value = model.PrimaryPart.CFrame
	cframeValue.Parent = model

	cframeValue.Changed:Connect(function(new)
		cframer(new)
	end)

	local tween = Services.TweenService:Create(cframeValue, tweenInfo, {Value = goal})

	tween.Completed:Connect(function()
		cframeValue:Destroy()
	end)

	tween:Play()
	return tween
end



--- Event Functions ---
function IceCreamExtravaganza:EventStarted()
	Score = 0

	-- Change countdown ui
	--EventInfoUI.Visible = false
	Timer.Visible = true

	ScoreDisplay.Visible = true

	for _, ListItem in ipairs(Scoreboard.PlayerList:GetChildren()) do
		if ListItem:IsA("TextLabel") then
			ListItem.Visible = false
		end
	end
	Scoreboard.Visible = true

	CollectSound = Paths.Audio.Collected:Clone()
	CollectSound.Parent = Players.LocalPlayer.Character

end

function IceCreamExtravaganza.InitiateEvent()
end

function IceCreamExtravaganza.EventEnded()
	-- Change countdown ui
	--EventInfoUI.Visible = false
	Timer.Visible = false

	Scoreboard.Visible = false
	ScoreDisplay.Visible = false

end

Remotes.IceCreamExtravaganza.OnClientEvent:Connect(function(Event, ...)
    local Params = table.pack(...)
    if Event == "DropCreated" then
        local Id = Params[1]
        local Model = Params[3]

		local Start = CFrame.new(Params[2]) * CFrame.fromEulerAnglesYXZ(0, math.random(0, math.pi), 0)
		local _, Size = Model:GetBoundingBox()

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


		local FloorPosition = Map.PrimaryPart.Position + Map.PrimaryPart.Size * Vector3.new(0, 0.5, 0) -- Position of top surface of floor
        local DropHeight = ((Start.Position - FloorPosition) - Size * Vector3.new(0, 0.5, 0)) * Vector3.new(0, 1, 0)


        local Info = TweenInfo.new(DropHeight.Y / Config.DropVelocity, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    	local Tween = TweenModel(Drop, Info, Start - DropHeight)

    	Tween.Completed:Connect(function()
    		Drop:Destroy()
    	end)

		local Connection
    	Connection = Hitbox.Touched:Connect(function(hit)
    		local Character = hit.Parent
    		local Hum = Character:FindFirstChildOfClass("Humanoid")

    		if Hum then
                -- Notifiy server that scoop has been collected
				if Character.Name == game.Players.LocalPlayer.Name then
					Score =
					CollectSound:Play()
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
		local Rankings = Params[1]
		local MyRanking

		for i = 1, Config.MaxPlayers do
			local Placement = FinishedUI.Placement:FindFirstChild(i)
			local Ranked = Rankings[i]

			if Ranked then
				Placement.Visible = true
				Placement.PlayerName.Text = Ranked.PlayerName..":"
				Placement.Score.Text = Ranked.Score

				if Ranked.PlayerName == game.Players.LocalPlayer.Name then
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
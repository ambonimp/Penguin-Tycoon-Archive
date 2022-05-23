local IceCreamExtravaganza = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local EVENT_NAME = script.Name

local Config = Modules.EventsConfig[EVENT_NAME]

local EventInfoUI = Paths.UI.Top.EventInfo
local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs[EVENT_NAME]
local FinishedUI = Paths.UI.Center.GeneralEventFinished


-- Variables
local Scoops = Services.RStorage.Assets[EVENT_NAME].Scoops

local Map = workspace.Event:WaitForChild("Event Map")
local Floor = Map.PrimaryPart.Position + Map.PrimaryPart.Size * Vector3.new(0, 0.5, 0) -- Position of top surface of floor

local Score
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
function IceCreamExtravaganza:EventStarted()
	EventInfoUI.ExitEvent.Visible = true
	EventUI.Visible = true

	Score = 0
end

function IceCreamExtravaganza.InitiateEvent()
end

function IceCreamExtravaganza.EventEnded()
	EventInfoUI.ExitEvent.Visible = false
	EventUI.Visible = false
end

Remotes.IceCreamExtravaganza.OnClientEvent:Connect(function(Event, ...)
    local Params = table.pack(...)
    if Event == "DropCreated" then
        local Id = Params[1]
        local Position = Params[2]
        local Type = Params[3]

        local Drop = Scoops[Type]:Clone()
        Drop.Position = Position
        Drop.Parent = workspace


        local DropHeight = ((Position - Floor) + Drop.Size * Vector3.new(0, 0.5, 0) )* Vector3.new(0, 1, 0)

        local Info = TweenInfo.new(DropHeight.Y / Config.DropVelocity, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    	local Tween = Services.TweenService:Create(Drop, Info, {Position = Position - DropHeight})

    	Tween.Completed:Connect(function()
    		Drop:Destroy()
    	end)

    	Drop.Touched:Connect(function(hit)
    		local Character = hit.Parent
    		local Hum = Character:FindFirstChildOfClass("Humanoid")

    		if Hum then
				Score = math.max(0, Score + (if Type == "Regular" then 1 else (if Type == "Bad" then -3 else 0)))
				EventUI.Score.Text = "Score: " .. Score

                -- Notifiy server that scoop has been collected
				if Character.Name == game.Players.LocalPlayer.Name then
					Remotes.IceCreamExtravaganza:FireServer("ScoopCollected", Id)
				end

    			Tween:Cancel()
    		end

    	end)

    	Tween:Play()
	elseif Event == "Finished" then
		local Scoreboard = Params[1]
		local MyRanking

		for i = 1, Config.MaxPlayers do
			local Placement = FinishedUI.Placement:FindFirstChild(i)
			local Ranked = Scoreboard[i]

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


return IceCreamExtravaganza
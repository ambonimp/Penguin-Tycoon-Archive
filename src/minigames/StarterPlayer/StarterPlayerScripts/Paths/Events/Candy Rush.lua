local CandyRush = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local Participants = Services.RStorage.Modules.EventsConfig.Participants

local EventInfoUI = Paths.UI.Top.EventInfo
local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs["Candy Rush"]
local FinishedUI = Paths.UI.Center.CandyRushFinished


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

function findTbl(playerName,EggsCollected)
	for i,v in pairs (EggsCollected) do
		if v[1] == playerName then return i end
	end
	return 0
end

Remotes.CandyRush.OnClientEvent:Connect(function(kind,tab)
	if kind == "Finished" then
		table.sort(tab,function(a,b)
			return a[2] > b[2]
		end)

		for i = 1,10 do
			local ui = FinishedUI.Placement:FindFirstChild(i)
			if tab[i] then
				ui.Visible = true
				ui.PlayerName.Text = tab[i][1]..":"
				ui.Score.Text = tab[i][2]
				if tab[i][1] == game.Players.LocalPlayer.Name then
					ui.BackgroundColor3 = Color3.new(0.901960, 0.843137, 0.058823)
				else
					ui.BackgroundColor3 = Color3.new(1, 1, 1)
				end
			else
				ui.BackgroundColor3 = Color3.new(1, 1, 1)
				ui.PlayerName.Text = "N/A"
				ui.Score.Text = ""
			end
		end
	
		local f = findTbl(game.Players.LocalPlayer.Name,tab)
		if f then
			local plr = tab[f]
			if plr then
				FinishedUI.Title.Text = "YOU PLACED "..toText[f]
				local score = plr[2]
				local eggs = plr[3]
				FinishedUI.Eggs:FindFirstChild("Blue"):FindFirstChild("Number").Text = eggs["Blue"]
				FinishedUI.Eggs:FindFirstChild("Red"):FindFirstChild("Number").Text = eggs["Red"]
				FinishedUI.Eggs:FindFirstChild("Purple"):FindFirstChild("Number").Text = eggs["Purple"]
				FinishedUI.Eggs:FindFirstChild("Green"):FindFirstChild("Number").Text = eggs["Green"]
				FinishedUI.Eggs:FindFirstChild("Gold"):FindFirstChild("Number").Text = eggs["Gold"]

				FinishedUI.Visible = true
				Paths.Modules.Buttons:UIOn(FinishedUI,true)
			end
		end
	elseif kind == "Update" then
		table.sort(tab,function(a,b)
			return a[2] > b[2]
		end)
	
		for i = 1,10 do
			local ui = EventUI.Players.PlayerList:FindFirstChild(i)
			if tab[i] then
				ui.Visible = true
				ui.Text = tab[i][1]..": "..tab[i][2]
			else
				ui.Visible = false
			end
		end
	
		local plr = tab[findTbl(game.Players.LocalPlayer.Name,tab)]
		if plr then
			local score = plr[2]
			local eggs = plr[3]
			EventUI.Eggs:FindFirstChild("Blue"):FindFirstChild("Number").Text = eggs["Blue"]
			EventUI.Eggs:FindFirstChild("Red"):FindFirstChild("Number").Text = eggs["Red"]
			EventUI.Eggs:FindFirstChild("Purple"):FindFirstChild("Number").Text = eggs["Purple"]
			EventUI.Eggs:FindFirstChild("Green"):FindFirstChild("Number").Text = eggs["Green"]
			EventUI.Eggs:FindFirstChild("Gold"):FindFirstChild("Number").Text = eggs["Gold"]
	
			EventUI.Number.Text = score
		end
	elseif kind == "Collected" then
		print(tab)
		if tab then
			if tab:FindFirstChild("Collected") == nil then
				Paths.Audio.Collected:Clone().Parent = tab
			end
			tab.Collected:Play()
		end
	end
end)

--- Event Functions ---
function CandyRush:EventStarted()
	if Participants:FindFirstChild(Paths.Player.Name) then
		Paths.Modules.Buttons:UIOff(Paths.UI.Center.EggHunt,true)
		workspace.Gravity = 160

		EventUI.Visible = true
	end
end


function CandyRush.InitiateEvent()
	
end

function CandyRush.EventEnded()
	workspace.Gravity = 196.2
end

--- Event Updating ---
function CandyRush:UpdateEvent(Info)
	
end


return CandyRush
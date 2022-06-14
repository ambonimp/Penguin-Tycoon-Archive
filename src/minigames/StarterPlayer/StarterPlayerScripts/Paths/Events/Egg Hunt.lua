local EggHunt = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants

local EventInfoUI = Paths.UI.Top.EventInfo
local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs["Egg Hunt"]
local FinishedUI = Paths.UI.Center.EggHuntFinished

local TotalEggs = 0
local Data = Services.RStorage.Remotes.GetStat:InvokeServer("Event")

local itemList  = {
	["Pink Bunny Ears"] = {Type = "Accessory" , Needed = 200},
	["Finding Egg"] = {Type = "Emote" , Needed = 400},
	["Bunny Hop"] = {Type = "Emote" , Needed = 500},
	["Eating Egg"] = {Type = "Emote" , Needed = 600},
	["Easter Basket"] = {Type = "Accessory" , Needed = 750},
}

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

function updateEggUI()
	if Data and Data[1] == "Egg Hunt" then
		local UI = Paths.UI.Center.EggHunt

		local Total = Data[2]["Blue"] + Data[2]["Red"] + Data[2]["Purple"] + Data[2]["Green"] + Data[2]["Gold"]
		UI.Eggs.Total.Number.Text = Total
		--[[
		UI.Eggs:FindFirstChild("Blue"):FindFirstChild("Number").Text = Data[2]["Blue"]
		UI.Eggs:FindFirstChild("Red"):FindFirstChild("Number").Text = Data[2]["Red"]
		UI.Eggs:FindFirstChild("Purple"):FindFirstChild("Number").Text = Data[2]["Purple"]
		UI.Eggs:FindFirstChild("Green"):FindFirstChild("Number").Text = Data[2]["Green"]
		UI.Eggs:FindFirstChild("Gold"):FindFirstChild("Number").Text = Data[2]["Gold"] 
		]]
		TotalEggs = Total

		for i,Unlockable in pairs (Paths.UI.Center.EggHunt.Unlockables.Frame:GetChildren()) do
			if Unlockable:IsA("Frame") and itemList[Unlockable.Name] then
				local Needed = itemList[Unlockable.Name].Needed
				if TotalEggs >= Needed then
					Unlockable.Claim.BackgroundColor3 = Color3.new(0.098039, 0.839215, 0)
					Unlockable.Claim.UIStroke.Color = Color3.new(0.090196, 0.619607, 0.023529)
					Unlockable.Claim.TextLabel.Text = "Claim"
				end
				if Data[3][Unlockable.Name] then
					Unlockable.Claim.BackgroundColor3 = Color3.new(0, 0.811764, 0.839215)
					Unlockable.Claim.UIStroke.Color = Color3.new(0.023529, 0.501960, 0.619607)
					Unlockable.Claim.TextLabel.Text = "Claimed"
				end
			end
		end
	end
end

Paths.UI.Center.EggHunt.MoreEggs.MouseButton1Down:Connect(function()
	Services.MPService:PromptProductPurchase(Paths.Player, 1258558775)
end)

function findTbl(playerName,EggsCollected)
	for i,v in pairs (EggsCollected) do
		if v[1] == playerName then return i end
	end
	return 0
end

Remotes.EggHunt.OnClientEvent:Connect(function(kind,tab,all)
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
				ui.PlayerName.Text = ""
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
		if tab then
			if tab:FindFirstChild("Collected") == nil then
				Paths.Audio.Collected:Clone().Parent = tab
			end
			tab.Collected:Play()
		end
		if all then
			Data = all
			updateEggUI()
		end
	end
end)

--- Event Functions ---
function EggHunt:EventStarted()
	if Participants:FindFirstChild(Paths.Player.Name) then
		Paths.Modules.Buttons:UIOff(Paths.UI.Center.EggHunt,true)
		workspace.Gravity = 160

		EventUI.Visible = true
	end
end


function EggHunt.InitiateEvent()
	
end

function EggHunt.EventEnded()
	workspace.Gravity = 196.2
end

--- Event Updating ---
function EggHunt:UpdateEvent(Info)
	
end

updateEggUI()
if Data then
	for i,Unlockable in pairs (Paths.UI.Center.EggHunt.Unlockables.Frame:GetChildren()) do
		local Needed = 0
		if Unlockable:IsA("Frame") and itemList[Unlockable.Name] then
			Needed = itemList[Unlockable.Name].Needed
			Unlockable.Price.Number.Text = Needed
			if TotalEggs >= Needed then
				Unlockable.Claim.BackgroundColor3 = Color3.new(0.098039, 0.839215, 0)
				Unlockable.Claim.UIStroke.Color = Color3.new(0.090196, 0.619607, 0.023529)
				Unlockable.Claim.TextLabel.Text = "Claim"
			end
			if Data[3][Unlockable.Name] then
				Unlockable.Claim.BackgroundColor3 = Color3.new(0, 0.811764, 0.839215)
				Unlockable.Claim.UIStroke.Color = Color3.new(0.023529, 0.501960, 0.619607)
				Unlockable.Claim.TextLabel.Text = "Claimed"
			end
		end
		if Unlockable:FindFirstChild("Claim") then
			Unlockable.Claim.MouseButton1Down:Connect(function()
				if TotalEggs >= Needed then
					Remotes.EggHunt:FireServer(Unlockable.Name)

					Unlockable.Claim.BackgroundColor3 = Color3.new(0, 0.811764, 0.839215)
					Unlockable.Claim.UIStroke.Color = Color3.new(0.023529, 0.501960, 0.619607)
					Unlockable.Claim.TextLabel.Text = "Claimed"
				end
			end)
		end
	end
end

local ProximityPrompt
if workspace:FindFirstChild("Easter") then
	ProximityPrompt = workspace.Easter.ProximityPart.Value:WaitForChild("ProximityPrompt")
end

if ProximityPrompt then
	ProximityPrompt.Triggered:Connect(function(player)
		if player == game.Players.LocalPlayer and Paths.UI.Center.TeleportConfirmation.Visible == false and Paths.UI.Center.BuyEgg.Visible == false and game.Players.LocalPlayer:GetAttribute("BuyingEgg") == false then
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.EggHunt,true)
		end
	end)
end

return EggHunt
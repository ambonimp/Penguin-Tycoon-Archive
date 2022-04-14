local EggHunt = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

--- Event Variables ---
local EventValues = Services.RStorage.Modules.EventsConfig.Values
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local Votes = Services.RStorage.Modules.EventsConfig.Votes

local EventInfoUI = Paths.UI.Top.EventInfo
local EventVotingUI = Paths.UI.Top.EventVoting
local EventPromptUI = Paths.UI.Top.EventPrompt
local EventUIs = Paths.UI.Right.EventUIs
local EventUI = EventUIs["Egg Hunt"]

local Data = Services.RStorage.Remotes.GetStat:InvokeServer("Event")

local itemList  = {
	["Backwards Cap"] = {Type = "Accessory" , Needed = {"Blue",150}},
	["Bear Hat"] = {Type = "Accessory" , Needed = {"Green",120}},
	["Cowboy"] = {Type = "Accessory" , Needed = {"Purple",70}},
	["Party Hat"] = {Type = "Accessory" , Needed = {"Red",50}},
	["Pink Sunhat"] = {Type = "Accessory" , Needed = {"Gold",30}},
}

function updateEggUI()
	if Data and Data[1] == "Egg Hunt" then
		local UI = Paths.UI.Center.EggHunt

		UI.Eggs:FindFirstChild("Blue"):FindFirstChild("Number").Text = Data[2]["Blue"]
		UI.Eggs:FindFirstChild("Red"):FindFirstChild("Number").Text = Data[2]["Red"]
		UI.Eggs:FindFirstChild("Purple"):FindFirstChild("Number").Text = Data[2]["Purple"]
		UI.Eggs:FindFirstChild("Green"):FindFirstChild("Number").Text = Data[2]["Green"]
		UI.Eggs:FindFirstChild("Gold"):FindFirstChild("Number").Text = Data[2]["Gold"]
	end
end

function findTbl(playerName,EggsCollected)
	for i,v in pairs (EggsCollected) do
		if v[1] == playerName then return i end
	end
	return 0
end

Remotes.EggHunt.OnClientEvent:Connect(function(kind,tab,all)
	if kind == "Update" then
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
		if tab:FindFirstChild("Collected") == nil then
			Paths.Audio.Collected:Clone().Parent = tab
		end
		tab.Collected:Play()
		if all then
			Data = all
			updateEggUI()
		end
	end
end)

--- Event Functions ---
function EggHunt:EventStarted()
	if Participants:FindFirstChild(Paths.Player.Name) then
		workspace.Gravity = 160
		local Map = workspace.Event["Event Map"]

		EventInfoUI.ExitEvent.Visible = true
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
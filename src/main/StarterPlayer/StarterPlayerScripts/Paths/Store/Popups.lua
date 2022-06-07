local Popups = {}

local Paths = require(script.Parent.Parent)
local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local PopupUI = UI.Top.Popup

local currentPass = nil
Popups.Gamepasses = {}

local lastAction = nil
local lastPopup = os.time()-(60*5)
local interval = 60*10
local lastChildrenTycoon = 0
local lastGems = 0

if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
	lastPopup = os.time()-(60*.5)
	interval = 60*1
end

local nameToId = {
	["Income"] = 25313170,
	["GoldRod"] = 28927736,
	["Luxury"] = 41205566,
	["Glider"] = 41205759,
	["GoldAxe"] = 43183311,
	["Jet"] = 45764173,
	["RainbowRod"] = 47438416,
	["Gems"] = 47438471,
	["Fish"] = 49090546,
}

function Popups.getAction()
	local Tool = Paths.Player:GetAttribute("Tool")
	local Vehicle = Paths.Player:GetAttribute("Vehicle")

	--Check tool
	if Tool and (Tool == "Fishing Rod" or Tool == "Gold Fishing Rod" or Tool == "Rainbow Fishing Rod") and not Paths.Player:GetAttribute("AFKFishing") then
		local ownsGold = Popups.ownsGamepass("GoldRod")
		local ownsRainbow = Popups.ownsGamepass("RainbowRod")
		local ownsThreeTimes = Popups.ownsGamepass("Fish")
		if not ownsGold then
			return "GoldRod"
		elseif not ownsRainbow and ownsGold then
			return "RainbowRod"
		elseif ownsRainbow and ownsGold and not ownsThreeTimes then
			return "Fish"
		end

	elseif Tool and Tool == "Axe" then
		local ownsGold = Popups.ownsGamepass("GoldAxe")
		if not ownsGold then
			return "GoldAxe"
		end
	elseif Tool and Tool == "Glider" then
		local ownsG = Popups.ownsGamepass("Glider")
		if not ownsG then
			return "Glider"
		end
	end

	--Check vehicle
	if Vehicle then
		if Vehicle == "Plane" then
			local ownsJet = Popups.ownsGamepass("Jet")
			if not ownsJet then
				return "Jet"
			end
		elseif (Vehicle == "Raft" or Vehicle == "Speedboat") then
			local ownsLuxury = Popups.ownsGamepass("Luxury")
			if not ownsLuxury then
				return "Luxury"
			end
		end
	end

	if #Paths.Tycoon.Tycoon:GetChildren() > lastChildrenTycoon then
		lastChildrenTycoon = #Paths.Tycoon.Tycoon:GetChildren()
		return "Income"
	elseif Paths.Player:GetAttribute("Gems") > lastGems then
		lastGems = Paths.Player:GetAttribute("Gems")
		return "Gems"
	end

	return nil
end

function Popups.ownsGamepass(name)
	if Modules.Gamepasses then
		return Modules.Gamepasses.Owned[nameToId[name]]
	else
		return false
	end
end

function Popups.load(passes)
	for i,tbl in pairs (passes) do
		Popups.Gamepasses[tbl[1]] = tbl[2]
	end

	PopupUI.Purchase.MouseButton1Down:Connect(function()
		Services.MPService:PromptGamePassPurchase(Paths.Player, currentPass)
		PopupUI.Visible = false
	end)

	PopupUI.No.MouseButton1Down:Connect(function()
		PopupUI.Visible = false
	end)
end

function showGamepass(name)
	if Popups.ownsGamepass(name) then return "Owns" end
	local id = nameToId[name]
	local Info = Services.MPService:GetProductInfo(id, Enum.InfoType.GamePass)
	if Info["IsForSale"] then
		local tbl = Popups.Gamepasses[id]
		currentPass = id
		PopupUI.PassName.Text = Info["Name"]
		PopupUI.Purchase.TheText.Text = Modules.Format:FormatComma(Info["PriceInRobux"])
		PopupUI.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
		PopupUI.Visible = true
		Paths.Audio.Notif:Play()
		return true
	end
	return false
end

task.spawn(function()
	repeat task.wait(1) until Paths.Tycoon
	lastGems = Paths.Player:GetAttribute("Gems") or 0
	lastChildrenTycoon = #Paths.Tycoon.Tycoon:GetChildren()
	while true do
		local action = Popups.getAction()
		if action then
			lastAction = action
		end
		if os.time()-lastPopup>=interval and Modules.Gamepasses then
			if lastAction then
				local showed = showGamepass(action)
				if showed ~= "Owns" then
					lastPopup = os.time()
				end
			end
		end
		task.wait(5)
	end
end)

return Popups
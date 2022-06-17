local Popups = {}

local Paths = require(script.Parent.Parent)
local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local PopupUI = UI.Top.Popups.Popup
local PopupRegularUI = UI.Top.Popups.PopupRegular

local currentPass = nil
Popups.Gamepasses = {}

local regularlastPopup = os.time()-(60*1.5)
local regularPopupInterval = 60*3
local popupFunction = nil
local lastAction = nil
local lastPopup = os.time()-(60*5)
local interval = 60*10
local lastChildrenTycoon = 0
local lastGems = 0
local barTime = 15

if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
	lastPopup = os.time()-(60*.5)
	interval = 60*1

	regularlastPopup = os.time()-(60*.25)
	regularPopupInterval = 60*.5
	barTime = 5
end

local regularNames = {"Twitter","Discord","Group","Like","Friend"}
local regularPopups = {
	["Twitter"] = {"Gain 10% extra income by following us on Twitter!","rbxassetid://9852947672","DONE!",nil,function()
		return Modules.Verification.isVerified
	end},
	["Discord"] = {"Join our community to receive 100 gems!","rbxassetid://9846753652","DONE!",nil,function()
		return Modules.DiscordVerification.isVerified
	end},
	["Group"] = {"Join the group to receive $5,000 money!","rbxassetid://9852947894","DONE!",nil,function()
		return Modules.GroupReward.IsClaimed
	end},
	["Like"] = {"Unlock a new code when this game reaches 150k likes!","rbxassetid://1409420127","DONE!",nil},
	["Friend"] = {"Invite your friends to play with them!","rbxassetid://9852948068","YES!",function()
		local canInvite = game:GetService("SocialService"):CanSendGameInviteAsync(Paths.Player)
		if canInvite then
			game:GetService("SocialService"):PromptGameInvite(Paths.Player)
		end
	end}
}

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

	if #Paths.Tycoon.Tycoon:GetChildren() > lastChildrenTycoon then
		lastChildrenTycoon = #Paths.Tycoon.Tycoon:GetChildren()
		return "Income"
	elseif Paths.Player:GetAttribute("Gems") > lastGems then
		lastGems = Paths.Player:GetAttribute("Gems")
		return "Gems"
	end

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
		Remotes.PopupPrompt:FireServer(currentPass)
		PopupUI.Visible = false
	end)

	PopupUI.No.MouseButton1Down:Connect(function()
		PopupUI.Visible = false
	end)

	PopupRegularUI.Done.MouseButton1Down:Connect(function()
		if popupFunction then
			popupFunction()
		end
		PopupRegularUI.Visible = false
	end)

	PopupRegularUI.No.MouseButton1Down:Connect(function()
		PopupRegularUI.Visible = false
	end)
end

function showGamepass(name)
	if Popups.ownsGamepass(name) then return "Owns" end
	local id = nameToId[name]
	if id then
		local Info = Services.MPService:GetProductInfo(id, Enum.InfoType.GamePass)
		if Info["IsForSale"] then
			PopupUI.Bar.Size = UDim2.new(.8,0,.1,0)
			PopupRegularUI.Visible = false
			local desc = Popups.Gamepasses[id]
			currentPass = id
			PopupUI.Description.Text = desc
			PopupUI.PassName.Text = Info["Name"]
			PopupUI.Purchase.TheText.Text = Modules.Format:FormatComma(Info["PriceInRobux"])
			PopupUI.Icon.Image = "rbxassetid://"..Info["IconImageAssetId"]
			PopupUI.Visible = true
			Paths.Audio.Notif:Play()
			task.spawn(function()
				PopupUI.Bar:TweenSize(UDim2.new(0,0,.1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,barTime,true)
				task.wait(barTime)
				if PopupUI.Visible then
					PopupUI.Visible = false
				end
			end)
			return true
		end
		return false
	end
end

function showRegular(name)
	if PopupUI.Visible then return end
	local tbl = regularPopups[name]
	local text = tbl[1]
	local icon = tbl[2]
	local button = tbl[3]
	local fun = tbl[4]
	if tbl[5] then
		if tbl[5]() then return end
	end
	if fun then
		popupFunction = fun
	else
		popupFunction = nil
	end
	PopupRegularUI.Bar.Size = UDim2.new(.8,0,.1,0)
	PopupRegularUI.Description.Text = text
	PopupRegularUI.Icon.Image = icon
	PopupRegularUI.Done.TheText.Text = button
	task.spawn(function()
		PopupRegularUI.Bar:TweenSize(UDim2.new(0,0,.1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,barTime,true)
		task.wait(barTime)
		if PopupRegularUI.Visible then
			PopupRegularUI.Visible = false
		end
	end)
	PopupRegularUI.Visible = true
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
				local showed = showGamepass(lastAction)
				lastAction = nil
				if showed ~= "Owns" then
					lastPopup = os.time()
				end
			end
		end
		if os.time()-regularlastPopup>=regularPopupInterval then
			regularlastPopup = os.time()
			showRegular(regularNames[math.random(1,#regularNames)])
		end
		task.wait(5)
	end
end)

return Popups
local Income = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

local Day = os.date("%A")
local Mult = 1

if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
	Mult = 2
else
	Mult = 1
end

--- Other Variables ---
local INCOME_INTERVAL = 3
local GEM_INTERVAL = 15*60

local IsTesting = (game.GameId == 3425588324)
local IsQA = (game.GameId == 3425594443)

if IsTesting or IsQA then
	GEM_INTERVAL = 3*60
end


--- Income Function ---
function Income:AddMoney(Player, Amount,isBought)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		if isBought == nil then
			Amount = Amount*Mult
		end
		if Player:GetAttribute("x3MoneyBoost") then
			Amount = Amount*3
		end

		Data["Stats"]["Total Money"] += Amount

		Data["Money"] += Amount
		Player:SetAttribute("Money", Data["Money"])
	end
end


function Income:AddGems(Player, Amount, Source)
	if not Source then
		Source = "Gameplay"
	end
	
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		if Amount > 0 and Source ~= "Bought" and Source ~= "Code" then
			Amount = Amount * Mult * Data["Gem Multiplier"]
		end
		Data["Stats"]["Total Gems"] += Amount 

		Data["Gems"] += Amount
		Player:SetAttribute("Gems", Data["Gems"])
		
		-- Fires a bindable event to notify server that this event has occured with given data
		-- Used normally to integrate with Game Analytics / Dive / Playfab
		local success, msg = pcall(function()
			EventHandler:Fire("gemsAdded", Player, {
				amount = Amount,
				source = Source
			})
		end)
	end
end


function Income:IncomeLoop()
	while true do
		for i, Player in pairs(game.Players:GetPlayers()) do
			local Data = Modules.PlayerData.sessionData[Player.Name]
			
			if Data then
				local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])
				
				if PlayerIncome > 0 then
					-- Add Money
					Income:AddMoney(Player, PlayerIncome)
				end
				
				-- Add to total playtime
				Data["Stats"]["Total Playtime"] += INCOME_INTERVAL
			end
		end
		
		wait(INCOME_INTERVAL)
	end
end

function Income:GemLoop()
	while true do
		task.wait(1)
		Day = os.date("%A")
		if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
			Mult = 2
		else
			Mult = 1
		end
	end
end


coroutine.wrap(function()
	Income:IncomeLoop()
end)()

coroutine.wrap(function()
	Income:GemLoop()
end)()


return Income
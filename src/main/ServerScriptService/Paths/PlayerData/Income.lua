local Income = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

local Day = os.date("%A")
local Mult = 1
--[[
if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
	Mult = 2
else
	Mult = 1
end]]

--- Other Variables ---
local INCOME_INTERVAL = 3
local GEM_INTERVAL = 15*60

local IsTesting = (game.GameId == 3425588324)
local IsQA = (game.GameId == 3425594443)

if IsTesting or IsQA then
	if IsQA then
		Mult = 1
	end

	GEM_INTERVAL = 3*60
end

local function IncrementStoredIncome(Data, CollectPoint, Addend)
	local PlayerIncome = CollectPoint:GetAttribute("Income") + Addend
	Data["Stored Income"] = PlayerIncome
	CollectPoint:SetAttribute("Income", PlayerIncome)
	CollectPoint.Hitbox.BillboardGui.Value.Text = "$" .. Modules.Format:FormatAbbreviated(PlayerIncome)
end

local function SetStoredIncome(Data, CollectPoint, Value)
	CollectPoint:SetAttribute("Income", Value)
	Data["Stored Income"] = Value
	CollectPoint.Hitbox.BillboardGui.Value.Text = "$" .. Modules.Format:FormatAbbreviated(Value)
end

--- Income Function ---
function Income:AddMoney(Player, Amount,isBought)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		if isBought == nil then
			Amount = Amount * Mult
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
			task.spawn(function()
				local Data = Modules.PlayerData.sessionData[Player.Name]
				local Tycoon = Modules.Ownership:GetPlayerTycoon(Player)
				
				if not Tycoon or not Data then return end
				local PlayerIncome = math.floor(Data["Income"] * Data["Income Multiplier"])

				if PlayerIncome > 0 then
					local CollectPoint = Tycoon:FindFirstChild("IncomeCollectPoint")
					if CollectPoint then

						-- Add Money
						local mult = Paths.Modules.Pets.getBonus(Player,"Paycheck","Income")
						PlayerIncome = math.floor(PlayerIncome * mult)

						if Data["Auto Collect"] then
							if CollectPoint:GetAttribute("Income") then
								PlayerIncome += CollectPoint:GetAttribute("Income") * mult
								CollectPoint.Hitbox.BillboardGui.Auto.Visible = true

								SetStoredIncome(Data, CollectPoint, 0)
							end

							Income:AddMoney(Player, PlayerIncome)
						else
							IncrementStoredIncome(Data, CollectPoint, PlayerIncome)
						end

						-- Add to total playtime
						Data["Stats"]["Total Playtime"] += INCOME_INTERVAL

					end

				end

			end)

		end
		
		task.wait(INCOME_INTERVAL)

	end

end

function Income:GemLoop()
	while true do
		task.wait(1)
		Day = os.date("%A")
		--[[
		if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
			Mult = 2
		else
			Mult = 1
		end]]

		if IsQA then
			Mult = 1
		end

	end

end

Remotes.CollectIncome.OnServerEvent:Connect(function(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data and not Data["Auto Collect"] then
		local CollectPoint = Modules.Ownership:GetPlayerTycoon(Player).IncomeCollectPoint

		local PlayerIncome = CollectPoint:GetAttribute("Income")
		if PlayerIncome then
			Income:AddMoney(Player, PlayerIncome)
			SetStoredIncome(Data, CollectPoint, 0)

		end

	end

end)

coroutine.wrap(function()
	Income:IncomeLoop()
end)()

coroutine.wrap(function()
	Income:GemLoop()
end)()


return Income
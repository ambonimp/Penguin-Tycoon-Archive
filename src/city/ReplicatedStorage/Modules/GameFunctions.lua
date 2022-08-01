local GameFunctions = {}

--- Variables ---
local MPService = game:GetService("MarketplaceService")
local MoneyProducts = {
	[1224873708] = {["Base"] = 1.0000, ["Bonus"] = 1}, 
	[1224873843] = {["Base"] = 3.2900, ["Bonus"] = 1.05}, 
	[1224873847] = {["Base"] = 8.2900, ["Bonus"] = 1.15}, 
	[1224873846] = {["Base"] = 20.790, ["Bonus"] = 1.25}, 
	[1224873844] = {["Base"] = 41.630, ["Bonus"] = 1.40}, 
	[1224873842] = {["Base"] = 104.13, ["Bonus"] = 1.60}
}
local BASE_INCOME_REWARD = 30 -- The amount of seconds of progress for R$ 24 worth of robux (Base = 1)


--- Functions ---
function GameFunctions:GetRequiredMoneyProduct(Player, MoneyRequired)
	local PlayerIncome = Player:GetAttribute("Income")
	local PlayerMoney = Player:GetAttribute("Money")

	local ProductChosen = 1224873708
	local ProductAmount = 1000000000000

	for Product, Info in pairs(MoneyProducts) do
		local RewardAmount = GameFunctions:GetMoneyProductReward(Product, PlayerIncome,Player)

		if PlayerMoney + RewardAmount >= MoneyRequired and RewardAmount < ProductAmount then
			ProductAmount = RewardAmount
			ProductChosen = Product
		end
	end

	return ProductChosen
end

function GameFunctions:GetRequiredGemProduct(GemsRequired)
	local ChosenProduct = 1266975715
	local ChosenAmount = 4250
	for Product, Amount in pairs(GemProducts) do
		if Amount > GemsRequired and Amount < ChosenAmount then
			ChosenProduct = Product
			ChosenAmount = Amount
		end
	end

	return ChosenProduct
end


function GameFunctions:GetMoneyProductReward(Product, Income)
	Product = tonumber(Product)
	local Base1Reward = 500 + (Income+1)/3 * BASE_INCOME_REWARD
	local BaseReward = Base1Reward * MoneyProducts[Product]["Base"]
	local TotalReward = BaseReward * MoneyProducts[Product]["Bonus"]
	
	return math.ceil(TotalReward)
end


--- Penguin Functions ---
function GameFunctions:GetPenguinIncome(Income, Level)
	if Level == 30 then
		Level = 10.01
	end
	local LevelIncome = math.floor(Income^(1+(Level-1)/80) * Level * 1.2)
	local NumLength = string.len(tostring(LevelIncome)) - 3
	local RoundingMultiplier = 10 ^ NumLength

	local FinalIncome = math.ceil(LevelIncome/RoundingMultiplier) * RoundingMultiplier
	if Level > 10 then
		FinalIncome = FinalIncome * 2
	end
	return FinalIncome
end

function GameFunctions:GetPenguinPrice(Price, Level)
	local LevelPrice = math.floor(Price^(1+(Level-1)/80) * (1 + Level/4))
	local NumLength = string.len(tostring(LevelPrice)) - 3
	if NumLength == 0 then NumLength = 1 end
	local RoundingMultiplier = 10 ^ NumLength

	local FinalPrice = math.floor(LevelPrice/RoundingMultiplier) * RoundingMultiplier
	return FinalPrice
end


function GameFunctions:GetPlayerPenguinIncome(Level)
	local Income = Level * 2.2

	if Level < 20 then
		Income = math.floor(Income ^ (1.05 + (Level/50)))
	elseif Level >= 20 and Level < 30 then
		Income = math.floor(Income ^ (1.12 + (Level/60)))
	else
		Income = math.floor(Income ^ (1.28 + (Level/90)))
	end

	local NumLength = string.len(tostring(Income)) - 3
	local RoundingMultiplier = 10 ^ NumLength

	return math.floor(Income/RoundingMultiplier) * RoundingMultiplier
end

function GameFunctions:GetPlayerPenguinPrice(Level)
	local Price = Level * 40

	if Level < 20 then
		Price = math.floor(Price ^ (1.1 + (Level/30)))
	elseif Level >= 20 and Level < 30 then
		Price = math.floor(Price ^ (1.25 + (Level/40)))
	else
		Price = math.floor(Price ^ (1.63 + (Level/85)))
	end

	local NumLength = string.len(tostring(Price)) - 3
	if NumLength == 0 then NumLength = 1 end
	local RoundingMultiplier = 10 ^ NumLength

	return math.floor(Price/RoundingMultiplier) * RoundingMultiplier
end





-- test scripts

--function GetPrice(Level)
--	local Price = Level * 40
	
--	if Level < 20 then
--		Price = math.floor(Price ^ (1.1 + (Level/30)))
--	elseif Level >= 20 and Level < 30 then
--		Price = math.floor(Price ^ (1.25 + (Level/40)))
--	else
--		Price = math.floor(Price ^ (1.63 + (Level/85)))
--	end

--	local NumLength = string.len(tostring(Price)) - 3
--	if NumLength == 0 then NumLength = 1 end
--	local RoundingMultiplier = 10 ^ NumLength

--	return math.floor(Price/RoundingMultiplier) * RoundingMultiplier
--end

--function GetIncome(Level)
--	local Income = Level * 2.2

--	if Level < 20 then
--		Income = math.floor(Income ^ (1.05 + (Level/50)))
--	elseif Level >= 20 and Level < 30 then
--		Income = math.floor(Income ^ (1.12 + (Level/60)))
--	else
--		Income = math.floor(Income ^ (1.28 + (Level/90)))
--	end
	
--	local NumLength = string.len(tostring(Income)) - 3
--	local RoundingMultiplier = 10 ^ NumLength

--	return math.floor(Income/RoundingMultiplier) * RoundingMultiplier
--end

--local x = 0
--for i = 1, 40, 1 do
--	x+=GetPrice(i)
--	print("Level: "..i, " Price: "..GetPrice(i), " Income: "..GetIncome(i))
--end
--print(x)

--local x = 0
--local Income = 4
--local Price = 140
--for i = 1, 50, 1 do
--	x+=GetPrice(Price, i)
--	print("Level: "..i, "Price: "..GetPrice(Price, i), "Income: "..GetIncome(Income, i))
--end
--print(x)


return GameFunctions
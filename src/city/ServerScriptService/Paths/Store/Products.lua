-- Handles all developer products; Buying money, accessories, eyes, tycoon products and upgrading penguins

local Products = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

--- Product Variables ---
local BoostsProducts = {[1266980995] = "x3 Money",[1266981097] = "Super Fishing Luck",[1266981160] = "Ultra Fishing Luck",[1266981422] = "Bundle"}
local MoneyProducts = {[1224873708] = true, [1224873843] = true, [1224873847] = true, [1224873846] = true, [1224873844] = true, [1224873842] = true}
local GemProducts = {[1266975588] = 100, [1266975627] = 275, [1266975643] = 725, [1266975658] = 1500, [1266975679] = 2400, [1266975715] = 4250}
local AccessoryProducts = {[1231222251] = true, [1231222252] = true, [1231222253] = true}
local OutfitProducts = {[1259048717] = true, [1259048739] = true, [1259048664] = true}
local EyesProducts = {[1232615468] = true}

local PenguinProducts = {
	[1231367104] = true, [1231367150] = true, [1231367190] = true, -- Basic (59), Medium (119), High (199)
	[1231367260] = true, [1231367285] = true, [1231367306] = true -- Expensive (449), Extreme (999), Insane (2499)
} 

local TycoonProducts = {
	[1224873709] = "Fish Shop#1", [1224873705] = "Hot Chocolate#1", [1224873707] = "Sawmill#1", [1224873704] = "Royal Egg#1", [1229622731] = "Vending Machine#1", 
	[1229624896] = "Massage Table#1", [1229625136] = "Beehive#1", [1229627953] = "Ice Cream Stand#1", [1229628483] = "Tiki Bar#1", [1229629428] = "Luxury Boat#1", 
	[1232236945] = "Planets#1", [1233161301] = "Watch Tower#1", [1234046860] = "Globe#1", [1234046883] = "Space Rocks#1", [1240569736] = "Powered Glider#1"
}

local EggProducts = {
	[1251433285]  = "Egg1"
}

local Bundles = {
	[1287414995] = 1
}


Services.MPService.PromptProductPurchaseFinished:Connect(function(id, assetId, isPurchased)
	local player
	for i,v in pairs (game.Players:GetPlayers()) do
		if v.UserId == id then
			player = v
			break
		end
	end
	if isPurchased == false and EggProducts[assetId] and player then
		Remotes.ResetProductPurchase:FireClient(player)
	end
end)

--- Functions ---
-- Fired when a product is bought - this does all the checks and fires the correct function depending on which product was purchased
Services.MPService.ProcessReceipt = function(purchaseInfo)
	local product = purchaseInfo.ProductId
	
	local PlayerID = purchaseInfo.PlayerId
	local Player = game.Players:GetPlayerByUserId(PlayerID)

	if Modules.PlayerData.sessionData[Player.Name] then
		-- Money Products
		--Gem Products
		if GemProducts[product] then
			Modules.Income:AddGems(Player,GemProducts[product],"Bought")
		elseif BoostsProducts[product] then
			if BoostsProducts[product] == "Bundle" then
				Modules.Boosts.givePlayerBoost(Player,"x3 Money",4)
				Modules.Boosts.givePlayerBoost(Player,"Super Fishing Luck",3)
				Modules.Boosts.givePlayerBoost(Player,"Ultra Fishing Luck",3)
			else
				Modules.Boosts.givePlayerBoost(Player,BoostsProducts[product],1)
			end
		-- Money Products
		elseif MoneyProducts[product] then
			local PlayerIncome = Modules.PlayerData.sessionData[Player.Name]["Income"]
			local Reward = Modules.GameFunctions:GetMoneyProductReward(product, PlayerIncome,Player)
			Modules.Income:AddMoney(Player, Reward,true)
			
			
		-- Tycoon Products
		elseif TycoonProducts[product] then
			local ButtonName = TycoonProducts[product]
			Modules.Purchasing:ItemPurchased(Player, ButtonName, true)
			
			
		-- Accessory Products
		elseif AccessoryProducts[product] then
			Modules.Accessories:AccessoryPurchased(Player)
			
		-- Outfit Products
		elseif Bundles[product] then
			local bundle = Paths.Modules.AllOutfits.Bundles[Bundles[product]]
			for i,item in pairs (bundle.Outfits) do
				local name = item[1]
				local typ = item[2]

				Modules.Accessories:ItemAcquired(Player, name, typ)
				task.wait(1)
			end
		elseif OutfitProducts[product] then
			Modules.Accessories:OutfitPurchased(Player)
				
			
		-- Eyes Products
		elseif EyesProducts[product] then
			Modules.Accessories:EyesPurchased(Player)
			
			
		-- Penguin Products
		elseif PenguinProducts[product] then
			Products:PenguinUpgradePurchased(Player)
			
		elseif EggProducts[product] then
			Modules.Pets.BuyPet(Player,EggProducts[product],true)
			
		-- Refresh Store
		elseif product == 1233004731 then
			Modules.Accessories:RefreshStore(Player)

		--50 eggs event product
		elseif product == 1258558775 then
			local data =  Modules.PlayerData.sessionData[Player.Name]
			if data then
				data["Event"][2]["Blue"] += 10
				data["Event"][2]["Green"] += 10
				data["Event"][2]["Purple"] += 10
				data["Event"][2]["Red"] += 10
				data["Event"][2]["Gold"] += 10
				Remotes.EggHunt:FireClient(Player,"Collected",nil,data["Event"])
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end
	end
	
		--[[
		Fires a bindable event to notify server that this event has occured with given data
		Used normally to integrate with Game Analytics / Dive / Playfab
	]]--
	pcall(function()
		local productData = game:GetService("MarketplaceService"):GetProductInfo(product)
		EventHandler:Fire("transactionCompleted", Player, {
			productId = product,
			productDetails = productData
		})
	end)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end


--- Penguin Leveling Up ---
local PenguinPurchaseLevels = {
	[1] = 1231367104, [2] = 1231367150, [3] = 1231367190, -- Basic (59), Medium (119), High (199)
	[4] = 1231367260, [5] = 1231367285, [6] = 1231367306 -- Expensive (449), Extreme (999), Insane (2499)
}
local PurchaseDBs = {}

-- Upgrading penguins with robux
-- Player: Object, ActionType: String, Penguin: Object/Model
Remotes.Store.OnServerEvent:Connect(function(Player, ActionType, Penguin)
	if ActionType == "Penguin" and not PurchaseDBs[Player.Name] and Modules.PlayerData.sessionData[Player.Name] then
		if Modules.PlayerData.sessionData[Player.Name]["Penguins"][Penguin.Name] or Penguin == Player.Character then
			local Data = Modules.PlayerData.sessionData[Player.Name]
			local PlayerIncome = Data["Income"]
			
			-- Get the level of purchase 
			local Income
			local UpgradePrice
			
			if Penguin == Player.Character then
				local Level = Data["My Penguin"]["Level"]
				UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(Level + 1)
				Income = Modules.GameFunctions:GetPlayerPenguinIncome(Level)
				
			elseif Penguin:GetAttribute("Income") then
				local Level = Data["Penguins"][Penguin.Name]["Level"]
				UpgradePrice = Modules.GameFunctions:GetPenguinPrice(Penguin:GetAttribute("Price"), Level + 1)
				Income = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), Level)
				
				if Level >= Modules.GameInfo.MAX_PENGUIN_LEVEL then return end
			end
			
			-- 6 different tiers of leveling up, the further they are the more expensive it gets, so they can't just p2w to #1
			local PurchaseLevel = 1
			
			if Income >= 200 and Income < 450 then
				PurchaseLevel = 2
			elseif Income >= 450 and Income < 1250 then
				PurchaseLevel = 3
			elseif Income >= 1250 and Income < 2500 then
				PurchaseLevel = 4
			elseif Income >= 2500 and Income < 10000 then
				PurchaseLevel = 5
			elseif Income >= 10000 then
				PurchaseLevel = 6
			end
			
			local ProductID = PenguinPurchaseLevels[PurchaseLevel]

			PurchaseDBs[Player.Name] = Penguin 
			Services.MPService:PromptProductPurchase(Player, ProductID)
		end
	end
end)

Services.MPService.PromptProductPurchaseFinished:Connect(function(UserID, ProductID, Purchased)
	PurchaseDBs[game.Players:GetNameFromUserIdAsync(UserID)] = nil
end)

function Products:PenguinUpgradePurchased(Player)
	if Modules.PlayerData.sessionData[Player.Name] and PurchaseDBs[Player.Name] then
		local Penguin = PurchaseDBs[Player.Name]
		
		local Success, Info = Modules.Penguins:UpgradePenguin(Player, Penguin)
		Remotes.Store:FireClient(Player, "Penguin Upgraded", Penguin, Success)
		
		wait()
		PurchaseDBs[Player.Name] = nil
	end
end


--- Tycoon Products ---
function Products:PromptRobuxItemPurchase(Player, ProductID)
	Services.MPService:PromptProductPurchase(Player, ProductID)
end


return Products
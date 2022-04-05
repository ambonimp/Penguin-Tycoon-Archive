-- Handles the purchasing and loading of; accessories (hats) and eyes

local Accessories = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

--- Functions ---
-- The function to put the item into the player's data and fire to the client to update it for the player
-- Player: Object, Item: String (name of the item), ItemType: String (item type, "Accessory" or "Eyes")
function Accessories:ItemAcquired(Player, Item, ItemType)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	if Data then
		local PlayerItems 
		if ItemType == "Accessory" then
			PlayerItems = Data["Accessories"]
		elseif ItemType == "Eyes" then
			PlayerItems = Data["Eyes"]
		end
		
		if not PlayerItems[Item] then
			PlayerItems[Item] = true
			Remotes.Store:FireClient(Player, ItemType, Item, true)
		end
	end
end



--- Collecting Accessories ---
-- This part connects a touched function to the physical accessories on the 4 islands in the middle, which when touched give the accessory to the player
local TouchDBs = {}

for i, Accessory in pairs(workspace["Collectable Accessories"]:GetChildren()) do
	local Reward = Accessory:GetAttribute("Reward")
	
	if Reward and Accessory:FindFirstChild("Circle") then
		Accessory.Circle.Touched:Connect(function(Part)
			if Part.Parent:FindFirstChild("Humanoid") then
				local Char = Part.Parent
				local Player = game.Players:GetPlayerFromCharacter(Char)
				
				if Char and Player and not TouchDBs[Player.Name] then
					TouchDBs[Player.Name] = true
					
					Accessories:ItemAcquired(Player, Reward, "Accessory")
					
					task.wait(1)
					TouchDBs[Player.Name] = nil
				end
			end
		end)
	end
end



--- Purchasing Accessories ---
local PurchaseDBs = {}

-- Handles all the events for purchasing accessories
-- Player:Object, ActionType: String (the action that is to be done, currently "Buy Item" or "Rotate Store")
-- Item: String (name of the item being purchased), ItemType: String (item type"), CurrencyType: String ("Robux" or "Gems")
Remotes.Store.OnServerEvent:Connect(function(Player, ActionType, Item, ItemType, CurrencyType)
	local data = Modules.PlayerData.sessionData[Player.Name]
	
	if data and ActionType == "Buy Item" and not PurchaseDBs[Player.Name] then
		if not Modules.PlayerData.sessionData[Player.Name][ItemType.." Rotation"][Item] then return end
		
		local Module 
		if ItemType == "Accessory" then
			Module = Modules.AllAccessories
		elseif ItemType == "Eyes" then
			Module = Modules.AllEyes
		end
		
		if CurrencyType == "Robux" then
			PurchaseDBs[Player.Name] = Item 
			
			local Info = Module.All[Item]
			local ProductID = Module.RarityInfo[Info.Rarity].ID
			
			Services.MPService:PromptProductPurchase(Player, ProductID)
			
		elseif CurrencyType == "Gems" then
			local Rarity = Module.All[Item].Rarity
			
			local Price = Module.RarityInfo[Rarity].PriceInGems
			local PlayerGems = data.Gems
			
			if PlayerGems >= Price then
				data.Gems -= Price
				Player:SetAttribute("Gems", data.Gems)
				Accessories:ItemAcquired(Player, Item, ItemType)
				
				--[[
					Fires a bindable event to notify server that this event has occured with given data
					Used normally to integrate with Game Analytics / Dive / Playfab
				]]--
				local success, msg = pcall(function()
					EventHandler:Fire("transactionCompleted", Player, {})
				end)
			end
		end

	elseif ActionType == "Rotate Store" then
		local Data = Modules.PlayerData.sessionData[Player.Name]

		if Data then
			local RotationTimer = Data["Rotation Timer"]

			local TimeSinceRotation = os.time() - RotationTimer
			local TimeUntilRotation = Modules.AllAccessories.RotationInterval - TimeSinceRotation

			if TimeUntilRotation <= 10 then
				Accessories:RefreshStore(Player)
			end
		end
	end
end)


-- refreshes the store for the Player: Object (chooses 6 random accessories and eyes)
function Accessories:RefreshStore(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	if Data then
		Data["Rotation Timer"] = os.time()
		Data["Accessory Rotation"] = Modules.AllAccessories:ChooseStoreAccessories()
		Data["Eyes Rotation"] = Modules.AllEyes:ChooseStoreEyes()
		Remotes.Store:FireClient(Player, "Store Rotated")
	end
end


-- we use only 1 Developer Product for each rarity of itemtype. i.e. all 'Rare' hats are purchased using the same developer product ID.
-- 
Services.MPService.PromptProductPurchaseFinished:Connect(function(UserID, ProductID, Purchased)
	PurchaseDBs[game.Players:GetNameFromUserIdAsync(UserID)] = nil
end)

function Accessories:AccessoryPurchased(Player)
	if Modules.PlayerData.sessionData[Player.Name] and PurchaseDBs[Player.Name] then
		local Accessory = PurchaseDBs[Player.Name]
		Accessories:ItemAcquired(Player, Accessory, "Accessory")
		wait()
		PurchaseDBs[Player.Name] = nil
	end
end

function Accessories:EyesPurchased(Player)
	if Modules.PlayerData.sessionData[Player.Name] and PurchaseDBs[Player.Name] then
		local Eyes = PurchaseDBs[Player.Name]
		Accessories:ItemAcquired(Player, Eyes, "Eyes")
		wait()
		PurchaseDBs[Player.Name] = nil
	end
end


return Accessories
local Accessories = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local HAT_RARITY_ACHIEVEMENTS = {
	Rare = 20,
	Epic = 21,
	Legendary = 22
}

--- Functions ---
function Accessories:ItemAcquired(Player, Item, ItemType)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		local Path
		if ItemType == "Accessory" then
			Path = "Accessories"
		elseif ItemType == "Eyes" then
			Path = "Eyes"
		elseif ItemType == "Outfits" then
			Path = "Outfits"
		end

		local PlayerItems = Data[Path]
		local Info = Modules["All" .. Path].All[Item]
		if Info and not PlayerItems[Item] then
			PlayerItems[Item] = true

			if ItemType == "Accessory" then
				if Info.Achievement then
					Modules.Achievements.Progress(Player, HAT_RARITY_ACHIEVEMENTS[Info.Rarity])
				end
			elseif ItemType == "Eyes" then
				Modules.Achievements.Progress(Player, 23)
			end

			Remotes.Store:FireClient(Player, ItemType, Item, true)
		else
			warn("INVALID ITEM:", Item, ItemType)
		end

	end

end

--- Collecting Accessories ---
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
					Modules.Achievements.Progress(Player, 13)

					task.wait(1)
					TouchDBs[Player.Name] = nil
				end

			end

		end)

	end

end



--- Purchasing Accessories ---
local PurchaseDBs = {}

function Accessories:RefreshStore(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		Data["Rotation Timer"] = os.time()
		Data["Accessory Rotation"] = Modules.AllAccessories:ChooseStoreAccessories()
		--Data["Outfits Rotation"] = Modules.AllOutfits:ChooseStoreAccessories()
		Data["Eyes Rotation"] = Modules.AllEyes:ChooseStoreEyes()
		Remotes.Store:FireClient(Player, "Store Rotated")
	end
end

Services.MPService.PromptProductPurchaseFinished:Connect(function(UserID, ProductID, Purchased)
	PurchaseDBs[game.Players:GetNameFromUserIdAsync(UserID)] = nil
end)

function Accessories:OutfitPurchased(Player)
	if Modules.PlayerData.sessionData[Player.Name] and PurchaseDBs[Player.Name] then
		local Outfit = PurchaseDBs[Player.Name]
		Accessories:ItemAcquired(Player, Outfit, "Outfits")
		task.wait()
		PurchaseDBs[Player.Name] = nil
	end
end


function Accessories:AccessoryPurchased(Player)
	if Modules.PlayerData.sessionData[Player.Name] and PurchaseDBs[Player.Name] then
		local Accessory = PurchaseDBs[Player.Name]
		Accessories:ItemAcquired(Player, Accessory, "Accessory")
		task.wait()
		PurchaseDBs[Player.Name] = nil
	end
end

function Accessories:EyesPurchased(Player)
	if Modules.PlayerData.sessionData[Player.Name] and PurchaseDBs[Player.Name] then
		local Eyes = PurchaseDBs[Player.Name]
		Accessories:ItemAcquired(Player, Eyes, "Eyes")
		task.wait()
		PurchaseDBs[Player.Name] = nil
	end
end



Remotes.Store.OnServerEvent:Connect(function(Player, ActionType, Item, ItemType, CurrencyType)
	local data = Modules.PlayerData.sessionData[Player.Name]

	if data and ActionType == "Buy Item" and not PurchaseDBs[Player.Name] then
		if ItemType ~= "Outfits" then
			--if not Modules.PlayerData.sessionData[Player.Name][ItemType.." Rotation"][Item] then return end
		end
		local n = "Accessories"
		local Module
		if ItemType == "Accessory" then
			Module = Modules.AllAccessories
		elseif ItemType == "Eyes" then
			n = ItemType
			Module = Modules.AllEyes
		elseif ItemType == "Outfits" then
			n = ItemType
			Module = Modules.AllOutfits
		end

		if data[n][Item] then return end

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

Modules.Achievements.Reconciled:Connect(function(Data)
	local ReconcilingHatRarityAchievements = Modules.FuncLib.TableClone(HAT_RARITY_ACHIEVEMENTS)
	for Achievement, Id in pairs(ReconcilingHatRarityAchievements) do
		if Modules.Achievements.IsCompleted(Data, Id) then
			ReconcilingHatRarityAchievements[Achievement] = nil
		end
	end

	for _, Achievement in pairs(ReconcilingHatRarityAchievements) do
		Modules.Achievements.ReconcileReset(Data, Achievement)
	end

	for Hat in pairs(Data.Accessories) do
		local Info = Modules.AllAccessories.All[Hat]
		if Info.Achievement then
			Modules.Achievements.ReconcileIncrement(Data, ReconcilingHatRarityAchievements[Info.Rarity])
		end
	end


	if not Modules.Achievements.IsCompleted(Data, 23) then
		Modules.Achievements.ReconcileReset(Data, 23)
		for EyePlural in pairs(Data.Eyes) do
			if Modules.AllEyes.All[EyePlural].IsForSale then
				Modules.Achievements.ReconcileIncrement(Data, 23)
			end
		end
	end

	if not Modules.Achievements.IsCompleted(Data, 13) then
		Modules.Achievements.ReconcileReset(Data, 13)
		for _, Accessory in pairs(workspace["Collectable Accessories"]:GetChildren()) do
			local Reward = Accessory:GetAttribute("Reward")

			if Reward and Data.Accessories[Reward] then
				Modules.Achievements.ReconcileIncrement(Data, 13)
			end

		end

	end

end)

return Accessories
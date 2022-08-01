local Penguins = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local MoneyProducts = {1224873708, 1224873843, 1224873847, 1224873846, 1224873844, 1224873842}

--- Initializing ---
function Penguins:PenguinPurchased(Player, PenguinName)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		Data["Penguins"][PenguinName] = {
			["Name"] = 	 string.split(PenguinName, "#")[1];
			["Level"] = 1;
			["BodyColor"] = "Default";
			["Accessory"] = "Default";
			["Eyes"] = "Default";
		}
	end
end


function Penguins:LoadPenguin(Penguin, Info, DontLoadHat, DontLoadEyes, DontLoadColor,Player)
	-- Load penguin appearance
	if Info["BodyColor"] ~= "Default" and not DontLoadColor then
		local Color = Color3.new(Info["BodyColor"]["R"], Info["BodyColor"]["G"], Info["BodyColor"]["B"])

		local PenguinBody = Penguin:FindFirstChild("Main")
		local PenguinArmL = Penguin:FindFirstChild("Arm L") or Penguin:FindFirstChild("ArmL")
		local PenguinArmR = Penguin:FindFirstChild("Arm R") or Penguin:FindFirstChild("ArmR")

		if PenguinBody and PenguinArmL and PenguinArmR then
			PenguinBody.Color = Color
			PenguinArmL.Color = Color
			PenguinArmR.Color = Color
		end
	end
	-- Load accessory
	if Info["Accessory"] ~= "Default" and not DontLoadHat then
		local Humanoid = Penguin:FindFirstChild("Humanoid")
		local Model = Services.SStorage.Accessories:FindFirstChild(Info["Accessory"])

		if Humanoid and Model then
			-- Destroy previous accessory
			if Penguin:FindFirstChild("Customization_Accessory") then
				Penguin:FindFirstChild("Customization_Accessory"):Destroy()
			end

			-- Add physical accessory
			local Model = Model:Clone()
			Model.Name = "Customization_Accessory"
			Humanoid:AddAccessory(Model)
		end
	end

	if Info["Outfit"] then
		Modules.Character:EquipShirt(Penguin,Info["Outfit"])
	end

	if Info["Super"] then
		Penguin:SetAttribute("IsSuper",true)

		local Rainbow = Services.RStorage.ClientDependency.PenguinsUI.Rainbow:Clone()
		Rainbow.Parent = Penguin.Info.PenguinInfo.PenguinName
	end

	-- Load eyes
	if Info["Eyes"] and not DontLoadEyes then
		local Humanoid = Penguin:FindFirstChild("Humanoid")
		local Model = Services.SStorage.Eyes:FindFirstChild(Info["Eyes"])

		if Humanoid and Model then
			-- Destroy previous eyes
			if Penguin:FindFirstChild("Customization_Eyes") then
				Penguin:FindFirstChild("Customization_Eyes"):Destroy()
			end

			-- Add physical eyes
			local Model = Model:Clone()
			Model.Name = "Customization_Eyes"
			Humanoid:AddAccessory(Model)
		end
	end

	local PenguinInfo = Penguin:WaitForChild("Info", 1)

	if PenguinInfo then
		local Income = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), Info["Level"])

		Penguin.Info.PenguinInfo.PenguinName.Text = Info["Name"]
		Penguin.Info.PenguinInfo.PenguinLevel.Text = "Lv. "..Info["Level"]..'/'..Modules.GameInfo.MAX_PENGUIN_LEVEL..' <font color="rgb(38,255,14)">(+ $'..Modules.Format:FormatComma(Income)..")</font>"
	end
end


Penguins["Change Name"] = function(Player, Penguin, NewName)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data and NewName then
		local Success, Result = pcall(function()
			return Services.TextService:FilterStringAsync(NewName, Player.UserId)
		end)

		if Success and string.len(NewName) <= 20 then
			local FilteredName = Result:GetNonChatStringForUserAsync(Player.UserId)

			if Success then
				if Data["Penguins"][Penguin.Name] then
					Data["Penguins"][Penguin.Name]["Name"] = FilteredName
					Penguin.Info.PenguinInfo.PenguinName.Text = FilteredName
				elseif Penguin == Player.Character and Penguin:FindFirstChild("HumanoidRootPart") then
					Data["My Penguin"]["Name"] = FilteredName
					Penguin:SetAttribute("CustomName", FilteredName)
				end


				return true, FilteredName
			end
		end

		return false, Data["Penguins"][Penguin.Name]["Name"]
	end
end


Penguins["Equip Accessory"] = function(Player, Penguin, Accessory)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Penguin or not Data then return end
	
	local Humanoid = Penguin:FindFirstChild("Humanoid")
	local Model = Services.SStorage.Accessories:FindFirstChild(Accessory)

	if Humanoid and Model and Data["Accessories"][Accessory] then -- If the player owns the accessory
		-- Remove previous accessory
		if Penguin:FindFirstChild("Customization_Accessory") then
			Penguin:FindFirstChild("Customization_Accessory"):Destroy()
		end

		-- Change accessory in data
		if Penguin == Player.Character then -- If it's their own penguin, save to their own table
			Data["My Penguin"]["Accessory"] = Accessory
		elseif Data["Penguins"][Penguin.Name] then
			Data["Penguins"][Penguin.Name]["Accessory"] = Accessory
		else return
		end

		-- Add physical accessory
		local Model = Model:Clone()
		Model.Name = "Customization_Accessory"
		Humanoid:AddAccessory(Model)
	end
end

Penguins["Equip Outfits"] = function(Player, Outfit)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Data then return end
	if Data["Outfits"][Outfit] then
		Data["My Penguin"]["Outfit"] = Outfit
		Modules.Character:EquipShirt(Player.Character,Outfit)
	end
end


Penguins["Equip Eyes"] = function(Player, Penguin, Eyes)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Penguin or not Data then return end
	
	local Humanoid = Penguin:FindFirstChild("Humanoid")
	local Model = Services.SStorage.Eyes:FindFirstChild(Eyes)

	if Humanoid and Model and Data["Eyes"][Eyes] then -- If the player owns the accessory
		-- Remove previous accessory
		if Penguin:FindFirstChild("Customization_Eyes") then
			Penguin:FindFirstChild("Customization_Eyes"):Destroy()
		end

		-- Change accessory in data
		if Penguin == Player.Character then -- If it's their own penguin, save to their own table
			Data["My Penguin"]["Eyes"] = Eyes
		elseif Data["Penguins"][Penguin.Name] then
			Data["Penguins"][Penguin.Name]["Eyes"] = Eyes
		else return
		end

		-- Add physical accessory
		local Model = Model:Clone()
		Model.Name = "Customization_Eyes"
		Humanoid:AddAccessory(Model)
	end
end


Penguins["Change BodyColor"] = function(Player, Penguin, Color)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Penguin or not Data then return end

	if Data["Penguins"][Penguin.Name] or Player.Character == Penguin then
		-- Create color table
		local ColorTable = {["R"] = Color.R, ["G"] = Color.G, ["B"] = Color.B}

		-- Change Color in data
		if Penguin == Player.Character then -- If it's their own penguin, save to their own table
			Data["My Penguin"]["BodyColor"] = ColorTable
		else
			Data["Penguins"][Penguin.Name]["BodyColor"] = ColorTable
		end

		-- Change physical penguin color
		local PenguinBody = Penguin:FindFirstChild("Main")
		local PenguinArmL = Penguin:FindFirstChild("Arm L") or Penguin:FindFirstChild("ArmL")
		local PenguinArmR = Penguin:FindFirstChild("Arm R") or Penguin:FindFirstChild("ArmR")

		if PenguinBody and PenguinArmL and PenguinArmR then
			PenguinBody.Color = Color
			PenguinArmL.Color = Color
			PenguinArmR.Color = Color
		end
	end
end

-- Upgrades the penguin level (Regular penguins; max level is 10, found in RStorage.Modules.GameInfo.MAX_PENGUIN_LEVEL, player penguin: no max level)
-- Player: Object, Penguin: Object/Model
-- Separated into 2 functions as it was too long
-- This function does the upgrade itself
function Penguins:UpgradePenguin(Player, Penguin,isSuper)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	local Level
	local OldIncome
	local NewIncome
	if isSuper then
		Penguin:SetAttribute("IsSuper",true)

		local Rainbow = Services.RStorage.ClientDependency.PenguinsUI.Rainbow:Clone()
		Rainbow.Parent = Penguin.Info.PenguinInfo.PenguinName

	end

	if Data["Penguins"][Penguin.Name] and Penguin:GetAttribute("Price") and Penguin:GetAttribute("Income") then
		if Data["Penguins"][Penguin.Name]["Level"] == Modules.GameInfo.MAX_PENGUIN_LEVEL and not isSuper then return false, Data["Penguins"][Penguin.Name]["Level"] end
		local oldLevel = Data["Penguins"][Penguin.Name]["Level"]
		-- Upgrade the penguin's level
		Data["Penguins"][Penguin.Name]["Level"] += 1
		if isSuper then
			Data["Penguins"][Penguin.Name]["Level"] = 30
			Data["Penguins"][Penguin.Name]["Super"] = true
		end
		-- Give the player the new income
		Level = Data["Penguins"][Penguin.Name]["Level"]
		if isSuper then
			OldIncome = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), oldLevel)
		else
			OldIncome = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), Level-1)
		end
		NewIncome = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), Level)

		-- Update the penguin UI
		Penguin.Info.PenguinInfo.PenguinLevel.Text = "Lv. "..Level .. '/'..Modules.GameInfo.MAX_PENGUIN_LEVEL..' <font color="rgb(38,255,14)">(+ $'..Modules.Format:FormatComma(NewIncome)..")</font>"

	elseif Penguin == Player.Character then
		
		-- Upgrade the penguin's level
		Data["My Penguin"]["Level"] += 1
		Player:SetAttribute("Level", Data["My Penguin"]["Level"])

		-- Give the player the new income
		Level = Data["My Penguin"]["Level"]
		OldIncome = Modules.GameFunctions:GetPlayerPenguinIncome(Level-1)
		NewIncome = Modules.GameFunctions:GetPlayerPenguinIncome(Level)
	end
	
	local IncomeToGive = NewIncome-OldIncome
	Data["Income"] += IncomeToGive
	Player:SetAttribute("Income", Data["Income"])
	
	return true, Level, Data["Penguins"]
end

-- This initiates and does the checks if the upgrade is valid
-- Player: Object, Penguin: Object/Model
Penguins["Upgrade"] = function(Player, Penguin, IsSuper)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	if Data["Penguins"][Penguin.Name] and Penguin:GetAttribute("Price") and Penguin:GetAttribute("Income") then
		local CurrentLevel = Data["Penguins"][Penguin.Name]["Level"]
		
		if CurrentLevel < Modules.GameInfo.MAX_PENGUIN_LEVEL then
			local PenguinPrice = Penguin:GetAttribute("Price")
			local PenguinIncome = Penguin:GetAttribute("Income")
			local UpgradePrice = Modules.GameFunctions:GetPenguinPrice(PenguinPrice, CurrentLevel + 1)
			
			local PlayerMoney = Data["Money"]
			
			if PlayerMoney >= UpgradePrice then
				Data["Money"] -= UpgradePrice
				if IsSuper then
					Penguin:SetAttribute("IsSuper",true)

					local Rainbow = Services.RStorage.ClientDependency.PenguinsUI.Rainbow:Clone()
					Rainbow.Parent = Penguin.Info.PenguinInfo.PenguinName
				end

				Player:SetAttribute("Money", Data["Money"])
				
				return Penguins:UpgradePenguin(Player, Penguin)
			else
				local prompted = false
				for i = 1,6 do
					local id = MoneyProducts[i]
					local Reward = Modules.GameFunctions:GetMoneyProductReward(id, Player:GetAttribute("Income"),Player)
					if Reward+PlayerMoney >= UpgradePrice then
						prompted = true
						Services.MPService:PromptProductPurchase(Player, id)
						break
					end
				end
				if prompted == false then
					Services.MPService:PromptProductPurchase(Player, MoneyProducts[6])
				end
				return false, "Not Enough Money"
			end
		else
			return false, "Penguin Max Level"
		end
		
		
	elseif Penguin == Player.Character then
		local CurrentLevel = Data["My Penguin"]["Level"]

		local UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(CurrentLevel + 1)

		local PlayerMoney = Data["Money"]

		if PlayerMoney >= UpgradePrice then
			Data["Money"] -= UpgradePrice
			Player:SetAttribute("Money", Data["Money"])

			return Penguins:UpgradePenguin(Player, Penguin)
		else
			local prompted = false
			for i = 1,6 do
				local id = MoneyProducts[i]
				local Reward = Modules.GameFunctions:GetMoneyProductReward(id, Player:GetAttribute("Income"),Player)
				if Reward+PlayerMoney >= UpgradePrice then
					prompted = true
					Services.MPService:PromptProductPurchase(Player, id)
					break
				end
			end
			if prompted == false then
				Services.MPService:PromptProductPurchase(Player, MoneyProducts[6])
			end
			return false, "Not Enough Money"
		end
	end
end



Penguins["Equip Emote"] = function(Player, Emote, Slot)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	if Data then
		-- If player has the emote and slot is valid then
		if Data["Equipped Emotes"][tostring(Slot)] and Data["Emotes"][Emote] then
			Data["Equipped Emotes"][tostring(Slot)] = Emote
		end
	end
end


Remotes.Customization.OnServerInvoke = function(Player, Function, Penguin, Info1)
	if Penguins[Function] then
		local a, b = Penguins[Function](Player, Penguin, Info1)

		return a, b
	end
end


return Penguins
local Penguins = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Initializing ---
function Penguins:PenguinPurchased(Player, PenguinName)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		Data["Penguins"][PenguinName] = {
			["Name"] = 	 string.split(PenguinName, "#")[1];
			["Level"] = 	 1;
			["BodyColor"] = "Default";
			["Accessory"] = "Default";
			["Eyes"] = "Default";
		}
	end
end


function Penguins:LoadPenguin(Penguin, Info)
	-- Load penguin appearance
	if Info["BodyColor"] ~= "Default" then
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
	if Info["Accessory"] ~= "Default" then
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

	-- Load eyes
	if Info["Eyes"] then
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
					Penguin.HumanoidRootPart.CustomName.PlrName.Text = FilteredName
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


function Penguins:UpgradePenguin(Player, Penguin)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Penguin or not Data then return end

	if Penguin == Player.Character then

		-- Upgrade the penguin's level
		Data["My Penguin"]["Level"] += 1
		Player:SetAttribute("Level", Data["My Penguin"]["Level"])

		-- Give the player the new income
		local Level = Data["My Penguin"]["Level"]
		local OldIncome = Modules.GameFunctions:GetPlayerPenguinIncome(Level-1)
		local NewIncome = Modules.GameFunctions:GetPlayerPenguinIncome(Level)
		
		local IncomeToGive = NewIncome-OldIncome
		
		Data["Income"] += IncomeToGive
		Player:SetAttribute("Income", Data["Income"])

		return true, Level
	end
end


Penguins["Upgrade"] = function(Player, Penguin)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Penguin or not Data then return end

	if Penguin == Player.Character then
		local CurrentLevel = Data["My Penguin"]["Level"]

		local UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(CurrentLevel + 1)

		local PlayerMoney = Data["Money"]

		if PlayerMoney >= UpgradePrice then
			Data["Money"] -= UpgradePrice
			Player:SetAttribute("Money", Data["Money"])

			return Penguins:UpgradePenguin(Player, Penguin)
		else
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
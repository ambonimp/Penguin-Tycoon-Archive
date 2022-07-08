local Purchasing = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")


--- Purchase Functions ---
function Purchasing:CanPurchaseWithMoney(Player, Item)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	if Data then
		local PlayerMoney = Data["Money"]

		local ItemPrice = Item:GetAttribute("Price")

		-- Check if the player has enough Money
		if PlayerMoney and ItemPrice then
			if not (PlayerMoney >= ItemPrice) then
				local ProductRequired = Modules.GameFunctions:GetRequiredMoneyProduct(Player, ItemPrice)
				Services.MPService:PromptProductPurchase(Player, ProductRequired)

				return false--, "Not enough Money."
			end
		else
			return false, "Error [Money]"
		end

		-- Check if the player owns the necessary item & doesn't already own this one (duplicate)
		local PlayerTycoon = Modules.Ownership:GetPlayerTycoon(Player)
		local Dependency = Item:GetAttribute("Dependency")

		if PlayerTycoon then
			if (not PlayerTycoon.Tycoon:FindFirstChild(Dependency) and Dependency ~= "NONE") or Data["Tycoon"][Item.Name] then
				return false--, "Dependency not owned."
			end
		else
			return false, "Error [Tycoon]"
		end

		-- Purchase may be made
		return true

	end
	
	return false
end


function Purchasing:ItemPurchased(Player, Item, IsAnimated)
	local Button = Paths.Template.Buttons:FindFirstChild(Item)
	if Item == "Sailboat#1" then
		Button = Paths.Template.Buttons:FindFirstChild("Dock#2")
	elseif Item == "Plane#1" then
		Button = Paths.Template.Buttons:FindFirstChild("Hot Springs#1")
	elseif Item == "Rocketship#1" then
		Button = Paths.Template.Buttons:FindFirstChild("New Island!#12")
	end

	if not Button then return end
	local Data = Modules.PlayerData.sessionData[Player.Name]
	-- Add income
	Data["Income"] += Button:GetAttribute("Income")
	Player:SetAttribute("Income", Data["Income"])

	-- Add item to their data so it saves
	Data["Tycoon"][Item] = true
	--if Item2 then
	--	Data["Tycoon"][Item2] = true
	--end
	-- Add specific items to their own table
	if Button:GetAttribute("Type") then
		if Button:GetAttribute("Type") == "Penguin" then
			Modules.Penguins:PenguinPurchased(Player, Item)
			
		elseif Button:GetAttribute("Type") == "Robux" then
			
		end
	end
	
	-- Add rewards
	if Modules.AllAccessories.Unlockables[Item] then
		Modules.Accessories:ItemAcquired(Player, Modules.AllAccessories.Unlockables[Item], "Accessory")
	end
	
	-- Badges
	if Modules.Badges.Purchases[Item] then
		Modules.Badges:AwardBadge(Player.UserId, Modules.Badges.Purchases[Item])
	end
	
	-- Remove button
	local Tycoon = Modules.Ownership:GetPlayerTycoon(Player)
	if Tycoon.Buttons:FindFirstChild(Item) then
		Modules.Placement:AnimateOut(Tycoon.Buttons[Item])
	end

	-- Place item
	Modules.Placement:NewItem(Player, Item, IsAnimated)
	--if Item2 then
	--	Modules.Placement:NewItem(Player, Item2, IsAnimated)
	--end
	--[[
		Fires a bindable event to notify server that this event has occured with given data
		Used normally to integrate with Game Analytics / Dive / Playfab
	]]--
	pcall(function()
		EventHandler:Fire("tycoonPurchase", Player, {
			name = Item,
			price = Button:GetAttribute("Price"),
			currency = Button:GetAttribute("CurrencyType"),
			id = Button:GetAttribute("ID"),
			island = Button:GetAttribute("Island"),
			income = Button:GetAttribute("Income"),
		})
	end)
	
	return true
end


function Purchasing:PurchaseItem(Player, Item, IsAnimated)
	local Button = Paths.Template.Buttons:FindFirstChild(Item)
	if not Button then return end

	local CurrencyType = Button:GetAttribute("CurrencyType")
	local Purchased

	if CurrencyType == "Money" then
		local CanPurchase, ErrorMsg = Purchasing:CanPurchaseWithMoney(Player, Button)
		
		if CanPurchase then
			-- Take player's money
			local Data = Modules.PlayerData.sessionData[Player.Name]
			Data["Money"] -= Button:GetAttribute("Price")
			Player:SetAttribute("Money", Data["Money"])

			Purchased = true
		elseif ErrorMsg then
			warn(Player, ErrorMsg)
			Purchased = false
		end

	elseif CurrencyType == "Gamepass" then
		local Id = tonumber(Button:GetAttribute("ID"))
		Services.MPService:PromptGamePassPurchase(Player, Id)

		if Services.MPService:UserOwnsGamePassAsync(Player.UserId, Id) then
			Purchased = true
		else
			local Conn
			Conn = Services.MPService.PromptGamePassPurchaseFinished:Connect(function(_Player, _Id, Success)
				if Player  == _Player and _Id == Id then
					Purchased = Success
					Conn:Disconnect()
				end
	        end)

	        repeat
				task.wait()
			until Purchased ~= nil
		end

	end

	if Purchased then
		Purchasing:ItemPurchased(Player, Item, IsAnimated)
		return true
	else
		return false
	end

end


return Purchasing
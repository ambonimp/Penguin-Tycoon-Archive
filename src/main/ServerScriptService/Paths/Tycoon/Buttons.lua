local Buttons = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Purchase Variables ---
local PurchaseDBs = {}

local lastCheck = {}
local lastOne = {}
local Total = 20
function getDependentObjects(item,Data)
	local items = {}

	local function nonRecurvise(next)
		local items = {}
		for i,v in pairs (Paths.Template.Buttons:GetChildren()) do
			if v:GetAttribute("Dependency") == next and v:GetAttribute("CurrencyType") == "Money" and not Data[v.Name] then
				table.insert(items,{Name = v.Name,Price = v:GetAttribute("Price")})
			end
		end
		return items
	end

	local function recursive(next)
		local last = Paths.Template.Buttons:FindFirstChild(next)
		for i,v in pairs (Paths.Template.Buttons:GetChildren()) do
			if v:GetAttribute("Dependency") == next and v:GetAttribute("CurrencyType") == "Money" and not Data[v.Name] then
				table.insert(items,{Name = v.Name,Price = v:GetAttribute("Price")})
				local items1 = nonRecurvise(v:GetAttribute("Object"))
				last = v
				if #items1 >= 0 then
					for i,v in pairs (items1) do
						table.insert(items,v)
						if #items == Total then
							return items
						end
					end
				end
			end
		end
		if #items == Total then
			return items
		elseif last then
			for i = 1,Total do
				table.insert(items,{Name = last.Name,Price = last:GetAttribute("Price")})
				if #items == Total then
					return items
				end
			end
		end
	end

	recursive(item)
	return items
end

function getMostExpensive(Player,Data)
	local mostExpensive = nil
	for name,has in pairs (Data) do
		local button = Paths.Template.Buttons:FindFirstChild(name)
		--warn(name)
		if button and button:GetAttribute("CurrencyType") == "Money" and button:GetAttribute("Type") == nil and Paths.Template.Upgrades:FindFirstChild(button:GetAttribute("Island")):FindFirstChild(name):GetAttribute("Type") == nil  then
			if mostExpensive == nil then
				mostExpensive = Paths.Template.Buttons:FindFirstChild(name)
			elseif Paths.Template.Buttons:FindFirstChild(name):GetAttribute("Price") >= mostExpensive:GetAttribute("Price") then
				mostExpensive = Paths.Template.Buttons:FindFirstChild(name)
			end
		end
	end
	return mostExpensive
end

function getNextPads(Player)
	if lastCheck[Player.Name] and os.time()-lastCheck[Player.Name] < 4 then
		return lastOne[Player.Name]
	end
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if Data and Data["Tycoon"] then
		local most = getMostExpensive(Player,Data["Tycoon"])
		if most then
			local items = getDependentObjects(most.Name,Data["Tycoon"])
			lastOne[Player.Name] = items
			lastCheck[Player.Name] = os.time()
			return items
		else
			return nil
		end
	end
end

game.Players.PlayerRemoving:Connect(function(Player)
	lastCheck[Player.Name] = nil
	lastOne[Player.Name] = nil
end)

function Services.RStorage.MoneyProduct.OnInvoke(Player)
	return getNextPads(Player)
end

function Services.RStorage.Remotes.MoneyProduct.OnServerInvoke(Player)
	return getNextPads(Player)
end

--- Purchase Functions ---
function Buttons:NewButton(Player, Button)
	local Button = Paths.Template.Buttons:FindFirstChild(Button)
	if Button then
		local Tycoon = Modules.Ownership:GetPlayerTycoon(Player)
		
		if Tycoon.Tycoon:FindFirstChild(Button:GetAttribute("Object")) then return end
		
		local Button = Button:Clone()
		Button.Parent = Tycoon.Buttons
		
		local Position, Rotation = Modules.Placement:GetRelativePos(Player:GetAttribute("Tycoon"), Button.Name, true)
		Modules.Placement:MoveModel(Button, Position, Rotation)
		
		Button.Hitbox.Touched:Connect(function(Part)
			if Part.Parent:FindFirstChild("Humanoid") then
				local Char = Part.Parent
				
				if game.Players:GetPlayerFromCharacter(Char) == Player and not PurchaseDBs[Button.Name] then
					PurchaseDBs[Button.Name] = true

					local CurrencyType = Button:GetAttribute("CurrencyType")
					
					if CurrencyType == "Robux" then
						Modules.Products:PromptRobuxItemPurchase(Player, Button:GetAttribute("ID"), Button)
					elseif CurrencyType == "Money" or CurrencyType == "Gamepass" then
						Modules.Purchasing:PurchaseItem(Player, Button.Name, true)
					end
					
					task.wait(0.3)
					PurchaseDBs[Button.Name] = nil
				end
			end

		end)

		return true
	end

end


return Buttons
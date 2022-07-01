local Tools = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = script

--- Tool Variables ---
local ToolFunctions = {}
for i, v in pairs(Dependency:GetChildren()) do ToolFunctions[v.Name] = require(v) end



--- Tool Functions ---
function Tools.AddTool(Player, Tool)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		-- If the tool isn't already in the player's inventory then..
		if not Data["Tools"][Tool] then
			Data["Tools"][Tool] = true
			Remotes.Tools:FireClient(Player, "Add Tool", Tool)
		end
	end
end


function Tools.UnequipTool(Player)
	local character = Player.Character

	if character and character:FindFirstChild("Tool") then
		character["Tool"]:Destroy()
	end

	Player:SetAttribute("Tool", "None")
end


function Tools.EquipTool(Player, Tool)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data and Data["Tools"][Tool] then
		local PreviousTool = Player:GetAttribute("Tool")

		if PreviousTool ~= "None" and PreviousTool ~= Tool then -- Unequip the current tool, and equip next one
			Tools.UnequipTool(Player)

		elseif PreviousTool == Tool then -- Only unequipping current tool
			Tools.UnequipTool(Player)

			return
		end

		local character = Player.Character

		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			Player:SetAttribute("Tool", Tool)

			for moduleName, module in pairs(ToolFunctions) do
				if string.match(Tool, moduleName) then
					module.Equipped(Player)
				end
			end

			if Services.SStorage.Tools:FindFirstChild(Tool) then
				local Model = Services.SStorage.Tools[Tool]:Clone()
				Model.Name = "Tool"
				Model.Parent = workspace
				character.Humanoid:AddAccessory(Model)
			end
		end
	end
end


-- Purchasing tools in the physical world
local ToolPurchaseDbs = {}
for _, Tool in workspace.Tools:GetChildren() do
	local Name = Tool.Name

	local Prompt = Instance.new("ProximityPrompt")
	Prompt.HoldDuration = 0.25
	Prompt.MaxActivationDistance = 30
	Prompt.RequiresLineOfSight = false
	Prompt.ActionText = "Unlock"
	Prompt.Parent = Tool.Hitbox

	Prompt.Triggered:Connect(function(Client)
		if ToolPurchaseDbs[Client] then return end
		ToolPurchaseDbs[Client] = true

		local Data = Modules.PlayerData.sessionData[Client.Name]
		if Data and not Data.Tycoon[Name] and Data.Tycoon[Tool:GetAttribute("Dependency")] then
			local Success
			local CurrencyType = Tool:GetAttribute("CurrencyType")

			if CurrencyType == "Gamepass" then
				local Id =  tonumber(Tool:GetAttribute("ID"))

				if Services.MPService:UserOwnsGamePassAsync(Client.UserId, Id) then
					Success = true
				else
					Services.MPService:PromptGamePassPurchase(Client, Id)

					local Conn
					Conn = Services.MPService.PromptProductPurchaseFinished:Connect(function(Player, _Id, Purchased)
						if Player == Client and _Id == Id then
							Success = Purchased
							Conn:Disconnect()
						end
					end)

				end
			elseif CurrencyType == "Money" then
				local Price = Tool:GetAttribute("Price")

				if Data["Money"] >= Price then
					Data["Money"] -= Price
					Client:SetAttribute("Money", Data["Money"])

					Success = true
				else
					local ProductRequired = Modules.GameFunctions:GetRequiredMoneyProduct(Client, Price)
					Services.MPService:PromptProductPurchase(Client, ProductRequired)

					Success = false
				end

			end

			repeat task.wait() until Success ~= nil
			if Success then
				Data.Tycoon[Name] = true

				Remotes.ToolPurchased:FireClient(Client, Name)
				Tools.AddTool(Client, Tool:GetAttribute("Tool"))

			end

			ToolPurchaseDbs[Client] = false

		end

	end)

end

game.Players.PlayerRemoving:Connect(function(Player)
	ToolPurchaseDbs[Player] = nil
end)



-- Receiving functions
Remotes.Tools.OnServerEvent:Connect(function(Player, Action, Tool)
	if Action == "Equip Tool" then
		Tools.EquipTool(Player, Tool)
	end
end)



return Tools
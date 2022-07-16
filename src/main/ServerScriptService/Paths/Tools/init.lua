local Tools = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = script

--- Tool Variables ---
Tools.ToolFunctions = {}
for i, v in pairs(Dependency:GetChildren()) do 
	Tools.ToolFunctions[v.Name] = require(v) 
end

game.Players.PlayerAdded:Connect(function(Player)
	repeat task.wait(.1) until Player == nil or Player:GetAttribute("Loaded")
	for i,v in pairs (Tools.ToolFunctions) do
		if v.LoadPlayer then
			v.LoadPlayer(Player)
		end
	end
end)

--- Tool Functions ---
function Tools.AddTool(Player, Tool, Temporary)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		-- If the tool isn't already in the player's inventory then..
		if not Data["Tools"][Tool] then
			Data["Tools"][Tool] = true
			Remotes.Tools:FireClient(Player, "Add Tool", Tool, Temporary)
		end
	end

end

function Tools.RemoveTool(Player, Tool)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		-- If the tool isn't already in the player's inventory then..
		if Data["Tools"][Tool] then
			Data["Tools"][Tool] = nil
			Remotes.Tools:FireClient(Player, "Remove Tool", Tool)
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
			
			for moduleName, module in pairs(Tools.ToolFunctions) do
				if string.match(Tool, moduleName) then
					local Equipped = module.Equipped
					if Equipped then
						Equipped(Player)
					end
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



-- Receiving functions 
Remotes.Tools.OnServerEvent:Connect(function(Player, Action, Tool)
	if Action == "Equip Tool" then
		Tools.EquipTool(Player, Tool)
	end
end)



return Tools
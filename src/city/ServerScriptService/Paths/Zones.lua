local Players = game:GetService("Players")
local Zones = {}

local Paths = require(script.Parent)
local Modules = Paths.Modules
local ReplicatedStorage = Paths.Services.RStorage
local Zone = require(ReplicatedStorage.Modules:WaitForChild("Zone"))

local Character = Modules.Character

local db = {}

local zoneFunctions = {
	["Skating"] = {
		["Enter"] = function(p)
			local plr = game.Players:FindFirstChild(p.Parent.Name)
			if plr and db[plr] == nil then
				db[plr] = true
				local char = plr.Character
				local skate = char and char:FindFirstChild("LeftSkate")
				if not skate then
					Character:AddSkates(plr)
				end
			end
		end,
		["Exit"] = function(p)
			local plr = game.Players:FindFirstChild(p.Parent.Name)
			if plr and db[plr] then
				local char = plr.Character
				local skate = char and char:FindFirstChild("LeftSkate")
				if skate then
					Character:RemoveSkates(plr)
				end
				db[plr] = nil
			end
		end
	},
	["Fishing"] = {
		["Enter"] = function(p)
			if p and p.Parent then
				local plr = game.Players:FindFirstChild(p.Parent.Name)
				if plr and db[plr] == nil then
					db[plr] = true
					local data = Modules.PlayerData.sessionData[plr.Name].Tools
					if data["Gold Fishing Rod"] then
						Modules.Tools.EquipTool(plr,"Gold Fishing Rod")
					elseif data["Fishing Rod"] then
						Modules.Tools.EquipTool(plr,"Fishing Rod")
					end
				end
			end
		end,
		["Exit"] = function(p)
			if p and p.Parent then
				local plr = game.Players:FindFirstChild(p.Parent.Name)
				if plr and db[plr] then
					Modules.Tools.UnequipTool(plr)
					db[plr] = nil
				end
			end
		end
	},
	["Hockey"] = {
		["Enter"] = function(p)
			if p and p.Parent then
				local plr = game.Players:FindFirstChild(p.Parent.Name)
				if plr and db[plr] == nil then
					local char = plr.Character
					db[plr] = true
					local skate = char and char:FindFirstChild("LeftSkate")
					if not skate then
						Paths.Services.SStorage.Tools["Hockey Stick"]:Clone().Parent = char
						Character:AddSkates(plr)
					end
				end
			end
		end,
		["Exit"] = function(p)
			if p and p.Parent then
				local plr = game.Players:FindFirstChild(p.Parent.Name)
				if plr and db[plr] then
					local char = plr.Character
					local skate = char and char:FindFirstChild("LeftSkate")
					if skate then
						Character:RemoveSkates(plr)
						if char:FindFirstChild("Hockey Stick") then
							char:FindFirstChild("Hockey Stick"):Destroy()
						end
					end
					db[plr] = nil
				end 
			end
		end
	},
	["Puck"] = {
		["Enter"] = function(p)
			if p.Name == "Puck" then
				workspace.PuckSound.Sound:Play()
				task.wait(.15)
				p.Velocity = Vector3.new(0,0,0)
				p.CFrame = CFrame.new(350.023712, 20.1363583, -1022.75153, 1, 4.37113883e-08, 1.67037434e-22, -4.37113883e-08, 1, 3.82137093e-15, 0, -3.82137093e-15, 1)
			end
		end,
		["Exit"] = function(p)
		end,
	}
}

task.spawn(function()
	repeat task.wait(1) until #workspace.Zones:GetChildren() == 6
	for i,v in pairs (workspace.Zones:GetChildren()) do
		if v:IsA("Folder") then
			local container = v
			local zone = Zone.new(container)
			if zoneFunctions[v.Name]["Enter"] then
				zone.partEntered:Connect(function(p)
					zoneFunctions[v.Name]["Enter"](p)
				end)
			end
			
			if zoneFunctions[v.Name]["Exit"] then
				zone.partExited:Connect(function(p)
					zoneFunctions[v.Name]["Exit"](p)
				end)
			end
		end
	end

	workspace.Puck:SetNetworkOwner(nil)
end)




return Zones
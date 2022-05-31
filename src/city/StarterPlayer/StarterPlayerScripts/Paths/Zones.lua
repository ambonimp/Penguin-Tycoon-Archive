local Zones = {}

local Paths = require(script.Parent)
local Remotes = Paths.Remotes
local Zone = require(Paths.Services.RStorage.Modules:WaitForChild("Zone"))

task.spawn(function()
	task.wait(1)
	local db = false
	for i,v in pairs (workspace.Zones:GetChildren()) do
		if v:IsA("Folder") then
			local container = v
			for i,v in pairs (container:GetChildren()) do
				v.Transparency = 1
			end
			local zone = Zone.new(container)
			local db = false
			zone.partEntered:Connect(function(p)
				if p and p.Parent and p.Name == "HumanoidRootPart" then
					local plr = game.Players:FindFirstChild(p.Parent.Name)
					if plr == game.Players.LocalPlayer then
						if db then return end
						db = true
						Remotes.Zone:FireServer(v.Name,"Enter")
						task.wait(.2)
						db = false
					end
				end
			end)

			zone.partExited:Connect(function(p)
				if p and p.Parent and p.Name == "HumanoidRootPart" then
					local plr = game.Players:FindFirstChild(p.Parent.Name)
					if plr == game.Players.LocalPlayer then
						if db then return end
						db = true
						Remotes.Zone:FireServer(v.Name,"Exit")
						task.wait(.2)
						db = false
					end
				end
			end)
		end
	end
	
end)

return Zones

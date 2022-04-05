local Settings = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Functions ---
Remotes.Settings.OnServerEvent:Connect(function(player, Setting, value)
	local Data = Modules.PlayerData.sessionData[player.Name]
	
	if Data then
		Data["Settings"][Setting] = value
		Remotes.Settings:FireClient(player, "Setting Changed", Setting, value)
		
		if Setting == "Faster Speed" then
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				if value then
					player.Character.Humanoid.WalkSpeed *= Data["Walkspeed Multiplier"]
				else
					player.Character.Humanoid.WalkSpeed /= Data["Walkspeed Multiplier"]
				end
			end
			
			
		elseif Setting == "Show Hearts" then
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart:FindFirstChild("CustomName") then
				player.Character.HumanoidRootPart.CustomName.Hearts.Visible = value
			end
			
			
		elseif Setting == "Chat Tag" then
			Modules.Chat:ApplyChatTag(player)
		end
	end
end)


return Settings
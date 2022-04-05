-- Player settings; such as Chat Tag and music enabled

local Settings = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Functions ---
-- receives client attempt on changing a setting
-- player: Object, Setting: String (which setting is being changed), value: boolean (whether enabled or not)
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
			
		elseif Setting == "Chat Tag" then
			Modules.Chat:ApplyChatTag(player)
		end
	end
end)


return Settings
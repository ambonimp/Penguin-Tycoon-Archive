local Settings = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Other Variables ---
local SettingsUI = UI.Center.Settings.Holder
local ToggleDB = false



--- Functions ---
local function TweenSetting(val, Setting)
	if val then
		Setting.Toggle.ToggledUI:TweenPosition(UDim2.new(0.5, -2, 0, 2), "Out", "Quart", 0.2)
		Setting.Toggle.ToggledUI.BackgroundColor3 = Color3.fromRGB(74, 213, 98)
	else
		Setting.Toggle.ToggledUI:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quart", 0.2)
		Setting.Toggle.ToggledUI.BackgroundColor3 = Color3.fromRGB(243, 70, 58)
	end
end


function Settings:GetPlayerSettings()
	local PlayerSettings = false
	local PlayerGamepasses = false

	for i = 1, 5, 1 do
		PlayerSettings = Remotes.GetStat:InvokeServer("Settings")
		PlayerGamepasses = Remotes.GetStat:InvokeServer("Gamepasses")
		if not PlayerSettings or not PlayerGamepasses then wait(0.5) end
	end

	return PlayerSettings, PlayerGamepasses
end


function Settings:GamepassPurchased(Gamepass)
	if Gamepass == 26269102 then
		SettingsUI["Chat Tag"].Visible = true
	end
	
	for i, Setting in pairs(SettingsUI:GetChildren()) do
		if Setting:GetAttribute("Gamepass") then
			if Gamepass == Setting:GetAttribute("Gamepass") then
				Setting.Locked.Visible = false
			end
		end
	end
end
-- Loading chat tag ui
local GroupRank = 0
pcall(function()
	GroupRank = Paths.Player:GetRankInGroup(12843903)
end)
if GroupRank and (GroupRank >= 1) then
	SettingsUI["Chat Tag"].Visible = true
end



function Settings:SettingUpdated(Setting, Value)
	if Setting == "Music" then
		if Value == true then
			Paths.Audio["Music"].Volume = 0.3
			Paths.Audio["Music"].Playing = true
		else
			Paths.Audio["Music"].Volume = 0
		end
	end
end


Remotes.Settings.OnClientEvent:Connect(function(ActionType, Setting, Value)
	if ActionType == "Setting Changed" then
		Settings:SettingUpdated(Setting, Value)
	end
end)



--- Loading Settings ---
for i, Setting in pairs(SettingsUI:GetChildren()) do
	if Setting:IsA("Frame") then
		Setting.Toggle.IsToggled.Changed:Connect(function(val)
			TweenSetting(val, Setting)
		end)

		Setting.Toggle.MouseButton1Down:Connect(function()
			if not ToggleDB then
				if Setting:FindFirstChild("Locked") and Setting.Locked.Visible == true then return end
				
				ToggleDB = true

				Setting.Toggle.IsToggled.Value = not Setting.Toggle.IsToggled.Value
				Remotes.Settings:FireServer(Setting.Name, Setting.Toggle.IsToggled.Value)

				wait(0.2)

				ToggleDB = false
			end
		end)
		
		if Setting:FindFirstChild("Locked") then
			Setting.Locked.MouseButton1Down:Connect(function()
				Services.MPService:PromptGamePassPurchase(Paths.Player, Setting:GetAttribute("Gamepass"))
			end)
		end

		-- Load Plr Currently Saved Settings
		coroutine.wrap(function()
			local PlayerSettings, PlayerGamepasses = Settings:GetPlayerSettings()
			if PlayerSettings and PlayerGamepasses then
				Setting.Toggle.IsToggled.Value = PlayerSettings[Setting.Name]
				
				if Setting:GetAttribute("Gamepass") then
					Setting.Locked.Visible = not PlayerGamepasses[tostring(Setting:GetAttribute("Gamepass"))]
				end
				
				if PlayerGamepasses["26269102"] then
					SettingsUI["Chat Tag"].Visible = true
				end
			end
		end)()
	end
end



--- Updating Settings ---

-- Music Enabled
if SettingsUI["Music"].Toggle.IsToggled.Value == false then
	if Paths.Audio:FindFirstChild("Music") then
		Paths.Audio.Music.Volume = 0
	end
end
if Paths.Audio:FindFirstChild("Music") then
	Paths.Audio.Music.Changed:Connect(function()
		if SettingsUI["Music"].Toggle.IsToggled.Value == false then
			Paths.Audio.Music.Volume = 0
		end
	end)
end
Paths.Audio.ChildAdded:Connect(function(Sound)
	if Sound.Name == "Music" then
		Sound.Changed:Connect(function()
			if SettingsUI["Music"].Toggle.IsToggled.Value == false then
				Sound.Volume = 0
			end
		end)
	end
end)


return Settings
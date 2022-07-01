local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Settings = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Services.RStorage.ClientDependency[script.Name]


--- Other Variables ---
local List = UI.Center.Settings.Holder
local ToggleDB

--- Functions ---
local Handlers = {
	["Music"] = function(Value)
		if Value == true then
			Paths.Audio["Music"].Volume = 0.3
			Paths.Audio["Music"].Playing = true
		else
			Paths.Audio["Music"].Volume = 0
		end
	end,

	["Progress Bar"] = function(Value)
		Modules.TycoonProgressBar.Toggle(Value)
	end,

	["Night"] = function(Value)
		Lighting.ClockTime = if Value then 22 else 12
	end,

	["Shadows"] = function(Value)
		Lighting.GlobalShadows = Value
	end,

	["Auto Activate Boosts"] = function(Value)
		for _, Boost in ipairs(UI.BLCorner.Boosts:GetChildren()) do
			if Boost:IsA("Frame") then
				Boost.AutoActivate.Visible = Value
			end
		end
	end
}

local function TweenToggle(Setting, Toggle)
	if Toggle then
		Setting.Toggle.ToggledUI:TweenPosition(UDim2.new(0.5, -2, 0, 2), "Out", "Quart", 0.2)
		Setting.Toggle.ToggledUI.BackgroundColor3 = Color3.fromRGB(74, 213, 98)
	else
		Setting.Toggle.ToggledUI:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quart", 0.2)
		Setting.Toggle.ToggledUI.BackgroundColor3 = Color3.fromRGB(243, 70, 58)
	end
end

function Settings:GamepassPurchased(Gamepass)
	for Setting, Details in Modules.SettingDetails do
		local Lbl = List[Setting]
		if Details.Gamepass == Gamepass then
			Lbl.Locked.Visible = false
			Lbl.Visible = true
		end
	end
end



--- Loading Settings ---
local SettingsData = Remotes.GetStat:InvokeServer("Settings")
local GamepassData = Remotes.GetStat:InvokeServer("Gamepasses")
for Setting, Details in Modules.SettingDetails do
	local Lbl = Dependency.SettingTemplate:Clone()
	Lbl.Name = Setting
	Lbl.SettingName.Text = Setting
	Lbl.LayoutOrder = Details.LayoutOrder
	Lbl.Visible = Details.AlwaysVisible

	local Gamepass = Details.Gamepass
	if Gamepass then
		local IsOwned = GamepassData[tostring(Gamepass)] ~= nil

		Lbl.Locked.Visible = not IsOwned
		Lbl.Visible = Details.AlwaysVisible or IsOwned

		if not IsOwned then
			Lbl.Locked.MouseButton1Down:Connect(function()
				Services.MPService:PromptGamePassPurchase(Paths.Player, Gamepass)
			end)
		end

		Lbl.BackgroundColor3 = Color3.fromRGB(250, 197, 38)
		Lbl.Stroke.UIStroke.Color = Color3.fromRGB(250, 197, 38)
	else
		Lbl.Locked.Visible = false

		Lbl.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
		Lbl.Stroke.UIStroke.Color = Color3.fromRGB(0, 0, 0)

	end

	Lbl.Parent = List


	-- Apply saved value
	local Toggled = SettingsData[Setting]
	local Toggle = Lbl.Toggle

	local IsToggled = Toggle.IsToggled
	IsToggled.Value = Toggled
	TweenToggle(Lbl, Toggled)

	local Handler = Handlers[Setting]
	if Handler then
		Handler(Toggled)
	end

	-- Changing
	IsToggled.Changed:Connect(function(Value)
		TweenToggle(Lbl, Value)
	end)

	Lbl.Toggle.MouseButton1Down:Connect(function()
		if not ToggleDb and not Lbl.Locked.Visible then
			ToggleDb = true

			local Value = not IsToggled.Value
			IsToggled.Value = Value

			Remotes.Settings:FireServer(Setting, Value)

			task.wait(0.2)
			ToggleDb = false
		end

	end)


end

-- Group rank based settings
task.spawn(function()
	local Tries = 0

	local Success, GroupRank
	repeat
		Success, GroupRank = pcall(function()
			return Paths.Player:GetRankInGroup(12843903)
		end)
		Tries += 1
	until Success or Tries == 5

	if Success then
		for Setting, Details in Modules.SettingDetails do
			local MinRank = Details.MinGroupRank
			if MinRank and GroupRank >= MinRank then
				local Lbl = List[Setting]
				Lbl.Locked.Visible = false
				Lbl.Visible = true
			end
		end
	end

end)

-- Handling
Remotes.Settings.OnClientEvent:Connect(function(ActionType, Setting, Value)
	if ActionType == "Setting Changed" then
		local Handler = Handlers[Setting]
		if Handler then
			Handler(Value)
		end

	end

end)

-- Music Enabled
if Paths.Audio:FindFirstChild("Music") then
	Paths.Audio.Music.Changed:Connect(function()
		if not List["Music"].Toggle.IsToggled.Value then
			Paths.Audio.Music.Volume = 0
		end
	end)
end

Paths.Audio.ChildAdded:Connect(function(Sound)
	if Sound.Name == "Music" then
		Sound.Changed:Connect(function()
			if not List["Music"].Toggle.IsToggled.Value then
				Sound.Volume = 0
			end
		end)
	end

end)



return Settings
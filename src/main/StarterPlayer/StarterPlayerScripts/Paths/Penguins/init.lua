local Penguins = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Other Variables ---
local CustomizationUI = UI.Left.Customization
local PenguinList = UI.Center.Penguins.List
Penguins.Penguins = {}


--- Setting Up Buttons (Proximity Prompts) ---
function Penguins:SetupPenguin(Penguin)
	local Info = Penguin:WaitForChild("Info", 3)
	if Info and not Penguins.Penguins[Penguin] then
		local ProximityPrompt = Info:WaitForChild("ProximityPrompt", 3)

		if ProximityPrompt then
			Penguins.Penguins[Penguin] = true -- Set the penguin as initiated so it doesn't get double setup

			Modules.PenguinsUI:SetupPenguin(Penguin)

			ProximityPrompt.Triggered:Connect(function(Player)
				Modules.Customization:EnterUI(Penguin)
			end)
		end
	end
end

-- Setting up customization sections/buttons
local UIdb = false
local PreviousOpen = CustomizationUI.Customization.Sections.Color


-- Initialize Colors being open
CustomizationUI.Customization.Sections.Color.Visible = true
CustomizationUI.Customization.Sections.Color.Position = UDim2.new(0.5, 0, 0.5, 0)
CustomizationUI.Customization.Buttons.Color.BackgroundTransparency = 0.2


local function ButtonClicked(button)
	if UIdb then return end
	UIdb = true

	-- If button clicked is the same as previous open, just turn it off
	if PreviousOpen ~= CustomizationUI.Customization.Sections[button.Name] then
		-- Out
		PreviousOpen:TweenPosition(UDim2.new(0.5, 0, 1.7, 0), "Out", "Quart", 0.2, true)
		CustomizationUI.Customization.Buttons[PreviousOpen.Name].BackgroundTransparency = 0.8

		-- In
		CustomizationUI.Customization.Sections[button.Name].Position = UDim2.new(0.5, 0, 1.7, 0)
		CustomizationUI.Customization.Sections[button.Name]:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quart", 0.2, true)
		CustomizationUI.Customization.Sections[button.Name].Visible = true
		button.BackgroundTransparency = 0.2

		task.wait(0.15)
		PreviousOpen.Visible = false
		PreviousOpen = CustomizationUI.Customization.Sections[button.Name]
	end

	UIdb = false
end

function Penguins.ButtonClicked(Button)
	ButtonClicked(Button)
end

for i, Button in pairs(CustomizationUI.Customization.Buttons:GetChildren()) do
	if Button:IsA("ImageButton") then
		Button.MouseButton1Down:Connect(function()
			ButtonClicked(Button)
		end)
	end
end


--- Connecting penguins to SetupPenguin() function ---
local PlayerTycoon = Paths.Player:GetAttribute("Tycoon")

task.spawn(function()
	workspace.Tycoons[PlayerTycoon].Tycoon.ChildAdded:Connect(function(Object)
		local Type = Object:GetAttribute("Type")
		if Type == "Penguin" then
			Penguins:SetupPenguin(Object)
		end
	end)

	for i, Object in pairs(workspace.Tycoons[PlayerTycoon].Tycoon:GetChildren()) do
		local Type = Object:GetAttribute("Type")
		if Type == "Penguin" then
			Penguins:SetupPenguin(Object)
		end
	end
end)


--- Upgrading Penguins ---


CustomizationUI.Super.MouseButton1Down:Connect(function()
	local Penguin = CustomizationUI.PenguinSelected.Value
	if Penguin then
		Remotes.Store:FireServer("Penguin", Penguin, true)
	end
end)
CustomizationUI.Instant.MouseButton1Down:Connect(function()
	local Penguin = CustomizationUI.PenguinSelected.Value
	if Penguin then
		Remotes.Store:FireServer("Penguin", Penguin)
	end
end)
Remotes.Store.OnClientEvent:Connect(function(PurchaseType, PurchaseInfo, IsPurchased,NewPenguinsData)
	if PurchaseType == "Penguin Upgraded" then
		local Penguin = CustomizationUI.PenguinSelected.Value
		if IsPurchased and Penguin then -- If purchase was true/successful then
			local NewLevel = tonumber(string.split(string.split(Penguin.Info.PenguinInfo.PenguinLevel.Text, "/"..tostring(Modules.GameInfo.MAX_PENGUIN_LEVEL))[1], " ")[2])

			-- Update penguin UI
			if Penguin:GetAttribute("Income") then
				local Income = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), NewLevel)
				local UpgradePrice = Modules.GameFunctions:GetPenguinPrice(Penguin:GetAttribute("Price"), NewLevel + 1)

				CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin.Info.PenguinInfo.PenguinName.Text
				CustomizationUI.PenguinNameBG.PenguinName.Rainbow.Enabled = NewLevel == 30

				CustomizationUI.PenguinNameBG.PenguinLevel.Text = Penguin.Info.PenguinInfo.PenguinLevel.Text

				if NewLevel < Modules.GameInfo.MAX_PENGUIN_LEVEL then
					CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"
				else
					CustomizationUI.Upgrade.TheText.Text = "Max Level"
				end
				if NewLevel >= 10 then
					CustomizationUI.Instant.Visible = false
				end
				if NewLevel == 30 then
					CustomizationUI.Super.Visible = false
				end
			end
		end
	end
end)
CustomizationUI.Upgrade.MouseButton1Down:Connect(function()
	local Penguin = CustomizationUI.PenguinSelected.Value

	if Penguin then
		local UpgradeSuccess, Info = Remotes.Customization:InvokeServer("Upgrade", Penguin)

		if UpgradeSuccess then
			Modules.PenguinsUI:PenguinInfoUpdated(Penguin)

			local NewLevel = Info

			-- Update penguin UI
			if Penguin:GetAttribute("Income") then
				local Income = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), NewLevel)
				local UpgradePrice = Modules.GameFunctions:GetPenguinPrice(Penguin:GetAttribute("Price"), NewLevel + 1)

				CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin.Info.PenguinInfo.PenguinName.Text
				CustomizationUI.PenguinNameBG.PenguinName.Rainbow.Enabled = NewLevel == 30
				CustomizationUI.PenguinNameBG.PenguinLevel.Text = Penguin.Info.PenguinInfo.PenguinLevel.Text

				if NewLevel < Modules.GameInfo.MAX_PENGUIN_LEVEL then
					CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"
				else
					CustomizationUI.Upgrade.TheText.Text = "Max Level"
				end

			elseif Penguin:GetAttribute("Penguin") then
				local Income = Modules.GameFunctions:GetPlayerPenguinIncome(NewLevel)
				local UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(NewLevel + 1)

				CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin:GetAttribute("CustomName")
				CustomizationUI.PenguinNameBG.PenguinName.Rainbow.Enabled = false
				CustomizationUI.PenguinNameBG.PenguinLevel.Text = "Level "..NewLevel..' <font color="rgb(38,255,14)">(+ $'..Modules.Format:FormatComma(Income)..")</font>"
				CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"
			end

		else
			local Reason = Info

		end
	end
end)



return Penguins
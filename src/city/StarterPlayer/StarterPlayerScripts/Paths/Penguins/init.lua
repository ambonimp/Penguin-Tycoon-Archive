local Penguins = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Other Variables ---
local CustomizationUI = UI.Left.Customization
Penguins.Penguins = {}


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

for i, Button in pairs(CustomizationUI.Customization.Buttons:GetChildren()) do
	Button.MouseButton1Down:Connect(function()
		ButtonClicked(Button)
	end)
end


--- Upgrading Penguins ---
CustomizationUI.Upgrade.MouseButton1Down:Connect(function()
	local Penguin = CustomizationUI.PenguinSelected.Value

	if Penguin then
		local UpgradeSuccess, Info = Remotes.Customization:InvokeServer("Upgrade", Penguin)

		if UpgradeSuccess then
			local NewLevel = Info

			-- Update penguin UI
			if Penguin:GetAttribute("Income") then
				local Income = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), NewLevel)
				local UpgradePrice = Modules.GameFunctions:GetPenguinPrice(Penguin:GetAttribute("Price"), NewLevel + 1)

				CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin.Info.PenguinInfo.PenguinName.Text
				CustomizationUI.PenguinNameBG.PenguinLevel.Text = Penguin.Info.PenguinInfo.PenguinLevel.Text

				if NewLevel < Modules.GameInfo.MAX_PENGUIN_LEVEL then
					CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"
				else
					CustomizationUI.Upgrade.TheText.Text = "Max Level"
				end

			elseif Penguin:GetAttribute("Penguin") then
				local Income = Modules.GameFunctions:GetPlayerPenguinIncome(NewLevel)
				local UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(NewLevel + 1)

				CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin.HumanoidRootPart.CustomName.PlrName.Text
				CustomizationUI.PenguinNameBG.PenguinLevel.Text = "Level "..NewLevel..' <font color="rgb(38,255,14)">(+ $'..Modules.Format:FormatComma(Income)..")</font>"
				CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"
			end

		else
			local Reason = Info

		end
	end
end)



return Penguins
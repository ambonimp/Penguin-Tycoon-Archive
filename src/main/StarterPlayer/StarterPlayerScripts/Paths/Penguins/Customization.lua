local Customization = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)
--- UI Variables ---
local CustomizationUI = UI.Left.Customization

local SelectedColorUI = Dependency.Selected
local SelectedAccessoryUI = Dependency.Parent.Accessories.SelectedAccessory
local SelectedEyesUI = Dependency.Parent.Accessories.SelectedEyes



--- Customization Functions ---
--- Renaming ---
CustomizationUI.PenguinNameBG.Rename.MouseButton1Down:Connect(function()
	CustomizationUI.PenguinNameBG.Rename.Visible = false
	CustomizationUI.PenguinNameBG.RenameFinish.Visible = true

	CustomizationUI.PenguinNameBG.PenguinNameTextbox.Text = CustomizationUI.PenguinNameBG.PenguinName.Text
	CustomizationUI.PenguinNameBG.PenguinName.Visible = false
	CustomizationUI.PenguinNameBG.PenguinNameTextbox.Visible = true

end)

CustomizationUI.PenguinNameBG.PenguinNameTextbox.FocusLost:Connect(function()
	CustomizationUI.PenguinNameBG.Rename.Visible = true
	CustomizationUI.PenguinNameBG.RenameFinish.Visible = false


	local NewName = CustomizationUI.PenguinNameBG.PenguinNameTextbox.Text
	local Success, FilteredName = Remotes.Customization:InvokeServer("Change Name", CustomizationUI.PenguinSelected.Value, NewName)

	CustomizationUI.PenguinNameBG.PenguinName.Text = FilteredName
	CustomizationUI.PenguinNameBG.PenguinName.Visible = true
	CustomizationUI.PenguinNameBG.PenguinNameTextbox.Visible = false

	Modules.PenguinsUI:PenguinInfoUpdated(CustomizationUI.PenguinSelected.Value)
end)

-- 20 max char limit
local PrevName = "nil"

CustomizationUI.PenguinNameBG.PenguinNameTextbox.Changed:Connect(function(property)
	if property == "Text" then
		local length = string.len(CustomizationUI.PenguinNameBG.PenguinNameTextbox.Text)

		if length > 20 then
			CustomizationUI.PenguinNameBG.PenguinNameTextbox.Text = PrevName
		end

		PrevName = CustomizationUI.PenguinNameBG.PenguinNameTextbox.Text
	end
end)



--- Changing Penguin Body Color ---
local ColorDB = false

for i, Color in pairs(CustomizationUI.Customization.Sections.Color.Colors:GetChildren()) do
	if Color:IsA("ImageButton") then
		Color.MouseButton1Down:Connect(function()
			if ColorDB then return end
			ColorDB = true

			local Penguin = CustomizationUI.PenguinSelected.Value
			local NewColor = Color.BackgroundColor3

			Remotes.Customization:InvokeServer("Change BodyColor", Penguin, NewColor)

			SelectedColorUI.Parent = Color

			task.wait(0.1)
			ColorDB = false

		end)

	end

end



--- UI Functions ---
local UIToReOpen = nil

function Customization:EnterUI(Penguin, PreviousUI)
	UIToReOpen = PreviousUI
	local CameraAngleCF = nil
	
	if Penguin:FindFirstChild("CameraAngle") then
		CameraAngleCF = Penguin.CameraAngle.CFrame
		Modules.Penguins.ButtonClicked(CustomizationUI.Customization.Buttons.Color)
		CustomizationUI.Customization.Buttons.Outfits.Visible = false
		-- Make plr invis if it's a regular/tycoon penguin
		Modules.Character:Invisible(true)

	elseif Penguin:GetAttribute("Penguin") then
		--CameraAngleCF = Penguin.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(10), math.rad(180), 0) * CFrame.new(0, 2, 5) -- viewport angle
		CameraAngleCF = Penguin.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(5), math.rad(178), math.rad(0)) * CFrame.new(-3, 0.5, 8)
		CustomizationUI.Customization.Buttons.Outfits.Visible = true
	else
		return -- If the player selects to customize but has their avatar selected
	end
	
	
	CustomizationUI.PenguinSelected.Value = Penguin
	

	-- Disable things for entering ui
	Modules.Character:Freeze()

	if Penguin:FindFirstChild("Info") then
		Penguin.Info.ProximityPrompt.Enabled = false
	end
	UI.Left.GemDisplay.Visible = false
	UI.Left.Buttons.Visible = false
	UI.Center.Visible = false
	UI.Top.Currencies.MoneyDisplay.BuyMore.Visible = false
	UI.Top.Currencies.GemDisplay.BuyMore.Visible = false


	-- For regular, tycoon penguins
	if Penguin:FindFirstChild("Info") then
		-- Get penguin info
		CustomizationUI.Instant.Position = UDim2.fromScale(0.838,1.015)
		CustomizationUI.Super.Visible = true

		local Level = tonumber(string.split(string.split(Penguin.Info.PenguinInfo.PenguinLevel.Text, "/"..tostring(Modules.GameInfo.MAX_PENGUIN_LEVEL))[1], " ")[2])
		if Level == 30 then
			CustomizationUI.Super.Visible = false
		end
		if Level >= 10 then
			CustomizationUI.Instant.Visible = false
		else
			CustomizationUI.Instant.Visible = true
		end
		local Income = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), Level)
		local UpgradePrice = Modules.GameFunctions:GetPenguinPrice(Penguin:GetAttribute("Price"), Level + 1)

		-- Set text
		CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin.Info.PenguinInfo.PenguinName.Text
		CustomizationUI.PenguinNameBG.PenguinName.Rainbow.Enabled = Level == 30
		CustomizationUI.PenguinNameBG.PenguinLevel.Text = Penguin.Info.PenguinInfo.PenguinLevel.Text--.. ' <font color="rgb(57,225,91)">(+'..Modules.Format:FormatComma(Income)..")</font>"

		if Level < Modules.GameInfo.MAX_PENGUIN_LEVEL then
			CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"
		else
			CustomizationUI.Upgrade.TheText.Text = "Max Level"
		end

	else -- For the player's penguin
		local Level = Paths.Player:GetAttribute("Level")
		CustomizationUI.Instant.Position = UDim2.fromScale(0.645,1.015)
		CustomizationUI.Super.Visible = false
		CustomizationUI.Instant.Visible = true
		local Income = Modules.GameFunctions:GetPlayerPenguinIncome(Level)
		local UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(Level + 1)

		CustomizationUI.Upgrade.TheText.Text = "N/A"
		CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin.HumanoidRootPart.CustomName.PlrName.Text
		CustomizationUI.PenguinNameBG.PenguinName.Rainbow.Enabled = false

		CustomizationUI.PenguinNameBG.PenguinLevel.Text = "Level "..Level..' <font color="rgb(38,255,14)">(+ $'..Modules.Format:FormatComma(Income)..")</font>"
		CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"
	end


	-- Open Customization UI
	CustomizationUI.Position = UDim2.new(-1.5, 0, 0.5, 0)
	CustomizationUI.Visible = true
	CustomizationUI:TweenPosition(UDim2.new(0.4, 0, 0.5, 0), "Out", "Back", 0.4, true)


	-- Tween Camera to the Penguin
	Modules.Camera:AttachTo(CameraAngleCF, true)


	-- Set color selected ui to the color the penguin has (if applicable)
	SelectedColorUI.Parent = script
	SelectedAccessoryUI.Parent = script.Parent.PenguinsUI
	SelectedEyesUI.Parent = script.Parent.PenguinsUI


	-- Customization UI checking currently selected items
	local CurrentHat = Penguin:FindFirstChild("Customization_Accessory")

	if CurrentHat then
		if CustomizationUI.Customization.Sections.Accessory.Holder:FindFirstChild(CurrentHat:GetAttribute("ItemName")) then
			SelectedAccessoryUI.Parent = CustomizationUI.Customization.Sections.Accessory.Holder[CurrentHat:GetAttribute("ItemName")]
		end
	end
	
	local CurrentEyes = Penguin:FindFirstChild("Customization_Eyes")

	if CurrentEyes then
		if CustomizationUI.Customization.Sections.Eyes.Holder:FindFirstChild(CurrentEyes:GetAttribute("ItemName")) then
			SelectedEyesUI.Parent = CustomizationUI.Customization.Sections.Eyes.Holder[CurrentEyes:GetAttribute("ItemName")]
		end
	end
	
	local PenguinBody = Penguin:WaitForChild("Main", 3)

	if PenguinBody then
		local PenguinR = math.ceil(PenguinBody.Color.R*255)
		local PenguinG = math.ceil(PenguinBody.Color.G*255)
		local PenguinB = math.ceil(PenguinBody.Color.B*255)

		for i, v in pairs(CustomizationUI.Customization.Sections.Color.Colors:GetChildren()) do
			if i%20 == 0 then task.wait() end
			if v:IsA("ImageButton") then
				if math.ceil(v.BackgroundColor3.R*255) == PenguinR and math.ceil(v.BackgroundColor3.G*255) == PenguinG and math.ceil(v.BackgroundColor3.B*255) == PenguinB then
					SelectedColorUI.Parent = v
				end
			end
		end
	end
end

function Customization:ExitUI()
	-- Make plr visible
	Modules.Character:Visible()
	Modules.Character:Unfreeze()

	-- Update viewport in Penguins UI
	Modules.PenguinsUI:UpdateViewport(CustomizationUI.PenguinSelected.Value)

	-- Tween out UI
	CustomizationUI:TweenPosition(UDim2.new(-1.5, 0, 0.5, 0), "In", "Back", 0.3, true)
	UI.Left.GemDisplay.Visible = true
	UI.Left.Buttons.Visible = true
	UI.Center.Visible = true
	UI.Top.Currencies.MoneyDisplay.BuyMore.Visible = true
	UI.Top.Currencies.GemDisplay.BuyMore.Visible = true

	-- Enable penguin buttons
	for Penguin, v in pairs(Modules.Penguins.Penguins) do
		if Penguin:WaitForChild("Info", 0.5) then
			if Penguin:FindFirstChild("Info") then
				Penguin.Info.ProximityPrompt.Enabled = false
			end
		end
	end

	-- Open previous UI if applicable

	task.wait(0.25)

	if UIToReOpen then
		Modules.Buttons:UIOn(UIToReOpen, true)
		UIToReOpen = nil
	end

	CustomizationUI.Visible = false

	-- Place camera back on the character
	Modules.Camera:ResetToCharacter(false)
end



--- Setting Up Buttons ---
CustomizationUI.ExitCustomization.MouseButton1Down:Connect(function()
	Customization:ExitUI()
end)

CustomizationUI.Customization.Sections.Accessory.Holder.BuyAccessories.MouseButton1Down:Connect(function()
	UIToReOpen = nil
end)

CustomizationUI.Customization.Sections.Outfits.Holder.BuyOutfits.MouseButton1Down:Connect(function()
	UIToReOpen = nil
end)


CustomizationUI.Customization.Sections.Eyes.Holder.BuyEyes.MouseButton1Down:Connect(function()
	UIToReOpen = nil
end)


return Customization
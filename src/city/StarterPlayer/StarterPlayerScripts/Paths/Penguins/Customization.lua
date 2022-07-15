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

	CustomizationUI.PenguinNameBG.PenguinName.TextEditable = true
end)

CustomizationUI.PenguinNameBG.RenameFinish.MouseButton1Down:Connect(function()
	CustomizationUI.PenguinNameBG.Rename.Visible = true
	CustomizationUI.PenguinNameBG.RenameFinish.Visible = false

	CustomizationUI.PenguinNameBG.PenguinName.TextEditable = false
end)

CustomizationUI.PenguinNameBG.PenguinName.FocusLost:Connect(function(x, a)
	local NewName = CustomizationUI.PenguinNameBG.PenguinName.Text

	local Success, FilteredName = Remotes.Customization:InvokeServer("Change Name", CustomizationUI.PenguinSelected.Value, NewName)

	CustomizationUI.PenguinNameBG.PenguinName.Text = FilteredName

	--Modules.PenguinsUI:PenguinInfoUpdated(CustomizationUI.PenguinSelected.Value)
end)

-- 20 max char limit
local PrevName = "nil"

CustomizationUI.PenguinNameBG.PenguinName.Changed:Connect(function(property)
	if property == "Text" then
		local length = string.len(CustomizationUI.PenguinNameBG.PenguinName.Text)

		if length > 20 then
			CustomizationUI.PenguinNameBG.PenguinName.Text = PrevName
		end

		PrevName = CustomizationUI.PenguinNameBG.PenguinName.Text
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

			wait(0.1)
			ColorDB = false
		end)
	end
end



--- UI Functions ---
function Customization:EnterUI(Penguin)
	CustomizationUI.PenguinSelected.Value = Penguin


	-- Disable things for entering ui
	Modules.Character:Freeze()
	UI.Left.GemDisplay.Visible = false
	UI.Left.Buttons.Visible = false
	UI.Center.Visible = false
	UI.Right.Buttons.Visible = false
	UI.BLCorner.GemDisplay.Visible = false


	local Level = Paths.Player:GetAttribute("Level")

	local Income = Modules.GameFunctions:GetPlayerPenguinIncome(Level)
	local UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(Level + 1)

	CustomizationUI.PenguinNameBG.PenguinName.Text = Penguin.HumanoidRootPart.CustomName.PlrName.Text
	CustomizationUI.PenguinNameBG.PenguinLevel.Text = "Level "..Level..' <font color="rgb(38,255,14)">(+ $'..Modules.Format:FormatComma(Income)..")</font>"
	CustomizationUI.Upgrade.TheText.Text = 'Level Up ($ '..Modules.Format:FormatComma(UpgradePrice)..")"


	-- Open Customization UI
	CustomizationUI.Position = UDim2.new(-1.5, 0, 0.5, 0)
	CustomizationUI.Visible = true
	CustomizationUI:TweenPosition(UDim2.new(0.4, 0, 0.5, 0), "Out", "Back", 0.4, true)


	-- Tween Camera to the Penguin
	local CameraAngleCF = Penguin.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(5), math.rad(178), math.rad(0)) * CFrame.new(-3, 0.5, 8)
	Modules.Camera:AttachTo(CameraAngleCF, true)


	-- Set color selected ui to the color the penguin has (if applicable)
	SelectedColorUI.Parent = script
	SelectedAccessoryUI.Parent = script
	SelectedEyesUI.Parent = script


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

	local CurrentOutfit = Penguin:FindFirstChild("Shirt")

	if CurrentOutfit then
		if CustomizationUI.Customization.Sections.Outfits.Holder:FindFirstChild(CurrentOutfit:GetAttribute("ItemName")) then
			SelectedAccessoryUI.Parent = CustomizationUI.Customization.Sections.Outfits.Holder[CurrentOutfit:GetAttribute("ItemName")]
		end
	else
		SelectedAccessoryUI.Parent = CustomizationUI.Customization.Sections.Outfits.Holder["None"]
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
	--Modules.PenguinsUI:UpdateViewport(CustomizationUI.PenguinSelected.Value)

	-- Tween out UI
	CustomizationUI:TweenPosition(UDim2.new(-1.5, 0, 0.5, 0), "In", "Back", 0.3, true)
	UI.Left.Buttons.Visible = true
	UI.Center.Visible = true
	UI.Right.Buttons.Visible = true
	UI.BLCorner.GemDisplay.Visible = true
	wait(0.25)

	CustomizationUI.Visible = false

	-- Place camera back on the character
	Modules.Camera:ResetToCharacter(false)
end



--- Setting Up Buttons ---
CustomizationUI.ExitCustomization.MouseButton1Down:Connect(function()
	Customization:ExitUI()
end)


Paths.UI.Right.Buttons.Customize.MouseButton1Down:Connect(function()
	if Paths.Player.Character then
		Customization:EnterUI(Paths.Player.Character)
	end
end)


return Customization
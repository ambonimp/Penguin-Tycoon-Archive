local Accessories = {}



--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

--- Variables ---
local CustomizationUI = UI.Left.Customization
local SelectedAccessoryUI = Dependency.SelectedAccessory
local SelectedOutfitUI = Dependency.SelectedAccessory
local SelectedEyesUI = Dependency.SelectedEyes

local ProximityPrompt
local ProximityPrompt2

local Store
local StoreSections = UI.Center.Store.Sections

local ClothingSections = UI.Center.Clothing.Sections

local NewItemUI = UI.Full.NewItem

local RarityColors = {
	["Free"] = Color3.fromRGB(240, 240, 240);
	["Regular"] = Color3.fromRGB(0, 200, 255);
	["Rare"] = Color3.fromRGB(0, 200, 255);
	["Epic"] = Color3.fromRGB(217, 0, 255);
	["Legendary"] = Color3.fromRGB(255, 226, 0);
	["Event"] = Color3.fromRGB(220, 55, 55);
}

local InfoModules = {
	["Accessory"] = Modules.AllAccessories,
	["Eyes"] = Modules.AllEyes,
	["Outfits"] = Modules.AllOutfits,
}

-- Timer variables
local RotationTimer = Remotes.GetStat:InvokeServer("Rotation Timer")


--- Load and Setup Accessories ---
local PlayerOutfits
local PlayerAccessories
local PlayerEyes
local EquipDB = false

function addModelToViewport(Model,Template)
	Model = Model:Clone()
	Model.PrimaryPart.Transparency = 1

	local c = Template.ViewportFrame.CurrentCamera or Instance.new("Camera")
	if Template.ViewportFrame:FindFirstChildOfClass("Model") then
		Template.ViewportFrame:FindFirstChildOfClass("Model"):Destroy()
	end
	c.Parent = Template.ViewportFrame
	Template.ViewportFrame.CurrentCamera = c
	c.CFrame = CFrame.new((Model.PrimaryPart.CFrame*CFrame.new(0,-1.25,-6.5)).Position,Model.PrimaryPart.Position)
	Model.Parent = Template.ViewportFrame
	Template.ViewportFrame.Visible = true
end

function Accessories:NewItem(Item, ItemType)
	local StoreSectionUI = nil
	local ClothesSectionUI = nil
	if ItemType ~= "Outfits" then
		StoreSectionUI = StoreSections[ItemType].Holder
	end

	ClothesSectionUI = ClothingSections[ItemType].Holder

	local CustomizationSection = CustomizationUI.Customization.Sections[ItemType].Holder
	-- If the accessory is already in the ui, don't clone it
	if CustomizationSection:FindFirstChild(Item) then return end

	-- Update UI in the store
	if StoreSectionUI and StoreSectionUI:FindFirstChild(Item) then
		StoreSectionUI[Item].Owned.Visible = true
	end
	if ClothesSectionUI and ClothesSectionUI:FindFirstChild(Item) then
		ClothesSectionUI[Item].Owned.Visible = true
	end

	-- Insert new template
	local Template = Dependency.AccessoryTemplate:Clone()
	Template.Name = Item
	Template.AccessoryIcon.Image = if Item == "None" then "rbxassetid://10546227339" else (InfoModules[ItemType].All[Item].Icon or "rbxgameasset://Images/"..Item.."_"..ItemType)
	Template.AccessoryName.Text = Item


	local Module = InfoModules[ItemType]
	local Rarity = assert(Module.All[Item], (Item or "NIL ITEM") .. " " .. "Item").Rarity

	Template.LayoutOrder = Module.RarityInfo[Rarity].PriceInRobux
	Template.BackgroundColor3 = RarityColors[Rarity]
	Template.Stroke.UIStroke.Color = RarityColors[Rarity]

	if Item == "None" or Item == "Default" then
		Template.LayoutOrder = 0
	end

	Template.Parent = CustomizationSection

	-- Equipping the accessory

	Template.MouseButton1Down:Connect(function()
		if EquipDB then return end
		EquipDB = true

		if ItemType == "Accessory" then
			SelectedAccessoryUI.Parent = Template
		elseif ItemType == "Eyes" then
			SelectedEyesUI.Parent = Template
		elseif ItemType == "Outfits" then
			SelectedOutfitUI.Parent = Template
		end

		if ItemType == "Outfits" then
			Remotes.Customization:InvokeServer("Equip "..ItemType, Item)
		else
			local Penguin = CustomizationUI.PenguinSelected.Value
			Remotes.Customization:InvokeServer("Equip "..ItemType, Penguin, Item)
		end

		task.wait(0.3)
		EquipDB = false
	end)
end


-- Loading current player items
coroutine.wrap(function()
	-- Loading accessories
	local PlayerAccessories = Remotes.GetStat:InvokeServer("Accessories")
	repeat PlayerAccessories = Remotes.GetStat:InvokeServer("Accessories") if not PlayerAccessories then wait(1) end until PlayerAccessories

	for Accessory, IsOwned in pairs(PlayerAccessories) do
		if IsOwned then
			Accessories:NewItem(Accessory, "Accessory")
		end
	end

	-- Loading outfits
	local PlayerOutfits = Remotes.GetStat:InvokeServer("Outfits")
	repeat PlayerOutfits = Remotes.GetStat:InvokeServer("Outfits") if not PlayerOutfits then wait(1) end until PlayerOutfits
	for Outfit, IsOwned in pairs(PlayerOutfits) do
		if IsOwned then
			Accessories:NewItem(Outfit, "Outfits")
		end
	end

	-- Loading eyes
	local PlayerEyes = Remotes.GetStat:InvokeServer("Eyes")
	repeat PlayerEyes = Remotes.GetStat:InvokeServer("Eyes") if not PlayerEyes then wait(1) end until PlayerEyes

	for Eyes, IsOwned in pairs(PlayerEyes) do
		if IsOwned then
			Accessories:NewItem(Eyes, "Eyes")
		end
	end
end)()


-- Getting new items
Remotes.Store.OnClientEvent:Connect(function(ActionType, Accessory, Purchased)
	if (ActionType == "Accessory" or ActionType == "Eyes" or ActionType == "Outfits") and Purchased then
		Accessories:NewItem(Accessory, ActionType)
		Accessories:AnimateNewItem(Accessory, ActionType)

	elseif ActionType == "Store Rotated" then
		RotationTimer = Remotes.GetStat:InvokeServer("Rotation Timer")
		Accessories:LoadStore()
	end
end)


CustomizationUI.Customization.Sections.Accessory.Holder.BuyAccessories.MouseButton1Down:Connect(function()
	Modules.Customization:ExitUI()
end)

CustomizationUI.Customization.Sections.Outfits.Holder.BuyOutfits.MouseButton1Down:Connect(function()
	Modules.Customization:ExitUI()
end)


CustomizationUI.Customization.Sections.Eyes.Holder.BuyEyes.MouseButton1Down:Connect(function()
	Modules.Customization:ExitUI()
end)


function Accessories:AnimateNewItem(Item, ItemType)
	-- Reset positions and sizes
	NewItemUI.Position = UDim2.new(0, 0, 1, 0)
	NewItemUI.Visible = true

	-- Setup accessory info
	NewItemUI.ItemName.Text = Item
	NewItemUI.ItemIcon.Image = InfoModules[ItemType].All[Item].Icon or "rbxgameasset://Images/"..Item.."_"..ItemType
	NewItemUI.ViewportFrame.Visible = false
	NewItemUI.ItemIcon.Visible = true

	-- Play animation
	NewItemUI:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Quart", 0.4, true)

	PlayerAccessories = Remotes.GetStat:InvokeServer("Accessories")
	PlayerOutfits = Remotes.GetStat:InvokeServer("Outfits")
	PlayerEyes = Remotes.GetStat:InvokeServer("Eyes")
	if PlayerOutfits["Police Officer"] and ProximityPrompt2 then
		ProximityPrompt2.Enabled = false
	end
end




-- Animate out NewItem screen
NewItemUI.Okay.MouseButton1Down:Connect(function()
	NewItemUI:TweenPosition(UDim2.new(0, 0, 1, 0), "Out", "Quart", 0.4, false)
	NewItemUI.Visible = false
end)



--- Setup Accessory Store ---
local function NewStoreTemplate(Item, ItemType)
	local Module = InfoModules[ItemType]
	
	local Rarity = Module.All[Item].Rarity
	local Template = Dependency.ItemStoreTemplate:Clone()
	Template.Name = Item
	Template.ItemName.Text = Item
	Template.ItemIcon.Image = InfoModules[ItemType].All[Item].Icon or "rbxgameasset://Images/"..Item.."_"..ItemType
	Template.LayoutOrder = Module.RarityInfo[Rarity].PriceInRobux
	Template.PurchaseRobux.TheText.Text = Modules.Format:FormatComma(Module.RarityInfo[Rarity].PriceInRobux)
	Template.PurchaseGems.TheText.Text = Modules.Format:FormatComma(Module.RarityInfo[Rarity].PriceInGems)

	Template.Background.BackgroundColor3 = RarityColors[Rarity]
	Template.Background.UIStroke.Color = RarityColors[Rarity]
	Template.ItemName.TextColor3 = RarityColors[Rarity]
	
	if ItemType == "Eyes" then
		Template.ItemIcon.Size = UDim2.new(0.9, 0, 0.8, 0)
	elseif ItemType == "Outfits" then
		Template.ItemIcon.Size = UDim2.fromScale(0.9, 0.5)
	end
	if PlayerAccessories[Item] or PlayerEyes[Item] or PlayerOutfits[Item] then
		Template.Owned.Visible = true
	else
		Template.PurchaseRobux.MouseButton1Down:Connect(function()
			Remotes.Store:FireServer("Buy Item", Item, ItemType, "Robux")
		end)
		
		Template.PurchaseGems.MouseButton1Down:Connect(function()
			Remotes.Store:FireServer("Buy Item", Item, ItemType, "Gems")
		end)
	end
	if ItemType ~= "Outfits" then
		Template.Parent = StoreSections[ItemType].Holder
	end

	local Template2 = Template:Clone()
	Template2.Parent = ClothingSections[ItemType].Holder
	if Template2 then
		if PlayerAccessories[Item] or PlayerEyes[Item] or PlayerOutfits[Item] then
			Template2.Owned.Visible = true
		else
			Template2.PurchaseRobux.MouseButton1Down:Connect(function()
				Remotes.Store:FireServer("Buy Item", Item, ItemType, "Robux")
			end)
			
			Template2.PurchaseGems.MouseButton1Down:Connect(function()
				Remotes.Store:FireServer("Buy Item", Item, ItemType, "Gems")
			end)

		end

	end

end


function Accessories:LoadStore()
	-- Load player info
	repeat
		PlayerAccessories = Remotes.GetStat:InvokeServer("Accessories")
		--ChosenAccessories = Remotes.GetStat:InvokeServer("Accessory Rotation")

		PlayerOutfits = Remotes.GetStat:InvokeServer("Outfits")

		PlayerEyes = Remotes.GetStat:InvokeServer("Eyes")
		--ChosenEyes = Remotes.GetStat:InvokeServer("Eyes Rotation")
		task.wait(1)
	until PlayerAccessories and PlayerEyes and PlayerOutfits

	-- Clear the UI from any old templates
	for i, v in pairs(StoreSections.Accessory:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
	for i, v in pairs(StoreSections.Eyes:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end

	for i, v in pairs(ClothingSections.Accessory.Holder:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
	for i, v in pairs(ClothingSections.Eyes.Holder:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end


	for i, v in pairs(ClothingSections.Outfits.Holder:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end

	-- Create new store
	for Accessory, v in pairs(Modules.AllAccessories.All) do
		if v.Rarity ~= "Event" and v.Rarity ~= "Free" and v.IsForSale then
			NewStoreTemplate(Accessory, "Accessory")
		end
	end
	for Outfit, v in pairs(Modules.AllOutfits.All) do
		if v.Rarity ~= "Event" and v.Rarity ~= "Free" and v.IsForSale then
			NewStoreTemplate(Outfit, "Outfits")
		end
	end
	for Eyes, v in pairs(Modules.AllEyes.All) do
		if v.Rarity ~= "Event" and v.Rarity ~= "Free" and v.IsForSale then
			NewStoreTemplate(Eyes, "Eyes")
		end
	end
end

Accessories:LoadStore()
--[[
--- Store timer ---
coroutine.wrap(function()
	while true do
		local TimeSinceRotation = os.time() - RotationTimer
		local TimeUntilRotation = Modules.AllAccessories.RotationInterval - TimeSinceRotation

		local Timer = Modules.Format:FormatTimeHMS(TimeUntilRotation)

		StoreSections.Parent.Timer.Text = "New Store In: "..Timer
		ClothingSections.Parent.Timer.Text = "New Store In: "..Timer

		if TimeUntilRotation <= 0 then
			Remotes.Store:FireServer("Rotate Store")
		end

		task.wait(1)
	end
end)()]]

task.spawn(function()
	repeat task.wait() until Modules.PlatformAdjustments and Modules.PlatformAdjustments.CurrentPlatform
	if Modules.PlatformAdjustments.CurrentPlatform == "Mobile" then
		for _, Section in ipairs(ClothingSections:GetChildren()) do
			Section.Holder.UIGridLayout.CellSize = UDim2.new(0.485, 0,0.59, 0)
		end

		for _, Section in ipairs(StoreSections:GetChildren()) do
			if Section.Name == "Accessory" or Section.Name == "Eyes" then
				Section.Holder.UIGridLayout.CellSize = UDim2.new(0.485, 0,0.59, 0)
			end

		end

	end

end)

return Accessories
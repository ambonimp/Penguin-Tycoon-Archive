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
local SelectedEyesUI = Dependency.SelectedEyes

local Store
local StoreSections = UI.Center.Store.Sections.Accessories.Holder

local NewItemUI = UI.Full.NewItem

local RarityColors = {
	["Free"] = Color3.fromRGB(240, 240, 240);
	["Regular"] = Color3.fromRGB(0, 200, 255);
	["Rare"] = Color3.fromRGB(0, 200, 255);
	["Epic"] = Color3.fromRGB(217, 0, 255);
	["Legendary"] = Color3.fromRGB(255, 226, 0);
	["Event"] = Color3.fromRGB(220, 55, 55);
}

-- Timer variables
local RotationTimer = Remotes.GetStat:InvokeServer("Rotation Timer")


--- Load and Setup Accessories ---
local PlayerAccessories
local PlayerEyes
local EquipDB = false

function Accessories:NewItem(Item, ItemType)
	local StoreSectionUI = StoreSections[ItemType]
	local CustomizationSection = CustomizationUI.Customization.Sections[ItemType].Holder
	-- If the accessory is already in the ui, don't clone it
	if CustomizationSection:FindFirstChild(Item) then return end
	
	-- Update UI in the store
	if StoreSectionUI:FindFirstChild(Item) then
		StoreSectionUI[Item].Owned.Visible = true
	end
	
	
	-- Insert new template
	local Template = Dependency.AccessoryTemplate:Clone()
	Template.Name = Item
	Template.AccessoryIcon.Image = "rbxgameasset://Images/"..Item.."_"..ItemType
	Template.AccessoryName.Text = Item
	

	local Module
	if ItemType == "Accessory" then
		Module = Modules.AllAccessories
	elseif ItemType == "Eyes" then
		Module = Modules.AllEyes
	end

	local Rarity = Module.All[Item].Rarity
	Template.LayoutOrder = Module.RarityInfo[Rarity].Price
	Template.BackgroundColor3 = RarityColors[Rarity]
	Template.Stroke.UIStroke.Color = RarityColors[Rarity]
		
	if Item == "None" or Item == "Default" then
		Template.LayoutOrder = 0
	end
	
	Template.Parent = CustomizationSection
	
	Modules.Index.ItemObtained({Name = Item, Rarity = Rarity})
	
	-- Equipping the accessory
	Template.MouseButton1Down:Connect(function()
		if EquipDB then return end
		EquipDB = true
		
		if ItemType == "Accessory" then
			SelectedAccessoryUI.Parent = Template
		elseif ItemType == "Eyes" then
			SelectedEyesUI.Parent = Template
		end
		
		local Penguin = CustomizationUI.PenguinSelected.Value
		Remotes.Customization:InvokeServer("Equip "..ItemType, Penguin, Item)
		
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
	if (ActionType == "Accessory" or ActionType == "Eyes") and Purchased then
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

CustomizationUI.Customization.Sections.Eyes.Holder.BuyEyes.MouseButton1Down:Connect(function()
	Modules.Customization:ExitUI()
end)


function Accessories:AnimateNewItem(Item, ItemType)
	-- Reset positions and sizes
	NewItemUI.Position = UDim2.new(0, 0, 1, 0)
	NewItemUI.Visible = true
	
	-- Setup accessory info
	NewItemUI.ItemName.Text = Item
	NewItemUI.ItemIcon.Image = "rbxgameasset://Images/"..Item.."_"..ItemType
	
	-- Play animation
	NewItemUI:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Quart", 0.4, true)
end



-- Animate out NewItem screen
NewItemUI.Okay.MouseButton1Down:Connect(function()
	NewItemUI:TweenPosition(UDim2.new(0, 0, 1, 0), "Out", "Quart", 0.4, false)
	NewItemUI.Visible = false
end)



--- Setup Accessory Store ---
local function NewStoreTemplate(Item, ItemType)
	local Module
	if ItemType == "Accessory" then
		Module = Modules.AllAccessories
	elseif ItemType == "Eyes" then
		Module = Modules.AllEyes
	end
	
	local Rarity = Module.All[Item].Rarity
	local Template = Dependency.ItemStoreTemplate:Clone()
	Template.Name = Item
	Template.ItemName.Text = Item
	Template.ItemIcon.Image = "rbxgameasset://Images/"..Item.."_"..ItemType
	Template.LayoutOrder = Module.RarityInfo[Rarity].PriceInRobux
	Template.PurchaseRobux.TheText.Text = Modules.Format:FormatComma(Module.RarityInfo[Rarity].PriceInRobux)
	Template.PurchaseGems.TheText.Text = Modules.Format:FormatComma(Module.RarityInfo[Rarity].PriceInGems)

	Template.Background.BackgroundColor3 = RarityColors[Rarity]
	Template.Background.UIStroke.Color = RarityColors[Rarity]
	Template.ItemName.TextColor3 = RarityColors[Rarity]
	
	if ItemType == "Eyes" then
		Template.ItemIcon.Size = UDim2.new(0.9, 0, 0.36, 0)
	end

	if PlayerAccessories[Item] or PlayerEyes[Item] then
		Template.Owned.Visible = true
	else
		Template.PurchaseRobux.MouseButton1Down:Connect(function()
			Remotes.Store:FireServer("Buy Item", Item, ItemType, "Robux")
		end)

		Template.PurchaseGems.MouseButton1Down:Connect(function()
			Remotes.Store:FireServer("Buy Item", Item, ItemType, "Gems")
		end)
	end

	Template.Parent = StoreSections[ItemType]
end


function Accessories:LoadStore()
	-- Load player info
	local ChosenAccessories = nil
	local ChosenEyes = nil
	
	repeat
		PlayerAccessories = Remotes.GetStat:InvokeServer("Accessories")
		ChosenAccessories = Remotes.GetStat:InvokeServer("Accessory Rotation")
		
		PlayerEyes = Remotes.GetStat:InvokeServer("Eyes")
		ChosenEyes = Remotes.GetStat:InvokeServer("Eyes Rotation")
		task.wait(1)
	until PlayerAccessories and ChosenAccessories and ChosenEyes and PlayerEyes
	
	-- Clear the UI from any old templates
	for i, v in pairs(StoreSections.Accessory:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end
	for i, v in pairs(StoreSections.Eyes:GetChildren()) do
		if v:IsA("Frame") then v:Destroy() end
	end

	-- Create new store
	for Accessory, v in pairs(ChosenAccessories) do
		NewStoreTemplate(Accessory, "Accessory")
	end
	for Eyes, v in pairs(ChosenEyes) do
		NewStoreTemplate(Eyes, "Eyes")
	end
end

Accessories:LoadStore()

--- Store timer ---
coroutine.wrap(function()
	while true do
		local TimeSinceRotation = os.time() - RotationTimer
		local TimeUntilRotation = Modules.AllAccessories.RotationInterval - TimeSinceRotation
		
		local Timer = Modules.Format:FormatTimeHMS(TimeUntilRotation)
		
		StoreSections.Parent.Timer.Text = "New Store In: "..Timer
		
		if TimeUntilRotation <= 0 then
			Remotes.Store:FireServer("Rotate Store")
		end
		
		task.wait(1)
	end
end)()


return Accessories
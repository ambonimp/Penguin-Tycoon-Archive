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

local bundleCons = {}
local NewItemUI = UI.Full.NewItem

local Modules = {
	["Accessory"] = Modules.AllAccessories,
	["Eyes"] = Modules.AllEyes,
	["Outfits"] = Modules.AllOutfits,
}

local UnlockItems = {
	"Bunny Ears","Feather Hat","Pirate Captain Hat","Straw Hat"
}

local RarityColors = {
	["Free"] = Color3.fromRGB(240, 240, 240);
	["Regular"] = Color3.fromRGB(0, 200, 255);
	["Rare"] = Color3.fromRGB(0, 200, 255);
	["Epic"] = Color3.fromRGB(217, 0, 255);
	["Legendary"] = Color3.fromRGB(255, 226, 0);
	["Event"] = Color3.fromRGB(220, 55, 55);
}



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
	if table.find(UnlockItems,Item) and workspace["Collectable Accessories"]:FindFirstChild(Item) then
		workspace["Collectable Accessories"]:FindFirstChild(Item):Destroy()
	end
	local StoreSectionUI = nil
	local ClothesSectionUI = nil
	StoreSectionUI = StoreSections.Accessory.Holder[ItemType]
	local CustomizationSection = CustomizationUI.Customization.Sections[ItemType].Holder
	-- If the accessory is already in the u         i, don't clone it
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

	if ItemType ~= "Outfits" then
		Template.AccessoryIcon.Image = Modules[ItemType].All[Item].Icon or "rbxgameasset://Images/"..Item.."_"..ItemType
	else
		if Item ~= "None" then
			local Model = assert(Services.RStorage.Assets.Shirts:FindFirstChild(Item), Item)
			addModelToViewport(Model,Template)
			Template.AccessoryIcon.Image = ""
		else
			Template.AccessoryIcon.Image = "rbxassetid://16201262"
		end
	end
	Template.AccessoryName.Text = Item
	

	local Module = Modules[ItemType]

	local Rarity = assert(Module.All[Item], Item).Rarity
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
		
		if ActionType == "Outfits" then
			PlayerOutfits[Accessory] = true
			local AllOutfits = Paths.Modules.AllOutfits
			local Bundles = AllOutfits.Bundles
			for i,bundle in pairs (StoreSections.Accessory.Holder.Bundles:GetChildren()) do
				local id = bundle:GetAttribute("BundleNumber")
				if id then
					local ownsAll = true
					for i,v in pairs (Bundles[id].Outfits) do
						if not PlayerOutfits[v[1]] then
							ownsAll = false
							break
						end
					end
					if ownsAll then
						bundle.Owned.Visible = true
						if bundleCons[id] then
							bundleCons[id]:Disconnect()
						end
					end
				end
			end
		end
		
	elseif ActionType == "Store Rotated" then
		--RotationTimer = Remotes.GetStat:InvokeServer("Rotation Timer")
		--Accessories:LoadStore()
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

	if ItemType ~= "Outfits" then
		NewItemUI.ItemIcon.Image = Modules[ItemType].All[Item].Icon or "rbxgameasset://Images/"..Item.."_"..ItemType
		NewItemUI.ViewportFrame.Visible = false
		NewItemUI.ItemIcon.Visible = true
		if NewItemUI.ViewportFrame:FindFirstChildOfClass("Model") then
			NewItemUI.ViewportFrame:FindFirstChildOfClass("Model"):Destroy()
		end
	else
		NewItemUI.ItemIcon.Visible = false
		NewItemUI.ViewportFrame.Visible = true
		local Model = assert(Services.RStorage.Assets.Shirts:FindFirstChild(Item), Item)
		addModelToViewport(Model,NewItemUI)
	end

	
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
	local Module
	if ItemType == "Accessory" then
		Module = Modules.AllAccessories
	elseif ItemType == "Eyes" then
		Module = Modules.AllEyes
	elseif ItemType == "Outfits" then
		Module = Modules.AllOutfits
	end
	
	local Rarity = Module.All[Item].Rarity
	local Template = Dependency.ItemStoreTemplate:Clone()
	Template.Name = Item
	Template.ItemName.Text = Item
	if ItemType == "Outfits" then
		local Model = Services.RStorage.Assets.Shirts:FindFirstChild(Item)
		addModelToViewport(Model,Template)
	else
		Template.ItemIcon.Image = Modules[ItemType].All[Item].Icon or "rbxgameasset://Images/"..Item.."_"..ItemType
	end
	Template.LayoutOrder = Module.RarityInfo[Rarity].PriceInRobux
	Template.PurchaseRobux.TheText.Text = Modules.Format:FormatComma(Module.RarityInfo[Rarity].PriceInRobux)
	Template.PurchaseGems.TheText.Text = Modules.Format:FormatComma(Module.RarityInfo[Rarity].PriceInGems)

	Template.Background.BackgroundColor3 = RarityColors[Rarity]
	Template.Background.UIStroke.Color = RarityColors[Rarity]
	Template.ItemName.TextColor3 = RarityColors[Rarity]
	
	if ItemType == "Eyes" then
		Template.ItemIcon.Size = UDim2.new(0.9, 0, 0.36, 0)
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
	local Template2 = Template:Clone()
	--if ItemType ~= "Outfits" then
		Template.Parent = StoreSections.Accessory.Holder[ItemType]
	--end
	
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



--Store accessory buttons & Bundles
do
	
	local UI = Paths.UI.Center.Store.Sections.Accessory.Holder
	local Buttons = UI.Buttons

	local lastOpen = Buttons.Accessory

	function Accessories.OpenFrame(button)
		lastOpen.BackgroundTransparency = .8
		UI:FindFirstChild(lastOpen.Name).Visible = false
		button.BackgroundTransparency = 0
		UI:FindFirstChild(button.Name).Visible = true
		lastOpen = button
	end

	for i,button in pairs (Buttons:GetChildren()) do
		if button:IsA("ImageButton") then
			button.MouseButton1Down:Connect(function()
				Accessories.OpenFrame(button)
			end)
		end
	end


	local AllOutfits = Paths.Modules.AllOutfits
	local Bundles = AllOutfits.Bundles


	function connectTimer(text,expires)
		task.spawn(function()
			local timeLeft = expires-os.time()
			while timeLeft > 0 do
				timeLeft = expires-os.time()
				local t = os.date('!%d:%H:%M:%S', timeLeft)
				text.Text = t
				task.wait(1)
			end
			text.Parent.Visible = false
		end)
	end

	for i,Bundle in pairs (UI.Bundles:GetChildren()) do --currently only one bundle so UI already exists.. will make it create the UI for multiple bundles in the future
		local id = Bundle:GetAttribute("BundleNumber")
		if id then
			local ownsAll = true
			for i,v in pairs (Bundles[id].Outfits) do
				if not PlayerOutfits[v[1]] then
					ownsAll = false
					break
				end
			end
			
			if ownsAll then
				Bundle.Owned.Visible = true
			else
				connectTimer(Bundle.TimeLeft,Bundles[id].Expires)
				bundleCons[id] = Bundle.PurchaseRobux.MouseButton1Down:Connect(function()
					Services.MPService:PromptProductPurchase(Paths.Player, Bundles[id].DevId)--
				end)
			end
			
		end
	end
	
end

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
		for _, Section in ipairs(StoreSections.Accessory.Holder:GetChildren()) do
			if Section.Name ~= "Buttons" and Section.Name ~= "Bundles" then
				Section.UIGridLayout.CellSize = UDim2.new(0.485, 0,0.59, 0)
			end
		end

	end

end)



return Accessories
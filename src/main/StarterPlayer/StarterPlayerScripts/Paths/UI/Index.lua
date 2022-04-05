local Index = {}

--- Main variables ---
local paths = require(script.Parent.Parent)

local Dependency = paths.Dependency:FindFirstChild(script.Name)

local services = paths.Services
local modules = paths.Modules
local remotes = paths.Remotes

local rarityColors = {
	["Free"] = Color3.fromRGB(240, 240, 240);
	["Regular"] = Color3.fromRGB(0, 200, 255);
	
	["Common"] = Color3.fromRGB(240, 240, 240),
	["Rare"] = Color3.fromRGB(47, 155, 255),
	["Epic"] = Color3.fromRGB(167, 25, 255),
	["Legendary"] = Color3.fromRGB(251, 255, 0),
	["Mythic"] = Color3.fromRGB(227, 53, 53),
	
	["Event"] = Color3.fromRGB(220, 55, 55);
}

local rarityLayoutNumbers = {
	["Free"] = -2;
	["Regular"] = -1;
	
	["Common"] = 1,
	["Rare"] = 10,
	["Epic"] = 100,
	["Legendary"] = 1000,
	["Mythic"] = 10000,
	
	["Event"] = 100000;
}



--- UI Variables ---
local playerFish = remotes.GetStat:InvokeServer("Fish Found")
local playerEnchantedFish = remotes.GetStat:InvokeServer("Enchanted Fish Found")
local playerAccessories = remotes.GetStat:InvokeServer("Accessories")
local playerEyes = remotes.GetStat:InvokeServer("Eyes")
local indexUI = paths.UI.Center.Index
local newFishUI = paths.UI.Full.NewFish



--- Initialize section buttons ---
local debounce = false
local PreviousOpen = indexUI.Sections.Fish
indexUI.Sections.Fish.Visible = true
indexUI.Sections.Fish.Position = UDim2.new(0.5, 0, 0.5, 0)
indexUI.Buttons.Fish.BackgroundTransparency = 0.2

local function ButtonClicked(button)
	if debounce then return end
	debounce = true

	-- If button clicked is the same as previous open, just turn it off
	if PreviousOpen ~= indexUI.Sections[button.Name] then
		-- Out
		PreviousOpen:TweenPosition(UDim2.new(0.5, 0, 1.7, 0), "Out", "Quart", 0.2, true)
		indexUI.Buttons[PreviousOpen.Name].BackgroundTransparency = 0.8

		-- In
		indexUI.Sections[button.Name].Position = UDim2.new(0.5, 0, 1.7, 0)
		indexUI.Sections[button.Name]:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quart", 0.2, true)
		indexUI.Sections[button.Name].Visible = true
		button.BackgroundTransparency = 0.2

		task.wait(0.15)
		PreviousOpen.Visible = false
		PreviousOpen = indexUI.Sections[button.Name]
	end

	debounce = false
end

for i, Button in pairs(indexUI.Buttons:GetChildren()) do
	Button.MouseButton1Down:Connect(function()
		ButtonClicked(Button)
	end)
end



--- New Fish Unlocked Animation ---
function Index.NewFishUnlocked(fishInfo)
	-- Reset positions and sizes
	newFishUI.Position = UDim2.new(0, 0, 1, 0)
	newFishUI.Visible = true

	-- Setup accessory info
	newFishUI.FishName.Text = fishInfo.Name
	newFishUI.FishIcon.Image = "rbxgameasset://Images/"..fishInfo.Name.."_Fish"
	
	newFishUI.FishRarity.Text = fishInfo.Rarity.." ("..indexUI.Sections.Fish.Holder.List[tostring(fishInfo.Id)].FishRarity.Text..")"
	newFishUI.FishRarity.TextColor3 = rarityColors[fishInfo.Rarity]
	newFishUI.NewFish.TextColor3 = rarityColors[fishInfo.Rarity]

	-- Play animation
	newFishUI:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Quart", 0.4, true)
end

newFishUI.Okay.MouseButton1Down:Connect(function()
	newFishUI:TweenPosition(UDim2.new(0, 0, 1, 0), "Out", "Quart", 0.4, false)
	newFishUI.Visible = false
end)


--- Index Functions ---
function Index.FishCaught(fishInfo, isNew)
	local isEnchanted = fishInfo.Enchanted
	local fishInfo = fishInfo.LootInfo
	
	if indexUI.Sections.Fish.Holder.List:FindFirstChild(tostring(fishInfo.Id)) then
		local Template = indexUI.Sections.Fish.Holder.List[tostring(fishInfo.Id)]
		Template.FishName.Text = fishInfo.Name
		Template.Background.BackgroundColor3 = rarityColors[fishInfo.Rarity]
		Template.Background.UIStroke.Color = rarityColors[fishInfo.Rarity]
		Template.FishIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		
		-- if it's a new fish then add it to the local table so it's not necessary to request it from the server
		if isNew then
			if not playerFish[tostring(fishInfo.Id)] then
				Index.NewFishUnlocked(fishInfo)
				playerFish[tostring(fishInfo.Id)] = 0
			end
		end
		
		if isEnchanted then
			if not playerEnchantedFish[tostring(fishInfo.Id)] then 
				playerEnchantedFish[tostring(fishInfo.Id)] = 0 
				Template.FishAmount.Position = UDim2.new(0.5, 0, 0.39, 0)
				Template.EnchantedFishAmount.Visible = true
			end
			playerEnchantedFish[tostring(fishInfo.Id)] += 1
			Template.EnchantedFishAmount.Text = "x"..playerEnchantedFish[tostring(fishInfo.Id)]
			
		else
			playerFish[tostring(fishInfo.Id)] += 1
			Template.FishAmount.Text = "x"..playerFish[tostring(fishInfo.Id)]
		end
	end
end

function Index.ItemObtained(Info)
	if indexUI.Sections.Accessories.Accessories.List:FindFirstChild(Info.Name) or indexUI.Sections.Accessories.Eyes.List:FindFirstChild(Info.Name) then
		local Template = indexUI.Sections.Accessories.Accessories.List:FindFirstChild(Info.Name) or indexUI.Sections.Accessories.Eyes.List:FindFirstChild(Info.Name)
		Template.Background.BackgroundColor3 = rarityColors[Info.Rarity]
		Template.Background.UIStroke.Color = rarityColors[Info.Rarity]
		Template.ItemIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end
end


-- Loading fish
local function LoadAllFish()
	-- Load fish templates
	for id, fishInfo in pairs(modules.FishingConfig.ItemList) do
		if not fishInfo.Rarity then continue end
		
		fishInfo.Id = id
		
		local Template = Dependency.FishTemplate:Clone()
		
		Template.FishRarity.TextColor3 = rarityColors[fishInfo.Rarity]
		Template.FishIcon.Image = "rbxgameasset://Images/"..fishInfo.Name.."_Fish"
		
		Template.Name = id
		Template.Parent = indexUI.Sections.Fish.Holder.List
		
		if playerFish[tostring(id)] then
			Index.FishCaught({Enchanted = false, LootInfo = fishInfo}, false)
		end
	end
	
	for enchantedFish, amount in pairs(playerEnchantedFish) do
		local Template = indexUI.Sections.Fish.Holder.List[tostring(enchantedFish)]
		
		Template.FishAmount.Position = UDim2.new(0.5, 0, 0.39, 0)
		Template.EnchantedFishAmount.Visible = true
		Template.EnchantedFishAmount.Text = "x"..playerEnchantedFish[tostring(enchantedFish)]
	end
	
	-- Load fish %
	table.sort(modules.FishingConfig.ChanceTable, function(a, b) return a.Percentage < b.Percentage end)
	
	for zone, fishes in pairs(modules.FishingConfig.ChanceTable) do
		for i, fishInfo in pairs(fishes) do
			if indexUI.Sections.Fish.Holder.List:FindFirstChild(tostring(fishInfo.Id)) then
				local percentageDecimal = fishInfo.Percentage
				if i > 1 then percentageDecimal = fishInfo.Percentage - fishes[i-1].Percentage end
				local percentageRounded = math.floor((percentageDecimal + 0.000001) * 100000)/1000
				indexUI.Sections.Fish.Holder.List[tostring(fishInfo.Id)].FishRarity.Text = percentageRounded.."%"
				
				indexUI.Sections.Fish.Holder.List[tostring(fishInfo.Id)].LayoutOrder = (100 - percentageRounded) * 10 * rarityLayoutNumbers[modules.FishingConfig.ItemList[fishInfo.Id].Rarity]
			end
		end
	end
end

local function LoadAllItems()
	-- Load Accessories
	for Accessory, Info in pairs(modules.AllAccessories.All) do
		Info.Name = Accessory

		local Template = Dependency.ItemTemplate:Clone()
		Template.ItemName.Text = Accessory
		Template.ItemRarity.Text = Info.Rarity
		Template.ItemRarity.TextColor3 = rarityColors[Info.Rarity]
		Template.ItemIcon.Image = "rbxgameasset://Images/"..Accessory.."_Accessory"

		Template.Name = Accessory
		Template.Parent = indexUI.Sections.Accessories.Accessories.List
		
		if Accessory == "None" then
			Template.LayoutOrder = -10
		else
			Template.LayoutOrder = rarityLayoutNumbers[Info.Rarity]
		end

		if playerAccessories[Accessory] then
			Index.ItemObtained(Info)
		end
	end
	
	-- Load Eyes
	for Eyes, Info in pairs(modules.AllEyes.All) do
		Info.Name = Eyes

		local Template = Dependency.ItemTemplate:Clone()
		Template.ItemName.Text = Eyes
		Template.ItemRarity.Text = Info.Rarity
		Template.ItemRarity.TextColor3 = rarityColors[Info.Rarity]
		Template.ItemIcon.Image = "rbxgameasset://Images/"..Eyes.."_Eyes"

		Template.Name = Eyes
		Template.Parent = indexUI.Sections.Accessories.Eyes.List
		
		if Eyes == "Default" then
			Template.LayoutOrder = -10
		else
			Template.LayoutOrder = rarityLayoutNumbers[Info.Rarity]
		end

		if playerEyes[Eyes] then
			Index.ItemObtained(Info)
		end
	end
end

coroutine.wrap(function()
	LoadAllFish()
	LoadAllItems()
end)()



return Index
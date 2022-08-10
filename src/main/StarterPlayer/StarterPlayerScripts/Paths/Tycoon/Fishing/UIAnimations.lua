local UIAnimations = {}

--- Main variables ---
local paths = require(script.Parent.Parent.Parent)

local services = paths.Services
local modules = paths.Modules
local remotes = paths.Remotes

local rarityColors = {
	["Common"] = Color3.fromRGB(220, 220, 220),
	["Rare"] = Color3.fromRGB(47, 155, 255),
	["Epic"] = Color3.fromRGB(167, 25, 255),
	["Legendary"] = Color3.fromRGB(251, 255, 0),
	["Mythic"] = Color3.fromRGB(227, 53, 53),
}


-- ui
local fishCaught = paths.UI.Bottom.FishCaught
local gemsCaught = paths.UI.Bottom.GemsCaught
local junkCaught = paths.UI.Bottom.JunkCaught
local threeCaught = paths.UI.Bottom.ThreeCaught
local newFish = paths.UI.Full.NewFish

local isStillPlaying = 1

local config = modules.FishingConfig
local itemTypes = config.ItemType

function UIAnimations.TripleFish(result)
	isStillPlaying += 1
	task.spawn(function()
		local currentAnim = isStillPlaying
		threeCaught.Visible = false
		threeCaught.Position = UDim2.new(0.5, 0, 1.25, 0)

		for i = 1,3 do
			local result = result[i]
			local lootInfo = result.LootInfo
			local fishCaught = threeCaught.Frame:FindFirstChild("Fish"..i)

			if lootInfo.Type == itemTypes.Hat then
				fishCaught.Visible = false
			elseif lootInfo.Type == itemTypes.Gem then
				fishCaught.Visible = true
				fishCaught.FishRarity.Visible = false
				fishCaught.Amount.Visible = false
				fishCaught.Icon.Image = "rbxassetid://8679117564"
				fishCaught.FishReward.Text = "+ ".. lootInfo.Gems
				fishCaught.FishName.Text = "Gem"
			elseif lootInfo.Type == itemTypes.Junk then
				local junkCaught = fishCaught
				junkCaught.FishRarity.Visible = true
				junkCaught.Visible = true
				junkCaught.Amount.Visible = true
				if result.Amount and result.Amount <= 200 then
					junkCaught.Amount.Text = result.Amount.."/200"
					junkCaught.Amount.Visible = true
					if result.Amount == 1 then
						paths.Modules.Setup:Notification("Collect 200 "..lootInfo.Name.." for the "..lootInfo.Name.." hat!",Color3.new(1, 0.760784, 0.4),8.5)
					end
				else
					junkCaught.Amount.Visible = false
				end
				-- Setup info
				junkCaught.FishName.Text = lootInfo.Name
				junkCaught.FishRarity.Text = "Junk"
				junkCaught.FishReward.Text = "+ $ "..paths.Modules.Format:FormatComma(math.floor(tonumber(result.Worth)))
				junkCaught.Icon.Image = "rbxgameasset://Images/"..lootInfo.Name.."_Junk"

			else
				local icon
				for _, details in pairs(config.ItemList) do
					if details.Name == lootInfo.Name then
						icon = details.Icon
						break
					end
				end

				fishCaught.Visible = true
				fishCaught.FishRarity.Visible = true
				fishCaught.Amount.Visible = false
				fishCaught.FishName.Text = lootInfo.Name
				fishCaught.FishRarity.Text = lootInfo.Rarity
				fishCaught.FishReward.Text = "+ $ "..paths.Modules.Format:FormatComma(math.floor(tonumber(result.Worth)))
				fishCaught.Icon.Image = icon or "rbxgameasset://Images/"..lootInfo.Name.."_Fish"

				fishCaught.BackgroundColor3 = rarityColors[lootInfo.Rarity]
				fishCaught.UIStroke.Color = rarityColors[lootInfo.Rarity]
				fishCaught.FishRarity.TextColor3 = rarityColors[lootInfo.Rarity]
				fishCaught.FishRarity.UIStroke.Color = Color3.new(rarityColors[lootInfo.Rarity].R/2, rarityColors[lootInfo.Rarity].G/2, rarityColors[lootInfo.Rarity].B/2)

				if result.Enchanted then
					fishCaught.FishRarity.Text = lootInfo.Rarity--.. " [ENCHANTED]"
					fishCaught.UIStroke.Color = Color3.fromRGB(255, 255, 255)
					fishCaught.FishRarity.TextColor3 = Color3.fromRGB(255, 255, 255)
				end

				fishCaught.UIStroke.Enchanted.Enabled = result.Enchanted
				fishCaught.FishRarity.Enchanted.Enabled = result.Enchanted
			end

		end
		threeCaught.Visible = true
		threeCaught:TweenPosition(UDim2.new(0.5, 0, -.150, 0), "Out", "Back", 0.5, true)
	
		task.wait(2)
	
		threeCaught:TweenPosition(UDim2.new(0.5, 0, 1.25, 0), "In", "Back", 0.5, true)	

		task.wait(0.6)

		if isStillPlaying == currentAnim then
			threeCaught.Visible = false
		end
	end)
end

--- Animation Functions ---
function UIAnimations.FishRetrievedAnimation(result)
	isStillPlaying += 1


	task.spawn(function()
		local currentAnim = isStillPlaying
		local icon
		for _, details in pairs(config.ItemList) do
			if details.Name == result.LootInfo.Name then
				icon = details.Icon
				break
			end

		end

		-- Reset positions and sizes
		fishCaught.Position = UDim2.new(0.5, 0, 1, 0)

		-- Setup info
		fishCaught.FishName.Text = result.LootInfo.Name
		fishCaught.FishRarity.Text = result.LootInfo.Rarity
		fishCaught.FishReward.Text = "+ $ "..paths.Modules.Format:FormatComma(math.floor(tonumber(result.Worth)))
		fishCaught.FishIcon.Image = icon or "rbxgameasset://Images/"..result.LootInfo.Name.."_Fish"

		fishCaught.BackgroundColor3 = rarityColors[result.LootInfo.Rarity]
		fishCaught.UIStroke.Color = rarityColors[result.LootInfo.Rarity]
		fishCaught.FishRarity.TextColor3 = rarityColors[result.LootInfo.Rarity]
		fishCaught.FishRarity.UIStroke.Color = Color3.new(rarityColors[result.LootInfo.Rarity].R/2, rarityColors[result.LootInfo.Rarity].G/2, rarityColors[result.LootInfo.Rarity].B/2)

		if result.Enchanted then
			fishCaught.FishRarity.Text = result.LootInfo.Rarity--.. " [ENCHANTED]"
			fishCaught.UIStroke.Color = Color3.fromRGB(255, 255, 255)
			fishCaught.FishRarity.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		fishCaught.UIStroke.Enchanted.Enabled = result.Enchanted
		fishCaught.FishRarity.Enchanted.Enabled = result.Enchanted

		-- Play animation
		fishCaught.Visible = true

		fishCaught:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Back", 0.5, true)

		task.wait(2)

		fishCaught:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.5, true)

		task.wait(0.6)

		if isStillPlaying == currentAnim then
			fishCaught.Visible = false
		end
	end)
end

function UIAnimations.JunkRetrievedAnimation(result)
	coroutine.wrap(function()
		-- Reset positions and sizes
		junkCaught.Position = UDim2.new(0.5, 0, 1, 0)
		if result.Amount and result.Amount <= 200 then
			junkCaught.Amount.Text = result.Amount.."/200"
			junkCaught.Amount.Visible = true
			if result.Amount == 1 then
				paths.Modules.Setup:Notification("Collect 200 "..result.LootInfo.Name.." for the "..result.LootInfo.Name.." hat!",Color3.new(1, 0.760784, 0.4),8.5)
			end
		else
			junkCaught.Amount.Visible = false
		end
		-- Setup info
		junkCaught.FishName.Text = result.LootInfo.Name
		junkCaught.FishRarity.Text = "Junk"
		junkCaught.FishReward.Text = "+ $ "..paths.Modules.Format:FormatComma(math.floor(tonumber(result.Worth)))
		junkCaught.FishIcon.Image = "rbxgameasset://Images/"..result.LootInfo.Name.."_Junk"

		-- Play animation
		junkCaught.Visible = true

		junkCaught:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Back", 0.5, true)

		task.wait(2)

		junkCaught:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.5, true)

		task.wait(0.6)

	 	junkCaught.Visible = false
	end)()
end

function UIAnimations.GemsRetrievedAnimation(result)
	coroutine.wrap(function()
		-- Reset positions and sizes
		gemsCaught.Position = UDim2.new(0.5, 0, 1, 0)
		
		-- Set texts
		gemsCaught.GemReward.Text = "+ "..result.LootInfo.Gems

		-- Play animation
		gemsCaught.Visible = true

		gemsCaught:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Back", 0.5, true)

		task.wait(2)

		gemsCaught:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.5, true)

		task.wait(0.6)

		gemsCaught.Visible = false
	end)()
end





return UIAnimations
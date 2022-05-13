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
local newFish = paths.UI.Full.NewFish

local isStillPlaying = 1


--- Animation Functions ---
function UIAnimations.FishRetrievedAnimation(result)
	isStillPlaying += 1

	coroutine.wrap(function()
		local currentAnim = isStillPlaying

		-- Reset positions and sizes
		fishCaught.Position = UDim2.new(0.5, 0, 1, 0)

		-- Setup info
		fishCaught.FishName.Text = result.LootInfo.Name
		fishCaught.FishRarity.Text = result.LootInfo.Rarity
		fishCaught.FishReward.Text = "+ $ "..paths.Modules.Format:FormatComma(math.floor(tonumber(result.Worth)))
		fishCaught.FishIcon.Image = "rbxgameasset://Images/"..result.LootInfo.Name.."_Fish"

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

		wait(2)

		fishCaught:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.5, true)

		wait(0.6)

		if isStillPlaying == currentAnim then
			fishCaught.Visible = false
		end
	end)()
end

function UIAnimations.JunkRetrievedAnimation(result)
	coroutine.wrap(function()
		-- Reset positions and sizes
		junkCaught.Position = UDim2.new(0.5, 0, 1, 0)
		print(result)
		if result.Amount and result.Amount <= 200 then
			junkCaught.Amount.Text = result.Amount.."/200"
			junkCaught.Amount.Visible = true
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

		wait(2)

		junkCaught:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.5, true)

		wait(0.6)

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

		wait(2)

		gemsCaught:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.5, true)

		wait(0.6)

		gemsCaught.Visible = false
	end)()
end





return UIAnimations
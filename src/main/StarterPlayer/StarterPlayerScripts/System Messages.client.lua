local StarterGui = game:GetService("StarterGui")


local path = require(script.Parent)
local remotes = path.Remotes
local modules = path.Modules

local fishingConfig = require(script.Parent.Fishing.Config)

local FISH_RARITY_COLORS = {
	["Common"] = Color3.fromRGB(240, 240, 240),
	["Rare"] = Color3.fromRGB(47, 155, 255),
	["Epic"] = Color3.fromRGB(167, 25, 255),
	["Legendary"] = Color3.fromRGB(251, 255, 0),
	["Mythic"] = Color3.fromRGB(227, 53, 53),
	["Gem"] = Color3.fromRGB(0, 184, 250),
	["Hat"] = Color3.fromRGB(0, 231, 19)
}
local Messages = {
	"[SOCIAL] Have an idea for the game? You can suggest it at any of our social links!";
	"[SOCIAL] Support us by leaving a thumbs up!";
	"[SOCIAL] Follow us on social media for exclusive codes!";
	"[SOCIAL] Follow our twitter for a 10% income bonus!";
	"[SOCIAL] Check out our Social Links at the bottom of the Game Page!";
}

local function getFishPercentage(id)
	for _, data in pairs(fishingConfig.ChanceTable) do
		for i, entry in ipairs(data) do
			if id == entry.Id then
				local previous = 0
				if data[i-1] then
					previous = data[i-1].Percentage
				end
				return (entry.Percentage - previous) * 100

			end

		end

	end

end

local function MakeMessage(Message, colour)
	StarterGui:SetCore("ChatMakeSystemMessage",{
		Text = Message;
		Color = colour;
		Font = Enum.Font.FredokaOne;
		FontSize = Enum.FontSize.Size28;
	})
end

MakeMessage("Welcome to Penguin Tycoon!")

while true do
	task(600)
	local RandomMessage = Messages[Random.new():NextInteger(1, #Messages)]
	MakeMessage(RandomMessage, Color3.new(73/255, 155/255, 255/255))
end

remotes.Announcement.OnClientEvent:Connect(function(player, item)
	if item == nil then
		item = player
		player = game.Players.LocalPlayer
	end
	local decimals


	local fishChance = getFishPercentage(item.Id)
	-- fish notification
	if item.Type == "Fish" and (item.Rarity == 'Legendary' or item.Rarity == 'Mythic') then
		if item.Rarity == 'Legendary' then decimals = 3
		elseif item.Rarity == 'Mythic' then decimals = 4
		end
		modules.FuncLib.SendMessage(
			string.format("FISHING] %s has just caught a %s %s (%." .. decimals .."f%%)!", player.Name, string.lower(item.Rarity), item.Name, fishChance),
			FISH_RARITY_COLORS[item.Rarity]
		)
	-- gem notification
	elseif item.Type == "Gem" and item.Name == "Treasure Chest" then
		decimals = 2
		modules.FuncLib.SendMessage(
			string.format("FISHING] %s has just caught a %s (%." .. decimals .."f%%)!", player.Name, item.Name, tostring(item.Gems), fishChance),
			FISH_RARITY_COLORS[item.Type]
		)
	elseif item.Type == "Hat" then
		decimals = 3
		modules.FuncLib.SendMessage(
			string.format("FISHING] %s has just caught a %s (%." .. decimals .."f%%)!", player.Name, "random hat", fishChance),
			FISH_RARITY_COLORS[item.Type]
		)
	elseif item.Type == "Poofie" then
		decimals = 3
		modules.FuncLib.SendMessage(
			string.format("[POOFIE] %s just hatched a legendary!", item.Name, item.RealName),
			Color3.fromRGB(255, 217, 0)
		)
	elseif item.Type == "Badge" then
		modules.FuncLib.SendMessage(
			string.format("[BADGE] %s has unlocked the '%s' badge!", player.Name, item.Name),
			Color3.fromRGB(110, 13, 102)
		)
	elseif item.Type == "PremiumPlayer" then
		modules.FuncLib.SendMessage(
			string.format("[PREMIUM] Premium member %s has just joined!", player.Name),
			Color3.fromRGB(205, 167, 94)
		)
	elseif item.Type == "GroupJoin" then
		modules.FuncLib.SendMessage(
			string.format("[GROUP] %s has joined the group and received $5,000!", player.Name),
			Color3.fromRGB(34, 144, 31)
		)
	end

end)

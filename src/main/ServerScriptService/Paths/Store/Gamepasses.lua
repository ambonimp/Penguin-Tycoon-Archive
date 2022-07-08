-- Handles gamepass purchasing, checking and applying

local Gamepasses = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local PopupPurchase = {}
local EventHandler = game:GetService("ServerStorage"):FindFirstChild("EventHandler")

--- Gamepass Variables ---
local AllGamepasses = {
	25313170, -- x2 Income
	26268187, -- Faster Speed
	26268229, -- Double Jump
	26269102, -- VIP
	28927736, -- Gold Fishing Rod
	41205566, -- Luxury Boat
	41205759, -- Powered Glider
	43183311, -- Gold Axe
	45764173, -- Jet,
	47438416, --rainbow fishing rod,
	47438471, -- x2 gems
	47438595, -- map teleport
	49090546, -- x3 fish capture
	52724179, -- Golden Pickaxe
	55102286, -- pets +100
	55102169, -- pets +300
	56637668, -- auto hatch
	56844198, -- lucky egg
}

local GamepassButtons = {
	[28927736] = "Gold Fishing Rod#1",
	[41205566] = "Luxury Boat#1",
	[41205759] = "Powered Glider#1",
	[43183311] = "Gold Axe#1",
	[45764173] = "Jet Plane#1",
	[47438416] = "Rainbow Fishing Rod#1",
	[52724179] = "Gold Pickaxe#1",
	[58998843] = "Chainsaw#1",
}


--- Functions ---

-- Applies the gamepass effect
-- playerName: String, gamepass: Integer (gamepass id)
function Gamepasses:ApplyGamepass(playerName, gamepass)
	local Data = Modules.PlayerData.sessionData[playerName]
	local Player = game.Players:FindFirstChild(playerName)

	if Data and Player then
		local AppliedPasses = Data["Applied Gamepasses"]
		-- If the Gamepass isn't already applied then apply it
		if not AppliedPasses[tostring(gamepass)] then
			Data["Applied Gamepasses"][tostring(gamepass)] = true
			Remotes.Store:FireClient(Player, "Gamepass", gamepass, true)
			--x2 gems
			if gamepass == 47438471 then
				Data["Gem Multiplier"] *= 2
				--x2 income
			elseif gamepass == 25313170 then
				Data["Income Multiplier"] *= 2

			-- Faster Speed
			elseif gamepass == 26268187 then
				Data["Walkspeed Multiplier"] *= 1.6

				local Char = Player.Character

				if Char and Char:FindFirstChild("Humanoid") then
					Char.Humanoid.WalkSpeed *= 1.6
				end

			-- VIP
			elseif gamepass == 26269102 then
				Modules.Chat:ApplyChatTag(Player)

			-- Tool upgrades
			elseif gamepass == 28927736 then
				Modules.Tools.AddTool(Player, "Gold Fishing Rod")
			elseif gamepass == 52724179 then
				Modules.Tools.AddTool(Player, "Gold Pickaxe")
			elseif gamepass == 47438416 then
				Modules.Tools.AddTool(Player, "Rainbow Fishing Rod")
			elseif gamepass == 58998843 then
				Modules.Tools.AddTool(Player, "Chainsaw")
			-- Pet storage gamepasses
			elseif gamepass == 55102286 then
				Data["Pets_Data"].MaxOwned += 300
				Player:SetAttribute("MaxPetsOwned",Data["Pets_Data"].MaxOwned)
			elseif gamepass == 55102169 then
				Data["Pets_Data"].MaxOwned += 100
				Player:SetAttribute("MaxPetsOwned",Data["Pets_Data"].MaxOwned)
			elseif gamepass == 56637668 then
				Data["Settings"]["Auto Hatch"] = true
			end

		end

		-- Gamepass buttons/tycoon item

	end
end


-- gives the gamepass to the player in the data & applies its effect
-- playerName: String, gamepass: Integer (gamepass id)
function Gamepasses:AwardGamepass(playerName, gamepass)
	if game.Players:FindFirstChild(playerName) then
		local Player = game.Players:FindFirstChild(playerName)
		local Data = Modules.PlayerData.sessionData[playerName]

		if Data and Player then
			-- Give Gamepass to player's inventory
			if gamepass == 49090546 then
				Player:SetAttribute("ThreeFish",true)
			end
			Data["Gamepasses"][tostring(gamepass)] = true
			-- Apply the gamepass' function
			Gamepasses:ApplyGamepass(playerName, gamepass)
		end
	end
end


-- Checks all gamepasses and gives/applies them to the player if they haven't already been; useful if the player purchases on the website, as no events would fire in that case
-- Player: Object
function Gamepasses:CheckGamepasses(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]

	if Data then
		local PlayerPasses = Data["Gamepasses"]
		local AppliedPasses = Data["Applied Gamepasses"]

		for i, Gamepass in pairs(AllGamepasses) do
			if Gamepasses:PlayerOwnsPass(Player, Gamepass)  then
				Gamepasses:AwardGamepass(Player.Name, Gamepass)
				if Gamepass == 49090546 then
					Player:SetAttribute("ThreeFish",true)
				elseif GamepassButtons[Gamepass] and not Data["Tycoon"][GamepassButtons[tonumber(Gamepass)]] then
						local ButtonName = GamepassButtons[Gamepass]
						Modules.Purchasing:ItemPurchased(Player, ButtonName, true)
					end
			elseif Gamepasses:PlayerOwnsPass(Player, Gamepass) and GamepassButtons[tonumber(Gamepass)] and not Data["Tycoon"][GamepassButtons[tonumber(Gamepass)]] then
				Data["Tycoon"][GamepassButtons[tonumber(Gamepass)]] = true

				local Tycoon = Modules.Ownership:GetPlayerTycoon(Player)
				if Tycoon.Buttons:FindFirstChild(GamepassButtons[tonumber(Gamepass)]) then
					Modules.Placement:AnimateOut(Tycoon.Buttons[GamepassButtons[tonumber(Gamepass)]])
				end
			end
		end
	end
end


-- Checks and returns whether the player: Object owns the gamepass of passId: Integer
function Gamepasses:PlayerOwnsPass(player, passId)
	local Data = Modules.PlayerData.sessionData[player.Name]

	if Data then
		if Data["Gamepasses"][tostring(passId)] == true then
			return true
		end

		local Success, IsOwned = pcall(function()
			return Services.MPService:UserOwnsGamePassAsync(player.UserId, passId)
		end)

		if Success and IsOwned then return true end

		return false
	end
end

Remotes.PopupPrompt.OnServerEvent:Connect(function(Player,PassId)
	PopupPurchase[Player.Name] = true
	Services.MPService:PromptGamePassPurchase(Player,PassId)
end)

Services.MPService.PromptGamePassPurchaseFinished:Connect(function(player, gamepass, purchased)
	if purchased then
		Gamepasses:AwardGamepass(player.Name, gamepass)
		local productData = game:GetService("MarketplaceService"):GetProductInfo(gamepass, Enum.InfoType.GamePass)
		--[[
			Fires a bindable event to notify server that this event has occured with given data
			Used normally to integrate with Game Analytics / Dive / Playfab
		]]--
		local success, msg = pcall(function()
			if PopupPurchase[player.Name] then
				PopupPurchase[player.Name] = nil
				EventHandler:Fire("PopupPurchase", player, {
					productId = gamepass,
					price = productData.PriceInRobux
				})
			end
		end)
		local success, msg = pcall(function()

			EventHandler:Fire("transactionCompleted", player, {
				productId = gamepass,
				productDetails = productData,
				price = productData.PriceInRobux
			})
		end)
	end

	if PopupPurchase[player.Name] then
		PopupPurchase[player.Name] = nil
	end
end)


return Gamepasses
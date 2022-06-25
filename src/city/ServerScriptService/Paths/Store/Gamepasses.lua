local Gamepasses = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


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
	55102286, -- pets +100
	55102169, -- pets +300
}



--- Functions ---
function Gamepasses:ApplyGamepass(playerName, gamepass)
	local Data = Modules.PlayerData.sessionData[playerName]
	local Player = game.Players:FindFirstChild(playerName)

	if Data and Player then
		local AppliedPasses = Data["Applied Gamepasses"]
		if gamepass == 49090546 then
			Player:SetAttribute("ThreeFish",true)
		end
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
			elseif gamepass == 28927736 then
				Data["Tycoon"]["Gold Fishing Rod#1"] = true
				Data["Tools"]["Gold Fishing Rod"] = true
				if Player:GetAttribute("Tool") ~= "None" then
					Modules.Tools.EquipTool(Player,"Gold Fishing Rod")
				end
			elseif gamepass == 47438416 then
				Data["Tycoon"]["Rainbow Fishing Rod#1"] = true
				Data["Tools"]["Rainbow Fishing Rod"] = true
				if Player:GetAttribute("Tool") ~= "None" then
					Modules.Tools.EquipTool(Player,"Gold Fishing Rod")
				end
			-- Pet storage gamepasses
			elseif gamepass == 55102286 then
				Data["Pets_Data"].MaxOwned += 300
				Player:SetAttribute("MaxPetsOwned",Data["Pets_Data"].MaxOwned)
			elseif gamepass == 55102169 then
				Data["Pets_Data"].MaxOwned += 100
				Player:SetAttribute("MaxPetsOwned",Data["Pets_Data"].MaxOwned)
			end
		end
	end
end


function Gamepasses:AwardGamepass(playerName, gamepass)
	if game.Players:FindFirstChild(playerName) then
		local Player = game.Players:FindFirstChild(playerName)
		local Data = Modules.PlayerData.sessionData[playerName]

		if Data and Player then
			-- Give Gamepass to player's inventory
			Data["Gamepasses"][tostring(gamepass)] = true

			-- Apply the gamepass' function
			Gamepasses:ApplyGamepass(playerName, gamepass)
		end
	end
end


function Gamepasses:CheckGamepasses(Player)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	
	if Data then
		local PlayerPasses = Data["Gamepasses"]
		local AppliedPasses = Data["Applied Gamepasses"]

		for i, Gamepass in pairs(AllGamepasses) do
			if Gamepasses:PlayerOwnsPass(Player, Gamepass) then
				Gamepasses:AwardGamepass(Player.Name, Gamepass)
			end
		end
	end
end


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

Services.MPService.PromptGamePassPurchaseFinished:Connect(function(player, gamepass, purchased)
	if purchased then
		Gamepasses:AwardGamepass(player.Name, gamepass)
	end
end)


return Gamepasses
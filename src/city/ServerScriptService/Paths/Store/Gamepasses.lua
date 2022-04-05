local Gamepasses = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Gamepass Variables ---
local AllGamepasses = {
	25313170,	 -- x2 Income
	26268187, -- Faster Speed
	26268229, -- Double Jump
	26269102, -- VIP
}



--- Functions ---
function Gamepasses:ApplyGamepass(playerName, gamepass)
	local Data = Modules.PlayerData.sessionData[playerName]
	local Player = game.Players:FindFirstChild(playerName)
	
	if Data and Player then
		local AppliedPasses = Data["Applied Gamepasses"]
		
		-- If the Gamepass isn't already applied then apply it
		if not AppliedPasses[tostring(gamepass)] then
			Data["Applied Gamepasses"][tostring(gamepass)] = true
			Remotes.Store:FireClient(Player, "Gamepass", gamepass, true)
			
			-- x2 Income
			if gamepass == 25313170 then
				Data["Income Multiplier"] *= 2
				
			-- Faster Speed
			elseif gamepass == 26268187 then
				Data["Walkspeed Multiplier"] *= 1.6
				
				local Char = Player.Character
				
				if Char and Char:FindFirstChild("Humanoid") then
					Char.Humanoid.WalkSpeed *= 1.6
				end
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
			if Gamepasses:PlayerOwnsPass(Player, Gamepass) and not AppliedPasses[tostring(Gamepass)] then
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
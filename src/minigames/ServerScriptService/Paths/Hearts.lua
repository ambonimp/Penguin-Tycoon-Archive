local Hearts = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Hearts Variables ---
local GivingDBs = {}
local HeartAmounts = {["Regular"] = 1, ["VIP"] = 3}



--- Functions ---
function Hearts:GiveHeart(PlayerGiving, PlayerReceiving, Type)
	local GivingData = Modules.PlayerData.sessionData[PlayerGiving.Name]
	local ReceivingData = Modules.PlayerData.sessionData[PlayerReceiving.Name]

	if GivingData and ReceivingData and PlayerReceiving:IsDescendantOf(game.Players) then
		if not GivingData[Type.." Hearts Given"][tostring(PlayerReceiving.UserId)] then -- If the player hasn't already been given a hear
			-- Set player as given
			GivingData[Type.." Hearts Given"][tostring(PlayerReceiving.UserId)] = true
			
			-- Give the heart(s)
			ReceivingData["Hearts"] += HeartAmounts[Type]
			PlayerReceiving:SetAttribute("Hearts", ReceivingData["Hearts"])
			
			Remotes.Hearts:InvokeClient(PlayerReceiving, "Heart Received", PlayerGiving.DisplayName, Type)
			
			return true, ReceivingData["Hearts"]
		else
			return false, ReceivingData["Hearts"]
		end
	else
		warn("Hearts 38: Data False or Player Descendency")
		return false
	end
end


Remotes.Hearts.OnServerInvoke = function(PlayerGiving, PlayerReceiving, Type)
	if GivingDBs[PlayerGiving.Name] then return false end
	GivingDBs[PlayerGiving.Name] = true
	
	local a, b = Hearts:GiveHeart(PlayerGiving, PlayerReceiving, Type)
	
	wait()
	GivingDBs[PlayerGiving.Name] = nil
	return a, b
end



return Hearts
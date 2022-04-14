local Codes = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local ServerStorage = game:GetService("ServerStorage")
local EventHandler = ServerStorage:FindFirstChild("EventHandler")

--- Functions ---
function Codes.CodeIsRedeemed(Player, NewCode)
	local RedeemedCodes = Modules.PlayerData.sessionData[Player.Name]["Redeemed Codes"]
	
	for i, RedeemedCode in pairs(RedeemedCodes) do
		if RedeemedCode == NewCode then
			return true
		end
	end
	
	return false
end


--- Rewards ---
Codes.GiveReward = {}

Codes.GiveReward["Money"] = function(Player, CodeData)
	Modules.Income:AddMoney(Player, CodeData.Amount)
end

Codes.GiveReward["Gems"] = function(Player, CodeData)
	Modules.Income:AddGems(Player, CodeData.Amount, "Code")
end

Codes.GiveReward["Accessory"] = function (Player, CodeData)
	Modules.Accessories:ItemAcquired(Player, CodeData.AccessoryName, CodeData.AccessoryType)
end

function Codes.RedeemCode(Player, Code)
	table.insert(Modules.PlayerData.sessionData[Player.Name]["Redeemed Codes"], Code)
	
	local CodeData = Modules.ActiveCodes[Code]
	Codes.GiveReward[CodeData.RewardType](Player, CodeData)
	
		-- Fires a bindable event to notify server that this event has occured with given data
	-- Used normally to integrate with Game Analytics / Dive / Playfab
	local success, msg = pcall(function()
		EventHandler:Fire("codeRedeem", Player, {
			code = Code,
			data = CodeData,
		})
	end)

	return CodeData.ReturnText or "Success!"
end


--- Main Function ---
Remotes.RedeemCode.OnServerInvoke = function(Player, Code)
	Code = string.upper(Code)
	
	if Modules.ActiveCodes[Code] and not Codes.CodeIsRedeemed(Player, Code) then -- Code Exists & Is not redeemed
		return Codes.RedeemCode(Player, Code)
	elseif Codes.CodeIsRedeemed(Player, Code) then
		return "Already Claimed!"
	end

	return "Invalid Or Expired Code!"
end

return Codes
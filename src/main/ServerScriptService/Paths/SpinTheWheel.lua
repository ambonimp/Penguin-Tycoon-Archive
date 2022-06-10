local Spin = {}

local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Rand = Random.new()
local PlayerRewards = {}
local Results = {
	["8"] = 1,
	["5"] = 2.7,
	["2"] = 3.3,
	["6"] = 13,
	["4"] = 14,
	["1"] = 15,
	["3"] = 25,
	["7"] = 26,
}

local Rewards = {
	[1] = {"Boost","Super Fishing Luck"},
	[2] = {"Boost","x3 Money"},
	[3] = {"Gems",10},
	[4] = {"Gems",30},
	[5] = {"Accessory","Jellyfish Hat"},
	[6] = {"Boost","Ultra Fishing Luck"},
	[7] = {"Income",20},
	[8] = {"Clothes","Hazmat Suit"},
}

function RollRandomResult()
	local RandomNumber = Rand:NextNumber(0, 1)*100
	local Number = 0
	local Chosen = nil
	for ID, Chance in pairs(Results) do
		Number = Number + Chance
		if RandomNumber <= Number then
			Chosen = ID
			break
		end
	end

	return tonumber(Chosen)
end

function Remotes.SpinTheWheel.OnServerInvoke(Player,Kind)
	if Kind == "GetResult" and (Modules.PlayerData.sessionData[Player.Name]["Spin"][1] or Modules.PlayerData.sessionData[Player.Name]["Spin"][2] > 0) then
		if Modules.PlayerData.sessionData[Player.Name]["Spin"][1] then
			Modules.PlayerData.sessionData[Player.Name]["Spin"][1] = false
		elseif Modules.PlayerData.sessionData[Player.Name]["Spin"][2] > 0 then
			Modules.PlayerData.sessionData[Player.Name]["Spin"][2] = 0
		end
		local Result = RollRandomResult()
		local Reward = Rewards[Result]
		if Reward then
			PlayerRewards[Player.Name] = Reward
		end
		return Result
	elseif Kind == "ClaimReward" and PlayerRewards[Player.Name] then
		local Reward = PlayerRewards[Player.Name]
		if Reward then
			local Kind = Reward[1]
			if Kind == "Gems" then
				Modules.Income:AddGems(Player,Reward[2])
			elseif Kind == "Income" then
				Modules.Income:AddMoney(Player,Player:GetAttribute("Income")*Reward[2])
			elseif Kind == "Boost" then
				Modules.Boosts.givePlayerBoost(Player,Reward[2],1)
			end
			PlayerRewards[Player.Name] = nil
		end
	end
end


return Spin
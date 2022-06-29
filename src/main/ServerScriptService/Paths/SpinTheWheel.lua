local Spin = {}

local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

Spin.SpinTime = (12*60*60)
if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
	Spin.SpinTime = 1*60
end

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
	[1] = {"Gems",7},--15% 
	[2] = {"Boost","Super Fishing Luck",1}, --3.3%
	[3] = {"Gems",5}, --25%
	[4] = {"Gems",10}, --14%
	[5] = {"Accessory","Jellyfish Hat",50}, --2.7%
	[6] = {"Income",100},--{"Boost","Ultra Fishing Luck",1},  13%
	[7] = {"Income",20}, --26%
	[8] = {"Outfit","Hazmat Suit",100}, --1%
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

function Spin.GiveReward(Player,Reward)
	local Kind = Reward[1]
	if Kind == "Gems" then
		Modules.Income:AddGems(Player,Reward[2])
		return "Gems",Reward[2]
	elseif Kind == "Income" then
		Modules.Income:AddMoney(Player,Player:GetAttribute("Income")*Reward[2])
		return "Income",Reward[2]
	elseif Kind == "Boost" then
		local am = Reward[3] or 1
		if Reward[2] == "Fishing Luck Bundle" then
			Modules.Boosts.givePlayerBoost(Player,"Super Fishing Luck",am,"REWARD")
			Modules.Boosts.givePlayerBoost(Player,"Ultra Fishing Luck",am,"REWARD")
			Modules.Boosts.givePlayerBoost(Player,"x3 Money",am,"REWARD")
		else
			Modules.Boosts.givePlayerBoost(Player,Reward[2],am,"REWARD")
		end
		return "Boost",Reward[2],am
	elseif Kind == "Outfit" then
		if Modules.PlayerData.sessionData[Player.Name]["Outfits"][Reward[2]] then
			Modules.Income:AddGems(Player,Reward[3])
			return "Owned",Reward[3]
		else
			Modules.Accessories:ItemAcquired(Player, Reward[2], "Outfits")
		end
	elseif Kind == "Accessory" then
		if Modules.PlayerData.sessionData[Player.Name]["Accessories"][Reward[2]] then
			Modules.Income:AddGems(Player,Reward[3])
			return "Owned",Reward[3]
		else
			Modules.Accessories:ItemAcquired(Player, Reward[2], "Accessory")
		end
	end
	return nil
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
			local spot,am = Spin.GiveReward(Player,Reward)
			PlayerRewards[Player.Name] = nil
			return spot,am
		end
	elseif Kind == "CheckGift" then
		if os.time() > Modules.PlayerData.sessionData[Player.Name]["Spin"][3] then
			Modules.PlayerData.sessionData[Player.Name]["Spin"][3] = os.time()+Spin.SpinTime
			Modules.PlayerData.sessionData[Player.Name]["Spin"][1] = true
		end
		return Modules.PlayerData.sessionData[Player.Name]["Spin"][3] 
	end
	return nil
end


return Spin
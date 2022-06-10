local Playtime = {}

local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Rewards = {
	[1] = {"Gems",5},
	[2] = {"Boost","Super Fishing Luck",1},
	[3] = {"Income",10},
	[4] = {"Gems",15},
	[5] = {"Boost","Super Fishing Luck",2},
	[6] = {"Gems",20},
	[7] = {"Boost","Ultra Fishing Luck",1},
	[8] = {"Income",100},
	[9] = {"Boost","x3 Money",1},
	[10] = {"Accessory","Traffic Cone",50},
	[11] = {"Boost","Fishing Luck Bundle",1},
	[12] = {"Outfit","Lobster",100},
}

local RewardTimes = {
    [1] = 5*60,
    [2] = 10*60,
    [3] = 15*60,
    [4] = 20*60,
    [5] = 30*60,
    [6] = 40*60,
    [7] = 50*60,
    [8] = 60*60,
    [9] = 75*60,
    [10] = 90*60,
    [11] = 120*60,
    [12] = 180*60,
}

if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
	RewardTimes = {
        [1] = 5*6,
        [2] = 10*6,
        [3] = 15*6,
        [4] = 20*6,
        [5] = 30*6,
        [6] = 40*6,
        [7] = 50*6,
        [8] = 60*6,
        [9] = 75*6,
        [10] = 90*6,
        [11] = 120*6,
        [12] = 180*6,
    }
end

function Remotes.PlaytimeRedeem.OnServerInvoke(Player,Award)
	local JoinTime = Player:GetAttribute("JoinTime")
	if RewardTimes[Award] and os.time() >= JoinTime+(RewardTimes[Award]) and not Modules.PlayerData.sessionData[Player.Name]["Playtime"][3][Award] then
		Modules.PlayerData.sessionData[Player.Name]["Playtime"][3][Award] = true
		local t,am,am2 = Modules.SpinTheWheel.GiveReward(Player,Rewards[Award])

		return true,t,am,am2
	end
	return false
end

return Playtime
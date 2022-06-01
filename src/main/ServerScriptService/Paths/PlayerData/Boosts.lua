local Boosts = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local BoostTimes = {
	["Fishing Super Luck"] = 60*20,
	["Fishing Ultra Luck"] = 60*15,
	["x3 Money"] = 60*20
}
local attName = {
	["Fishing Super Luck"] = "FishingSuperLuckBoost",
	["Fishing Ultra Luck"] = "FishingUltraLuckBoost",
	["x3 Money"] = "x3MoneyBoost"
}
--[[
Data["Boosts"] = { --[1]owned, [2]time left in current boost
	["Fishing Super Luck"] = {0,0},  --10% fish rarity
	["Fishing Ultra Luck"] = {0,0}, --15% fish rarity
	["x3 Money"] = {0,0}, --x3 Money
}
]]
function Boosts:givePlayerBoost(Player,Boost,Amount)
	local data = Modules.PlayerData.sessionData[Player.Name]
	if data then
		local boosts = data["Boosts"]
		boosts[Boost][1] += Amount
		Remotes.BoostHandler:FireClient(Player,Boost,"Add",data)
	end
end

function Boosts.startPlayerBoost(Player,Boost)
	local data = Modules.PlayerData.sessionData[Player.Name]
	if data then
		local boosts = data["Boosts"]
		if boosts[Boost][1] > 0 then
			boosts[Boost][1] -= 1
			Player:SetAttribute(attName[Boost],true)
			boosts[Boost][2] = BoostTimes[Boost]
			Remotes.BoostHandler:FireClient(Player,Boost,"Start",data)
			while Player and Player.Parent do
				task.wait(10)
				boosts[Boost][2] -= 10
				if boosts[Boost][2] <= 0 then
					break
				end
			end
			if Player and Player.Parent then
				Player:SetAttribute(Boost.." Boost",false)
				Remotes.BoostHandler:FireClient(Player,Boost,"End",data)
				boosts[Boost][2] = 0
			end
		end
	end
end

Remotes.BoostHandler.OnServerEvent:Connect(function(Player,Action,Boost)
	print(Player,Action,Boost)
	if Action == "Start" then
		Boosts.startPlayerBoost(Player,Boost)
	end
end)

return Boosts
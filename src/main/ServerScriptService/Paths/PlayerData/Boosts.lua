local Boosts = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local BoostTimes = {
	["Super Fishing Luck"] = 60*15,
	["Ultra Fishing Luck"] = 60*15,
	["x3 Money"] = 60*15
}
local attName = {
	["Super Fishing Luck"] = "FishingSuperLuckBoost",
	["Ultra Fishing Luck"] = "FishingUltraLuckBoost",
	["x3 Money"] = "x3MoneyBoost"
}
--[[
Data["Boosts"] = { --[1]owned, [2]time left in current boost
	["Fishing Super Luck"] = {0,0},  --10% fish rarity
	["Fishing Ultra Luck"] = {0,0}, --15% fish rarity
	["x3 Money"] = {0,0}, --x3 Money
}
]]
function Boosts.givePlayerBoost(Player,Boost,Amount,from)
	local data = Modules.PlayerData.sessionData[Player.Name]
	if data then
		local boosts = data["Boosts"]
		boosts[Boost][1] += Amount
		Remotes.BoostHandler:FireClient(Player,Boost,"Add",data)
		if from == "REWARD" then
			task.spawn(function()
				Boosts.startPlayerBoost(Player,Boost,false)
			end)
		end
	end
end

function Boosts.startPlayerBoost(Player,Boost,isJoin)
	local data = Modules.PlayerData.sessionData[Player.Name]
	if data then
		local boosts = data["Boosts"]
		if boosts[Boost][1] > 0 and (boosts[Boost][2] == 0 or isJoin) and not Player:GetAttribute(attName[Boost]) then
			Player:SetAttribute(attName[Boost],true)
			if isJoin then
				boosts[Boost][2] = boosts[Boost][2] - 5
			else
				boosts[Boost][1] -= 1
				boosts[Boost][2] = BoostTimes[Boost]
			end
			Remotes.BoostHandler:FireClient(Player,Boost,"Start",data)
			while Player and Player.Parent do
				task.wait(5)
				boosts[Boost][2] -= 5
				if boosts[Boost][2] <= 0 then
					break
				end
			end
			if Player and Player.Parent then
				Player:SetAttribute(attName[Boost],false)
				boosts[Boost][2] = 0
				Remotes.BoostHandler:FireClient(Player,Boost,"End",data)
			end
		elseif not isJoin then
			if boosts[Boost][1] <= 0 then
				boosts[Boost][1] = 0
				Paths.Remotes.ClientNotif:FireClient(Player,"You got no "..Boost.." left!",Color3.new(0.792156, 0.509803, 0.184313),3.5)
			elseif boosts[Boost][2] > 0 or Player:GetAttribute(attName[Boost]) then
				Paths.Remotes.ClientNotif:FireClient(Player,Boost.." is already running!",Color3.new(0.792156, 0.509803, 0.184313),3.5)
			end
		end
	end
end

Remotes.BoostHandler.OnServerEvent:Connect(function(Player,Action,Boost)
	if Action == "Start" then
		Boosts.startPlayerBoost(Player,Boost,nil)
	end
end)

return Boosts
local Chat = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Initializing ---
function Chat:ApplyChatTag(player)
	coroutine.wrap(function()
		local Data = Modules.PlayerData.sessionData[player.Name]
		if not Data then return end

		local GroupRank = 0
		pcall(function()
			GroupRank = player:GetRankInGroup(12843903)
		end)

		local VIP = Modules.PlayerData.sessionData[player.Name]["Gamepasses"]["26269102"]

		local Tags = {
			[1] = {{TagText = "Member", TagColor = Color3.new(246/255, 196/255, 255/255)}}, -- Member
			[90] = {{TagText = "⭐ Youtuber", TagColor = Color3.new(255/255, 113/255, 47/255)}}, -- Youtuber
			[100] = {{TagText = "Tester", TagColor = Color3.new(93/255, 93/255, 255/255)}}, -- Tester
			[110] = {{TagText = "🕵️ Staff", TagColor = Color3.new(61/255, 155/255, 255/255)}}, -- Staff
			[120] = {{TagText = "⛏️ Contributor", TagColor = Color3.new(138/255, 255/255, 105/255)}}, -- Contributor

			["VIP"] = {{TagText = "⭐ VIP", TagColor = Color3.new(255/255, 234/255, 0/255)}}, -- VIP

			["Verified"] = {{TagText = "☑️ Verified", TagColor = Color3.fromRGB(48, 176, 255)}}, -- Verified

			[1503429436] = {{TagText = "⚒️ Dev", TagColor = Color3.fromRGB(107, 142, 255)}}, -- Dz3rro
			[1299100232] = {{TagText = "⚒️ Dev", TagColor = Color3.fromRGB(255, 237, 34)}}, -- D3Sinon
			[75787254] = {{TagText = "⚒ Dev", TagColor = Color3.fromRGB(255, 135, 135)}}, -- Kippiiq
			[2215273802] = {{TagText = "⚒ Dev", TagColor = Color3.fromRGB(144, 238, 144)}} -- unsigned_var
		}

		local speaker = Services.ChatService:GetSpeaker(player.Name)

		if not speaker then
			for i = 1, 10 do -- 10 retries to get speaker
				speaker = Services.ChatService:GetSpeaker(player.Name)
				if speaker then break end
				wait(0.2)
			end
		end

		if Data["Settings"]["Chat Tag"] then
			if GroupRank <= 1 and Data["Twitter Verification"] then
				speaker:SetExtraData("Tags", Tags["Verified"])
			elseif Tags[GroupRank] then
				speaker:SetExtraData("Tags", Tags[GroupRank])
			elseif Tags[player.UserId] then
				speaker:SetExtraData("Tags", Tags[player.UserId])
			elseif VIP then
				speaker:SetExtraData("Tags", Tags["VIP"])
			end

			if GroupRank <= 1 and VIP then
				speaker:SetExtraData("Tags", Tags["VIP"])
			end
		else
			speaker:SetExtraData("Tags", nil)
		end
	end)()
end


return Chat
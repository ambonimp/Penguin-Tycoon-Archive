local Badges = {}

local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

function Badges:AwardBadge(UserID, BadgeID)
	local Succ, Succ2 = pcall(function()
		if not BadgeService:UserHasBadgeAsync(UserID, BadgeID) then
			BadgeService:AwardBadge(UserID, BadgeID)

		end

	end)

	if Succ and Succ2 then
		local BadgeInfo = BadgeService:GetBadgeInfoAsync(BadgeID)
		local Player = Players:GetPlayerByUserId(UserID)
		if BadgeInfo and Player then
			Remotes.Announcement:FireAllClients(Player, {
				Type = "Badge",
				Name = BadgeInfo.Name
			})
		end

	end

end

Badges.Purchases = {
	["Sailboat#1"] = 2126143691;
	["Plane#1"] = 2126439191;

	["New Island!#0"] = 2124907090; -- Starter Island (Given immediately, since its not purchased)
	["New Island!#1"] = 2124907091; -- Lumberjack
	["Youtube Island!#1"] = 2126696346; -- YouTube
	["New Island!#2"] = 2124907092; -- Ice skate
	["New Island!#3"] = 2124907093; -- Filler
	["New Island!#4"] = 2124907094; -- King penguin
	["New Island!#5"] = 2124907095; -- Japanese
	["New Island!#6"] = 2124907096; -- Filler
	["New Island!#7"] = 2124907097; -- Hot Springs
	["New Island!#8"] = 2124907098; -- Blossom Tree
	["New Island!#9"] = 2124907099;-- Filler
	["New Island!#31"] = 2127993948;-- Mansion
	["New Island!#10"] = 2124907100; -- Theme Park
	["New Island!#11"] = 2124907101; -- Desert Island
	["New Island!#12"] = 2124907102; -- Observatory
	["New Island!#13"] = 2124907103; -- Filler
	["New Island!#14"] = 2124907104; -- Filler
	["New Island!#15"] = 2124907105; -- Meteor
	["New Island!#16"] = 2124907106; -- Space Station
	["New Island!#17"] = 2124907107; -- Rovers
	["New Island!#18"] = 2124907108; -- Satellite
	["New Island!#19"] = 2124907109; -- Spaceship
	["New Island!#20"] = 2124929781; -- Film set
	["New Island!#21"] = 2124929782; -- Cinema
	["New Island!#22"] = 2124929783; -- Green tree
	["New Island!#23"] = 2124929784;-- Greenhouse
	["New Island!#25"] = 2124929785;-- Caveman
	["New Island!#26"] = 2124929786;-- Enchanted Mushrooms
	["New Island!#29"] = 2124929788;-- Hospital
	["New Island!#30"] = 2124929789;-- Military
	["Mining Island!#1"] = 2126876430;-- Mining

	["New Island!#32"] = 2127256368; -- Woodcutting world
	["New Island!#33"] = 2127256371; -- Sports
	["New Island!#34"] = 2127256374; -- Bee
	["New Island!#35"] = 2127256375; -- Castle
	["New Island!#36"] = 2127394463; -- School
	["New Island!#37"] = 2127704120; -- Factory
	["New Island!#38"] = 2127704122; -- Zoo
	["New Island!#39"] = 2127799195; -- Arcade
	["New Island!#40"] = 2127993820; -- Circus

}

return Badges
local Badges = {}

local BadgeService = game:GetService("BadgeService")

function Badges:AwardBadge(UserID, BadgeID)
	pcall(function()
		if not BadgeService:UserHasBadgeAsync(UserID, BadgeID) then
			BadgeService:AwardBadge(UserID, BadgeID)
		end
	end)
end

Badges.Purchases = {
	["Sailboat#1"] = 2126143691;
	["Plane#1"] = 2126439191;

	["Path#26"] = 2126696346;
	["Mining Island!#1"] = 2126876430;

	["New Island!#0"] = 2124907090; -- Starter Island (Given immediately, since its not purchased)
	["Snow#3"] = 2124907091;
	["Barrels#1"] = 2124907092;
	["Path#1"] = 2124907093;
	["Path#2"] = 2124907094;

	["Path#3"] = 2124907095;
	["Stairs#1"] = 2124907096;
	["Stairs#2"] = 2124907097;
	["Pillars#1"] = 2124907098;
	["Logs#2"] = 2124907099;

	["Broken Ice#6"] = 2124907100;
	["Path#6"] = 2124907101;
	["Planks#1"] = 2124907102;
	["Icy Access#1"] = 2124907103;
	["Broken Ice#1"] = 2124907104;

	["Snow#8"] = 2124907105; -- v1.30
	["Stairs#3"] = 2124907106;
	["Teleport Device#1"] = 2124907107;
	["Stairs#4"] = 2124907108;
	["Stairs#5"] = 2124907109; -- v1.40

	["Space Bridge#1"] = 2124929781; -- v1.70 (Movie Making Island)
	["Broken Ice#2"] = 2124929782;
	["Broken Ice#3"] = 2124929783;
	["Stairs#7"] = 2124929784;
	["Stairs#8"] = 2124929785;
	["Pillars#2"] = 2124929786;
	["Broken Ice#4"] = 2124929787;
	["Pillars#3"] = 2124929788; --Hospital
	["New Island!#30"] = 2124929789; -- Military

	["New Island!#32"] = 2127256368; -- woodcutting trees
	["New Island!#33"] = 2127256371; -- sports
	["New Island!#34"] = 2127256374; -- bee
	["New Island!#35"] = 2127256375; -- castle
	["New Island!#37"] = 2127704120; -- factory
	["New Island!#38"] = 2127704122; -- school
	["New Island!#39"] = 2127799195; -- arcade

}

return Badges
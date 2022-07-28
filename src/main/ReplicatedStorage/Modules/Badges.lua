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
	["New Island!#1"] = 2124907091;
	["New Island!#2"] = 2124907092;
	["New Island!#3"] = 2124907093;
	["New Island!#4"] = 2124907094;

	["New Island!#5"] = 2124907095;
	["New Island!#6"] = 2124907096;
	["New Island!#7"] = 2124907097;
	["New Island!#8"] = 2124907098;
	["New Island!#9"] = 2124907099;

	["New Island!#10"] = 2124907100;
	["New Island!#11"] = 2124907101;
	["New Island!#12"] = 2124907102;
	["New Island!#13"] = 2124907103;
	["New Island!#14"] = 2124907104;

	["New Island!#15"] = 2124907105; -- v1.30
	["New Island!#16"] = 2124907106;
	["New Island!#17"] = 2124907107;
	["New Island!#18"] = 2124907108;
	["New Island!#19"] = 2124907109; -- v1.40

	["New Island!#20"] = 2124929781; -- v1.70 (Movie Making Island)
	["New Island!#21"] = 2124929782;
	["New Island!#22"] = 2124929783;
	["New Island!#23"] = 2124929784;
	["New Island!#24"] = 2124929785;
	["New Island!#25"] = 2124929786; 
	["New Island!#26"] = 2124929787;
	["New Island!#29"] = 2124929788; --Hospital
	["New Island!#30"] = 2124929789; -- Military

	["New Island!#32"] = 2127256368; --woodcutting trees
	["New Island!#33"] = 2127256371; --sports
	["New Island!#34"] = 2127256374; --bee
	["New Island!#35"] = 2127256375; --castle
	["New Island!#37"] = 2127704120; -- factory
	["New Island!#38"] = 2127704122; --school

}

return Badges
local Tycoon = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Initializing ---
function Tycoon:InitializePlayer(Player)
	local ChosenTycoon = Modules.Ownership:GetAvailableTycoon()
	
	if not ChosenTycoon then
		warn(Player, "was kicked due to Choosing Tycoon error")
		Player:Kick("Tycoon Initiliazing Error: Please try rejoining!")
	end

	Modules.Ownership:ClaimTycoon(ChosenTycoon, Player)
	Modules.Loading:LoadTycoon(Player)
	
	Modules.Character:Spawn(Player, "Penguin")
end

for _, MinigameHandler in ipairs(script.Minigames:GetChildren()) do
	require(MinigameHandler)
end


return Tycoon
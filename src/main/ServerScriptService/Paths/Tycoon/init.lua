local Tycoon = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Initializing ---
function Tycoon:InitializePlayer(Player, ChosenTycoon)
	ChosenTycoon = ChosenTycoon or Modules.Ownership:GetAvailableTycoon()
	
	if not ChosenTycoon then
		warn(Player, "was kicked due to Choosing Tycoon error")
		Player:Kick("Tycoon Initiliazing Error: Please try rejoining!")
	end

	Modules.Ownership:ClaimTycoon(ChosenTycoon, Player)
	Modules.Loading:LoadTycoon(Player)

	task.spawn(function()
		local ChosenTycoonModel = workspace:WaitForChild("Tycoons"):WaitForChild(ChosenTycoon)
		Player:RequestStreamAroundAsync(ChosenTycoonModel:WaitForChild("Spawn").Position)
		Modules.Character:Spawn(Player, "Penguin", true)
	end)
  
end

for _, MinigameHandler in ipairs(script.Minigames:GetChildren()) do
	require(MinigameHandler)
end


return Tycoon
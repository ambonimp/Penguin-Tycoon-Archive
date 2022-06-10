local RStorage = game:GetService("ReplicatedStorage")
local PlaceIds =  require(RStorage.Modules.PlaceIds)

local EventsConfig = {}

EventsConfig.Names = {
	[PlaceIds["Falling Tiles"]] = "Falling Tiles",
	[PlaceIds["Skate Race"]] = "Skate Race",
	[PlaceIds["Soccer"]] = "Soccer",
	[PlaceIds["Candy Rush"]] = "Candy Rush",
	[PlaceIds["Ice Cream Extravaganza"]] = "Ice Cream Extravaganza",
	[PlaceIds["Sled Race"]] = "Sled Race"
}


EventsConfig.INTERMISSION_INTERVAL = 10

EventsConfig["Skate Race"] = {
	MinPlayers = 2,
	MaxPlayers = 20,
	Duration = 140,
	Laps = 2,
	FastestPossible = 100,
	ImageID = 9283419629,
	["Display Name"] = "Skate Race" ,
	--["Tutorial"] = "Reach the end to win!",
}


EventsConfig["Falling Tiles"] = {
	MinPlayers = 2,
	MaxPlayers = 15,
	Duration = 180,
	ImageID = 9283419766,
	["Display Name"] = "Falling Tiles",
	--["Tutorial"] = "Reach the end to win!",
}

EventsConfig["Soccer"] = {
	MinPlayers = 2,
	MaxPlayers = 12,
	Duration = 180,
	MaxGoals = 10,
	ImageID = 9287829535,
	["Display Name"] = "Soccer",
	--["Tutorial"] = "Reach the end to win!",
}

EventsConfig["Candy Rush"] = {
	MinPlayers = 2,
	MaxPlayers = 20,
	Duration = 120,
	ImageID = 9617829253,
	["Display Name"] = "Candy Rush",
	--["Tutorial"] = "Reach the end to win!",
}

EventsConfig["Ice Cream Extravaganza"] = {
	MinPlayers = 2,
	MaxPlayers = 12,
	Duration = 45,
	DropVelocity = 12,
	DropRate = 0.4,
	InvicibilityLength = 5,
	ImageID = 9727903441,
	["Display Name"] = "Ice Cream Extravaganza",
	--["Tutorial"] = "Reach the end to win!",
}

EventsConfig["Sled Race"] = {
	MinPlayers = 2,
	MaxPlayers = 15,
	Duration = 100,
	TurnVelocity = math.rad(25),
	MaxSteerAngle = math.rad(45),
	DefaultVelocity = 75,
	MinVelocity = 30,
	MaxVelocity = 280,
	CollectableEffectDuration = 3,
	ObstacleVelocityMinuend = 25,
	BoostVelocityAddend = 30,
	ImageID = 9868349733,
	["Display Name"] = "Sled Race",
	--["Tutorial"] = "Reach the end to win!",
}

EventsConfig["Egg Hunt"] = {
	MinPlayers = 2,
	MaxPlayers = 20,
	Duration = 120,
	ImageID = 9348758097,
	["Display Name"] = "Egg Hunt",
	--["Tutorial"] = "Reach the end to win!",
}

if game.PlaceId == 9647797909 then -- Testing
	EventsConfig.INTERMISSION_INTERVAL = 10
	EventsConfig.Names[9647797909] = "Skate Race"
	EventsConfig[EventsConfig.Names[9647797909]].Duration = 120
	EventsConfig[EventsConfig.Names[9647797909]].FastestPossible = 1
	EventsConfig[EventsConfig.Names[9647797909]].Laps = 1
	EventsConfig[EventsConfig.Names[9647797909]].MinPlayers = 1
end

return EventsConfig
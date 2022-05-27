local RStorage = game:GetService("ReplicatedStorage")
local PlaceIds =  require(RStorage.Modules.PlaceIds)


local EventsConfig = {}

EventsConfig.Names = {
	[PlaceIds["Falling Tiles"]] = "Falling Tiles",
	[PlaceIds["Skate Race"]] = "Skate Race",
	[PlaceIds["Soccer"]] = "Soccer",
	[PlaceIds["Candy Rush"]] = "Candy Rush",
	[PlaceIds["Ice Cream Extravaganza"]] = "Ice Cream Extravaganza"
} --,"Egg Hunt"}


EventsConfig.INTERMISSION_INTERVAL = 10
EventsConfig.VOTE_TIMER = 10
EventsConfig.ACCEPT_TIMER = 10


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
	Duration = 30,
	DropVelocity = 12,
	DropRate = 0.4,
	InvicibilityLength = 5,
	ImageID = 9727903441,
	["Display Name"] = "Ice Cream Extravaganza",
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
	EventsConfig.Names[9647797909] = "Ice Cream Extravaganza"
	-- EventsConfig[EventsConfig.Names[9647797909]].Duration = 10
	EventsConfig[EventsConfig.Names[9647797909]].MinPlayers = 1
end

return EventsConfig
local RStorage = game:GetService("ReplicatedStorage")
local PlaceIds =  require(RStorage.Modules.PlaceIds)


local EventsConfig = {}

EventsConfig.Events = {
	[PlaceIds["Falling Tiles"]] = "Falling Tiles",
	[PlaceIds["Skate Race"]] = "Skate Race",
	[PlaceIds["Soccer"]] = "Soccer",
	[PlaceIds["Candy Rush"]] = "Candy Rush"
} --,"Egg Hunt"}


EventsConfig.INTERMISSION_INTERVAL = 10--30
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
	MinPlayers = 0,
	MaxPlayers = 20,
	Duration = 120,
	ImageID = 9617829253,
	["Display Name"] = "Candy Rush",
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


if game.PlaceId == 9170899192 then -- night skating test
	EventsConfig.INTERMISSION_INTERVAL = 10
	EventsConfig.ACCEPT_TIMER = 10
end


return EventsConfig
local Config = {}

Config.Constants = {
	MAX_THROW_DISTANCE = 100,
	PLAYER_ISLAND_RADIUS = 600,
	FISH_TIME = 3
}

Config.PlayerIslandData = {
	Blue = {
		CenterPosition = Vector3.new(-2146.429, 14, 3158.058)
	},
	Green = {
		CenterPosition = Vector3.new(-2121.977, 14, -5167.128)	
	},
	Orange = {
		CenterPosition = Vector3.new(4294.932, 14, -1256.423)	
	},
	Purple = {
		CenterPosition = Vector3.new(-4121.977, 14, -1167.128)	
	},
	Red = {
		CenterPosition = Vector3.new(2504.539, 14, 3437.893)	
	},
	Yellow = {
		CenterPosition = Vector3.new(2294.932, 14, -5256.423)
	}
}


return Config

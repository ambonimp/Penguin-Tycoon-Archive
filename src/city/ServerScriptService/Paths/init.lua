local Paths = {}

Paths.Services = {}
Paths.Modules = {}
Paths.Vars = {}
Paths.Initialized = false

function Paths.Initiliaze()
--- Initializing Services ---
	Paths.Services.DataStoreService = game:GetService("DataStoreService")
	Paths.Services.RStorage = game:GetService("ReplicatedStorage");
	Paths.Services.SStorage = game:GetService("ServerStorage");
	Paths.Services.ServerScriptService = game:GetService("ServerScriptService")
	Paths.Services.MPService = game:GetService("MarketplaceService");
	Paths.Services.RunService = game:GetService("RunService");
	Paths.Services.Teams = game:GetService("Teams");
	Paths.Services.TweenService = game:GetService("TweenService");
	Paths.Services.TextService = game:GetService("TextService");
	Paths.Services.ContentProvider = game:GetService("ContentProvider");
	Paths.Services.TeleportService = game:GetService("TeleportService");
	Paths.Services.PhysicsService = game:GetService("PhysicsService");
	Paths.Services.HttpService = game:GetService("HttpService")

	coroutine.wrap(function()
		Paths.Services.ChatService = require(script.Parent:WaitForChild("ChatServiceRunner").ChatService)
	end)()
	
	
--- Other Variables ---
	
	
--- Initializing Remotes ---
	Paths.Remotes = Paths.Services.RStorage.Remotes;
	
	Paths.Dependency = Paths.Services.SStorage:WaitForChild("ServerDependency")
	
--- Initializing Modules ---
	-- Other Modules
	Paths.Modules.Format = require(Paths.Services.RStorage.Modules.Format)
	Paths.Modules.GameFunctions = require(Paths.Services.RStorage.Modules.GameFunctions)
	Paths.Modules.GameInfo = require(Paths.Services.RStorage.Modules.GameInfo)
	Paths.Modules.FuncLib = require(Paths.Services.RStorage.Modules.FuncLib)
	Paths.Modules.AllAccessories = require(Paths.Services.RStorage.Modules.AllAccessories)
	Paths.Modules.AllOutfits = require(Paths.Services.RStorage.Modules.AllOutfits)
	Paths.Modules.AllEyes = require(Paths.Services.RStorage.Modules.AllEyes)
	Paths.Modules.FishingConfig = require(Paths.Services.RStorage.Modules.FishingConfig)
	Paths.Modules.AllQuests = require(Paths.Services.RStorage.Modules.AllQuests)
	Paths.Modules.AllAchievements = require(Paths.Services.RStorage.Modules.AllAchievements)
	Paths.Modules.Character = require(script.Character)
	Paths.Modules.Codes = require(script.Codes);
	Paths.Modules.ActiveCodes = require(script.Codes.ActiveCodes)
	Paths.Modules.Verification = require(script.Verification)
	Paths.Modules.Settings = require(script.Settings)
	Paths.Modules.Teleporting = require(script.Teleporting)
	Paths.Modules.EventsConfig = require(Paths.Services.RStorage.Modules.EventsConfig)
	Paths.Modules.FuncLib = require(Paths.Services.RStorage.Modules.FuncLib)
	Paths.Modules.Collisions = require(script.Collisions)
	Paths.Modules.Zones = require(script.Zones)
	Paths.Modules.SettingDetails = require(Paths.Services.RStorage.Modules.SettingDetails)
	Paths.Modules.LeaderboardDetails = require(Paths.Services.RStorage.Modules.LeaderboardDetails)

	-- Chat Modules
	Paths.Modules.Chat = require(script.Chat)

	-- Emote Server Modules
	Paths.Modules.Emotes = require(script.Emotes)

	-- Tool Modules
	Paths.Modules.Tools = require(script.Tools)
	
	Paths.Modules.Achievements = require(script.Achievements)
	Paths.Modules.SpinTheWheel = require(script.SpinTheWheel)
	Paths.Modules.Playtime = require(script.Playtime)
	Paths.Modules.Quests = require(script.Quests)
	-- Data Modules
	Paths.Modules.Save = require(script.PlayerData.Save)
	Paths.Modules.Boosts = require(script.PlayerData.Boosts);
	Paths.Modules.PlayerData = require(script.PlayerData);
	Paths.Modules.Income = require(script.PlayerData.Income)
	Paths.Modules.Leaderboards = require(script.Leaderboards)
	
	-- Store Modules
	Paths.Modules.Store = require(script.Store)
	Paths.Modules.Gamepasses = require(script.Store.Gamepasses)
	Paths.Modules.Products = require(script.Store.Products)
	Paths.Modules.Accessories = require(script.Store.Accessories)
	
	-- Penguins
	Paths.Modules.Penguins = require(script.Penguins)
	
	-- Hearts
	Paths.Modules.Hearts = require(script.Hearts)
	
	-- Pets
	Paths.Modules.PetDetails = require(Paths.Services.RStorage.Modules.PetDetails)
	Paths.Modules.Pets = require(script.Pets)
	
	Paths.Modules.Fishing = require(script.Fishing)
	Paths.Modules.PoolSpawner = require(script.Fishing.PoolSpawner)
--- Other Variables ---
	Paths.Initialized = true
end

return Paths
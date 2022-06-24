local Paths = {}

Paths.Services = {}
Paths.Modules = {}
Paths.Vars = {}
Paths.Initialized = false


-- Initializes all services, modules and other commonly/globally used variables, so they can be accessed from all other server-sided modules.
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
	Paths.Services.HttpService = game:GetService("HttpService")
	
	coroutine.wrap(function()
		Paths.Services.ChatService = require(script.Parent:WaitForChild("ChatServiceRunner").ChatService)
	end)()

	
	Paths.Dependency = Paths.Services.SStorage:WaitForChild("ServerDependency")
--- Other Variables ---
	Paths.Template = workspace.Template;
	Paths.Template.Parent = Paths.Services.RStorage
	
	
--- Initializing Remotes ---
	Paths.Remotes = Paths.Services.RStorage.Remotes;
	
	
--- Initializing Modules ---
	-- Other Modules
	Paths.Modules.Format = require(Paths.Services.RStorage.Modules.Format)
	Paths.Modules.GameFunctions = require(Paths.Services.RStorage.Modules.GameFunctions)
	Paths.Modules.GameInfo = require(Paths.Services.RStorage.Modules.GameInfo)
	Paths.Modules.AllOutfits = require(Paths.Services.RStorage.Modules.AllOutfits)
	Paths.Modules.AllAccessories = require(Paths.Services.RStorage.Modules.AllAccessories)
	Paths.Modules.AllQuests = require(Paths.Services.RStorage.Modules.AllQuests)
	Paths.Modules.MiningDetails = require(Paths.Services.RStorage.Modules.MiningDetails)
	Paths.Modules.AllEyes = require(Paths.Services.RStorage.Modules.AllEyes)
	Paths.Modules.Character = require(script.Character)
	Paths.Modules.Codes = require(script.Codes);
	Paths.Modules.ActiveCodes = require(script.Codes.ActiveCodes)
	Paths.Modules.Verification = require(script.Verification)
	Paths.Modules.Settings = require(script.Settings)
	Paths.Modules.Teleporting = require(script.Teleporting)
	Paths.Modules.Badges = require(Paths.Services.RStorage.Modules.Badges)
	Paths.Modules.FishingConfig = require(Paths.Services.RStorage.Modules.FishingConfig)
	Paths.Modules.ProgressionDetails = require(Paths.Services.RStorage.Modules.ProgressionDetails)
	Paths.Modules.VehicleDetails = require(Paths.Services.RStorage.Modules.VehicleDetails)
	Paths.Modules.FuncLib = require(Paths.Services.RStorage.Modules.FuncLib)
	Paths.Modules.Feedback = require(script.Feedback)
	
	-- Chat Modules
	Paths.Modules.Chat = require(script.Chat)
	
	-- Emote Server Modules
	Paths.Modules.Emotes = require(script.Emotes)

	-- Tool Modules
	Paths.Modules.Tools = require(script.Tools)

	-- Penguins
	Paths.Modules.Penguins = require(script.Penguins)
	
	-- Tycoon Modules
	Paths.Modules.Tycoon = require(script.Tycoon)
	Paths.Modules.Initiate = require(script.Tycoon.Initiate)
	Paths.Modules.Vehicles = require(script.Vehicles)
	Paths.Modules.Ownership = require(script.Tycoon.Ownership)
	Paths.Modules.Purchasing = require(script.Tycoon.Purchasing)
	Paths.Modules.Placement = require(script.Tycoon.Placement)
	Paths.Modules.Buttons = require(script.Tycoon.Buttons)
	Paths.Modules.Loading = require(script.Tycoon.Loading)
	
	-- Data Modules
	Paths.Modules.Save = require(script.PlayerData.Save)
	Paths.Modules.PlayerData = require(script.PlayerData);
	Paths.Modules.Income = require(script.PlayerData.Income)
	Paths.Modules.Leaderboards = require(script.Leaderboards)

	
	-- Store Modules
	Paths.Modules.Store = require(script.Store)
	Paths.Modules.Gamepasses = require(script.Store.Gamepasses)
	Paths.Modules.Products = require(script.Store.Products)
	Paths.Modules.Accessories = require(script.Store.Accessories)
	Paths.Modules.Boosts = require(script.PlayerData.Boosts)
	Paths.Modules.SpinTheWheel = require(script.SpinTheWheel)
	Paths.Modules.Playtime = require(script.Playtime)
	Paths.Modules.Quests = require(script.Quests)
	Paths.Modules.Fishing = require(script.Tycoon.Fishing)
	Paths.Modules.PoolSpawner = require(script.Tycoon.Fishing.PoolSpawner)

	-- Pets
	Paths.Modules.PetDetails = require(Paths.Services.RStorage.Modules.PetDetails)
	Paths.Modules.Pets = require(script.Pets)
	
	--- Other Variables ---
	Paths.Initialized = true
end

return Paths
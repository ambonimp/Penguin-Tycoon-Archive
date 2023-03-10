local Paths = {}

Paths.Services = {}
Paths.Modules = {}
Paths.UI = {}

function Paths.Initiliaze()
--- Initializing Services ---
	Paths.Services.RStorage = game:GetService("ReplicatedStorage");
	Paths.Services.MPService = game:GetService("MarketplaceService");
	Paths.Services.RunService = game:GetService("RunService");
	Paths.Services.TweenService = game:GetService("TweenService");
	Paths.Services.InputService = game:GetService("UserInputService");
	Paths.Services.TextService = game:GetService("TextService");
	Paths.Services.TeleportService = game:GetService("TeleportService");
	Paths.Services.ContentProvider = game:GetService("ContentProvider");
	Paths.Services.GuiService = game:GetService("GuiService")
	Paths.Services.Lighting = game:GetService("Lighting")
	Paths.Services.ProximityPrompt = game:GetService("ProximityPromptService")
	
	
	Paths.Dependency = Paths.Services.RStorage:WaitForChild("ClientDependency")
	
--- Initializing UI ---
	local PlayerGui = game.Players.LocalPlayer.PlayerGui
	Paths.UI.Main = PlayerGui:WaitForChild("Main")
	Paths.UI.SpecialEffects = PlayerGui:WaitForChild("SpecialEffects")

	Paths.UI.Left = Paths.UI.Main:WaitForChild("Left")
	Paths.UI.Center = Paths.UI.Main:WaitForChild("Center")
	Paths.UI.Bottom = Paths.UI.Main:WaitForChild("Bottom")
	Paths.UI.Top = Paths.UI.Main:WaitForChild("Top")
	Paths.UI.Full = Paths.UI.Main:WaitForChild("Full")
	Paths.UI.Right = Paths.UI.Main:WaitForChild("Right")
	Paths.UI.BLCorner = Paths.UI.Main:WaitForChild("BLCorner")
	Paths.UI.Tools = Paths.UI.Bottom.Tools
	
--- Initializing Remotes ---
	Paths.Remotes = Paths.Services.RStorage.Remotes;
	
	
--- Initializing Player Variables ---
	Paths.Player = game.Players.LocalPlayer;

	-- Other Variables
	Paths.Audio = script.Parent.Audio
	
	
--- Initializing Modules ---
	local ModuleLoader = require(script.ModuleLoader)

	-- Other Modules
	ModuleLoader.Register("GameInfo", Paths.Services.RStorage.Modules.GameInfo)
	ModuleLoader.Register("Setup", script.Setup);
	ModuleLoader.Register("Format", Paths.Services.RStorage.Modules.Format)
	ModuleLoader.Register("GameFunctions", Paths.Services.RStorage.Modules.GameFunctions)
	ModuleLoader.Register("GameInfo", Paths.Services.RStorage.Modules.GameInfo)
	ModuleLoader.Register("Camera", script.Camera)
	ModuleLoader.Register("AllAccessories", Paths.Services.RStorage.Modules.AllAccessories)
	ModuleLoader.Register("AllTools", Paths.Services.RStorage.Modules.AllTools)
	ModuleLoader.Register("AllAchievements", Paths.Services.RStorage.Modules.AllAchievements)
	ModuleLoader.Register("AllOutfits", Paths.Services.RStorage.Modules.AllOutfits)
	ModuleLoader.Register("AllEyes", Paths.Services.RStorage.Modules.AllEyes)
	ModuleLoader.Register("AllEmotes", Paths.Services.RStorage.Modules.AllEmotes)
	ModuleLoader.Register("MiningDetails", Paths.Services.RStorage.Modules.MiningDetails)
	ModuleLoader.Register("FishingConfig", Paths.Services.RStorage.Modules.FishingConfig)
	ModuleLoader.Register("FuncLib", Paths.Services.RStorage.Modules.FuncLib)
	ModuleLoader.Register("Emotes", script.Emotes)
	ModuleLoader.Register("GroupReward", script.GroupReward)
	ModuleLoader.Register("Verification", script.Verification)
	ModuleLoader.Register("DiscordVerification", script.DiscordVerification)
	
	-- Event Modules
	ModuleLoader.Register("EventsConfig", Paths.Services.RStorage.Modules.EventsConfig)
	
	-- Character Modules
	ModuleLoader.Register("DoubleJump", script.Character.DoubleJump);
	ModuleLoader.Register("Character", script.Character);
	ModuleLoader.Register("CharacterSelect", script.Character.CharacterSelect);
	
	-- UI Modules
	
	ModuleLoader.Register("DeviceDetector", script.DeviceDetector)
	ModuleLoader.Register("Feedback", script.Feedback)
	ModuleLoader.Register("UpdatingUI", script.UI.Updating)
	ModuleLoader.Register("UIAnimations", script.UI.Animations)
	ModuleLoader.Register("Scaling", script.UI.Scaling)
	ModuleLoader.Register("Teleporting", script.UI.Teleporting)
	ModuleLoader.Register("Map", script.UI.Map)
	ModuleLoader.Register("PlatformAdjustments", script.UI.PlatformAdjustments)
	ModuleLoader.Register("UI", script.UI)
	ModuleLoader.Register("Index", script.UI.Index)
	ModuleLoader.Register("Milestones", script.Milestones)
	-- ModuleLoader.Register("SpinTheWheel", script.Milestones.SpinTheWheel)
	ModuleLoader.Register("Playtime", script.Milestones.Playtime)
	ModuleLoader.Register("Achievements", script.Milestones.Achievements)
	ModuleLoader.Register("Quests", script.Milestones.Quests)
	
	-- Store Modules
	ModuleLoader.Register("Store", script.Store)
	ModuleLoader.Register("Gamepasses", script.Store.Gamepasses)
	ModuleLoader.Register("Money", script.Store.Money)
	ModuleLoader.Register("Gems", script.Store.Gems)
	ModuleLoader.Register("Accessories", script.Store.Accessories)
	ModuleLoader.Register("Boosts", script.Store.Boosts)
	
	-- Hearts Modules
	ModuleLoader.Register("Hearts", script.Hearts);

	-- Penguin Modules
	--ModuleLoader.Register("PenguinsUI", script.Penguins.PenguinsUI)
	ModuleLoader.Register("Penguins", script.Penguins)
	ModuleLoader.Register("Customization", script.Penguins.Customization)
	
	-- Audio Modules
	ModuleLoader.Register("Audio", Paths.Services.RStorage.Modules.Audio)
	ModuleLoader.Register("AudioHandler", script.AudioHandler)
	
	-- Other Modules (That have to be required after)
	ModuleLoader.Register("Aquarium", script.Aquarium)
	ModuleLoader.Register("Fishing", script.Fishing)
	ModuleLoader.Register("Tools", script.Tools)
	
	-- Pets
	ModuleLoader.Register("PetDetails", Paths.Services.RStorage.Modules.PetDetails)
	ModuleLoader.Register("Pets", script.Pets)
	ModuleLoader.Register("Zones", script.Zones)

	ModuleLoader.Register("SettingDetails", Paths.Services.RStorage.Modules.SettingDetails)
	ModuleLoader.Register("Settings", script.Settings)
	ModuleLoader.Register("LeaderboardDetails", Paths.Services.RStorage.Modules.LeaderboardDetails)
	
	ModuleLoader.Register("Leaderboards", script.Leaderboards)
	ModuleLoader.Register("SystemMessages", script.SystemMessages)


	ModuleLoader.Register("Buttons", script.UI.Buttons)
	-- Load Version
	ModuleLoader.Load()
	Paths.UI.Main.Version.Text = Paths.Modules.GameInfo.Version

end

return Paths
local Paths = {}

Paths.Services = {}
Paths.Modules = {}
Paths.UI = {}


function Paths.Initiliaze()
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	--- Initializing Services ---
	-- print("Load services")
	Paths.Services.Players = game:GetService("Players");
	Paths.Services.StarterGui = game:GetService("StarterGui");
	Paths.Services.RStorage = game:GetService("ReplicatedStorage");
	Paths.Services.MPService = game:GetService("MarketplaceService");
	Paths.Services.RunService = game:GetService("RunService");
	Paths.Services.TweenService = game:GetService("TweenService");
	Paths.Services.InputService = game:GetService("UserInputService");
	Paths.Services.TextService = game:GetService("TextService");
	Paths.Services.TeleportService = game:GetService("TeleportService");
	Paths.Services.ContentProvider = game:GetService("ContentProvider");
	Paths.Services.ContextActionService = game:GetService("ContextActionService");
	Paths.Services.CollectionService = game:GetService("CollectionService");
	Paths.Services.PhysicsService = game:GetService("PhysicsService")
	Paths.Services.ProximityPrompt = game:GetService("ProximityPromptService")

	Paths.Services.GuiService = game:GetService("GuiService");

	Paths.Dependency = Paths.Services.RStorage:WaitForChild("ClientDependency")
	--- Initializing UI ---
	-- print("Load UI")
	local PlayerGui = Paths.Services.Players.LocalPlayer.PlayerGui
	Paths.UI.Main = PlayerGui:WaitForChild("Main")
	Paths.UI.SpecialEffects = PlayerGui:WaitForChild("SpecialEffects")
	Paths.UI.LoadingScreen = PlayerGui:WaitForChild("LoadingScreen")

	Paths.UI.Left = Paths.UI.Main:WaitForChild("Left")
	Paths.UI.Right = Paths.UI.Main:WaitForChild("Right")
	Paths.UI.Center = Paths.UI.Main:WaitForChild("Center")
	Paths.UI.Bottom = Paths.UI.Main:WaitForChild("Bottom")
	Paths.UI.Top = Paths.UI.Main:WaitForChild("Top")
	Paths.UI.Full = Paths.UI.Main:WaitForChild("Full")
	Paths.UI.BLCorner = Paths.UI.Main:WaitForChild("BLCorner")
	Paths.UI.CharacterSelect = PlayerGui:WaitForChild("CharacterSelect"):WaitForChild("Background"):WaitForChild("Center")
	Paths.UI.Tools = Paths.UI.Bottom.Tools


--- Initializing Remotes ---
	Paths.Remotes = Paths.Services.RStorage.Remotes;


--- Initializing Player Variables ---
	Paths.Player = Paths.Services.Players.LocalPlayer;
	local TycoonName = Paths.Player:GetAttribute("Tycoon")
	Paths.Tycoon = workspace.Tycoons:WaitForChild(TycoonName)

	-- Other Variables
	Paths.Audio = script.Parent.Audio


--- Initializing Modules ---
	local ModuleLoader = require(script.ModuleLoader)

	-- Other Modules
	-- print("Load Modules")
	ModuleLoader.Register("Setup", script.Setup);

	ModuleLoader.Register("FuncLib", Paths.Services.RStorage.Modules.FuncLib)
	ModuleLoader.Register("Format", Paths.Services.RStorage.Modules.Format)
	ModuleLoader.Register("GameFunctions", Paths.Services.RStorage.Modules.GameFunctions)
	ModuleLoader.Register("GameInfo", Paths.Services.RStorage.Modules.GameInfo)
	ModuleLoader.Register("Camera", script.Camera)
	ModuleLoader.Register("Help", script.Tycoon.Help)
	ModuleLoader.Register("AllOutfits", Paths.Services.RStorage.Modules.AllOutfits)
	ModuleLoader.Register("AllAccessories", Paths.Services.RStorage.Modules.AllAccessories)
	ModuleLoader.Register("AllAchievements", Paths.Services.RStorage.Modules.AllAchievements)
	ModuleLoader.Register("AllTools", Paths.Services.RStorage.Modules.AllTools);
	ModuleLoader.Register("AllEyes", Paths.Services.RStorage.Modules.AllEyes)
	ModuleLoader.Register("AllEmotes", Paths.Services.RStorage.Modules.AllEmotes)
	ModuleLoader.Register("Indicators", script.Setup.Indicators)
	ModuleLoader.Register("PassButtons", script.Setup.PassButtons)
	ModuleLoader.Register("GroupReward", script.GroupReward)
	ModuleLoader.Register("EventsConfig", Paths.Services.RStorage.Modules.EventsConfig)
	ModuleLoader.Register("PlaceIds", Paths.Services.RStorage.Modules.PlaceIds)
	ModuleLoader.Register("FishingConfig", Paths.Services.RStorage.Modules.FishingConfig)
	ModuleLoader.Register("Maid", Paths.Services.RStorage.Modules.Maid)
	ModuleLoader.Register("Signal", Paths.Services.RStorage.Modules.Signal)
	ModuleLoader.Register("Verification", script.Verification)
	ModuleLoader.Register("DiscordVerification", script.DiscordVerification)
	ModuleLoader.Register("ProgressionDetails", Paths.Services.RStorage.Modules.ProgressionDetails)
	ModuleLoader.Register("MiningDetails", Paths.Services.RStorage.Modules.MiningDetails)
	ModuleLoader.Register("VehicleDetails", Paths.Services.RStorage.Modules.VehicleDetails)
	ModuleLoader.Register("BuildADetails", Paths.Services.RStorage.Modules.BuildADetails)
	ModuleLoader.Register("DeviceDetector", script.DeviceDetector)
	ModuleLoader.Register("Feedback", script.Feedback)
	ModuleLoader.Register("PartyUtil", Paths.Services.RStorage.Modules.PartyUtil)


	-- Tool Modules
	ModuleLoader.Register("Tools", script.Tools);

	-- Character Modules
	-- print("loading character modules")
	ModuleLoader.Register("Emotes", script.Emotes)
	ModuleLoader.Register("DoubleJump", script.Character.DoubleJump);
	ModuleLoader.Register("Character", script.Character);
	ModuleLoader.Register("CharacterSelect", script.Character.CharacterSelect);

	-- UI Modules
	-- print("ui modules")
	ModuleLoader.Register("UpdatingUI", script.UI.Updating)
	ModuleLoader.Register("Scaling", script.UI.Scaling)
	ModuleLoader.Register("UIAnimations", script.UI.Animations)
	ModuleLoader.Register("Teleporting", script.UI.Teleporting)
	ModuleLoader.Register("TycoonTeleporting", script.UI.TycoonTeleporting)
	ModuleLoader.Register("PlatformAdjustments", script.UI.PlatformAdjustments)
	ModuleLoader.Register("Snackbars", script.UI.Snackbars)
	ModuleLoader.Register("UI", script.UI)
	ModuleLoader.Register("Index", script.UI.Index)

	ModuleLoader.Register("Milestones", script.Milestones)
	-- ModuleLoader.Register("SpinTheWheel", script.Milestones.SpinTheWheel)
	ModuleLoader.Register("Playtime", script.Milestones.Playtime)
	ModuleLoader.Register("Achievements", script.Milestones.Achievements)
	ModuleLoader.Register("Quests", script.Milestones.Quests)

	-- print("penguin modules")
	-- Penguin Modules
	ModuleLoader.Register("PenguinsUI", script.Penguins.PenguinsUI)
	ModuleLoader.Register("Penguins", script.Penguins)
	ModuleLoader.Register("Customization", script.Penguins.Customization)

	-- print("audio modules")
	-- Audio Modules
	ModuleLoader.Register("Audio", Paths.Services.RStorage.Modules.Audio)
	ModuleLoader.Register("AudioHandler", script.AudioHandler)

	-- print("tycoon/fishing modules")
	-- Other Modules (That have to be required after)
	ModuleLoader.Register("Tycoon", script.Tycoon)
	ModuleLoader.Register("Rebirths", script.Tycoon.Rebirths)
	ModuleLoader.Register("BuildA", script.Tycoon.BuildA);
	ModuleLoader.Register("Fishing", script.Tycoon.Fishing)
	ModuleLoader.Register("Rocket", script.Tycoon.Rocket)

	
	-- print("Load pets module")
	-- Pets
	ModuleLoader.Register("PetDetails", Paths.Services.RStorage.Modules.PetDetails)
	ModuleLoader.Register("Pets", script.Pets)

	ModuleLoader.Register("SettingDetails", Paths.Services.RStorage.Modules.SettingDetails)
	ModuleLoader.Register("Settings", script.Settings)
	-- print("store modules")
	-- Store Modules
	ModuleLoader.Register("Store", script.Store)
	ModuleLoader.Register("Gamepasses", script.Store.Gamepasses)
	ModuleLoader.Register("Money", script.Store.Money)
	ModuleLoader.Register("Gems", script.Store.Gems)
	ModuleLoader.Register("Boosts", script.Store.Boosts)
	ModuleLoader.Register("Accessories", script.Store.Accessories)

	-- print("store modules")
	-- Store Modules
	ModuleLoader.Register("Store", script.Store)
	ModuleLoader.Register("Gamepasses", script.Store.Gamepasses)
	ModuleLoader.Register("Money", script.Store.Money)
	ModuleLoader.Register("Gems", script.Store.Gems)
	ModuleLoader.Register("Boosts", script.Store.Boosts)
	ModuleLoader.Register("Accessories", script.Store.Accessories)

	ModuleLoader.Register("Leaderboards", script.Leaderboards)
	ModuleLoader.Register("SystemMessages", script.SystemMessages)

	ModuleLoader.Register("TycoonUIProgress", script.UI.TycoonUIProgress)
	ModuleLoader.Register("Buttons", script.UI.Buttons)
	ModuleLoader.Register("Parties", script.UI.Parties)

	-- Load Version
	ModuleLoader.Load()
	Paths.UI.Main.Version.Text = Paths.Modules.GameInfo.Version

end

return Paths
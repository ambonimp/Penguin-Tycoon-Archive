local Paths = {}

Paths.Services = {}
Paths.Modules = {}
Paths.UI = {}

function Paths.Initiliaze()
	--- Initializing Services ---
	print("Load services")
	Paths.Services.RStorage = game:GetService("ReplicatedStorage");
	Paths.Services.MPService = game:GetService("MarketplaceService");
	Paths.Services.RunService = game:GetService("RunService");
	Paths.Services.TweenService = game:GetService("TweenService");
	Paths.Services.InputService = game:GetService("UserInputService");
	Paths.Services.TextService = game:GetService("TextService");
	Paths.Services.TeleportService = game:GetService("TeleportService");
	Paths.Services.ContentProvider = game:GetService("ContentProvider");
	Paths.Services.ContextActionService = game:GetService("ContextActionService");
	Paths.Services.PhysicsService = game:GetService("PhysicsService")

	Paths.Services.GuiService = game:GetService("GuiService");
	
	Paths.Dependency = Paths.Services.RStorage:WaitForChild("ClientDependency")
	--- Initializing UI ---
	print("LOad UI")
	local PlayerGui = game.Players.LocalPlayer.PlayerGui
	Paths.UI.Main = PlayerGui:WaitForChild("Main")
	Paths.UI.SpecialEffects = PlayerGui:WaitForChild("SpecialEffects")

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
	Paths.Player = game.Players.LocalPlayer;
	local TycoonName = Paths.Player:GetAttribute("Tycoon")
	Paths.Tycoon = workspace.Tycoons:WaitForChild(TycoonName)
	
	-- Other Variables
	Paths.Audio = script.Parent.Audio
	
	
--- Initializing Modules ---
	-- Other Modules
	print("Load Modules")
	Paths.Modules.Setup = require(script.Setup);
	Paths.Modules.Format = require(Paths.Services.RStorage.Modules.Format)
	Paths.Modules.GameFunctions = require(Paths.Services.RStorage.Modules.GameFunctions)
	Paths.Modules.GameInfo = require(Paths.Services.RStorage.Modules.GameInfo)
	Paths.Modules.Camera = require(script.Camera)
	Paths.Modules.Help = require(script.Tycoon.Help)
	Paths.Modules.AllOutfits = require(Paths.Services.RStorage.Modules.AllOutfits)
	Paths.Modules.AllAccessories = require(Paths.Services.RStorage.Modules.AllAccessories)
	Paths.Modules.AchievementsDictionary = require(Paths.Services.RStorage.Modules.Achievements)
	Paths.Modules.AllEyes = require(Paths.Services.RStorage.Modules.AllEyes)
	Paths.Modules.AllEmotes = require(Paths.Services.RStorage.Modules.AllEmotes)
	Paths.Modules.Indicators = require(script.Setup.Indicators)
	Paths.Modules.Settings = require(script.Settings)
	Paths.Modules.GroupReward = require(script.GroupReward)
	Paths.Modules.FishingConfig = require(Paths.Services.RStorage.Modules.FishingConfig)
	Paths.Modules.FuncLib = require(Paths.Services.RStorage.Modules.FuncLib)
	Paths.Modules.Maid = require(Paths.Services.RStorage.Modules.Maid)
	Paths.Modules.Signal = require(Paths.Services.RStorage.Modules.Signal)
	Paths.Modules.Verification = require(script.Verification)
	Paths.Modules.DiscordVerification = require(script.DiscordVerification)
	Paths.Modules.ProgressionDetails = require(Paths.Services.RStorage.Modules.ProgressionDetails)
	Paths.Modules.MiningDetails = require(Paths.Services.RStorage.Modules.MiningDetails)
	Paths.Modules.VehicleDetails = require(Paths.Services.RStorage.Modules.VehicleDetails)
	Paths.Modules.DeviceDetector = require(script.DeviceDetector)
	Paths.Modules.Feedback = require(script.Feedback)
	


	-- Tool Modules
	Paths.Modules.Tools = require(script.Tools);

	-- Character Modules
	print("loading character modules")
	Paths.Modules.Emotes = require(script.Emotes)
	Paths.Modules.DoubleJump = require(script.Character.DoubleJump);
	Paths.Modules.Character = require(script.Character);
	Paths.Modules.CharacterSelect = require(script.Character.CharacterSelect);
	
	-- UI Modules
	print("ui modules")
	Paths.Modules.UpdatingUI = require(script.UI.Updating)
	Paths.Modules.UIAnimations = require(script.UI.Animations)
	Paths.Modules.Transitions = require(script.UI.Animations)
	Paths.Modules.Buttons = require(script.UI.Buttons)
	Paths.Modules.Teleporting = require(script.UI.Teleporting)
	Paths.Modules.PlatformAdjustments = require(script.UI.PlatformAdjustments)
	Paths.Modules.UI = require(script.UI)
	Paths.Modules.Index = require(script.UI.Index)
	Paths.Modules.Achievements = require(script.Achievements)
	Paths.Modules.SpinTheWheel = require(script.Achievements.SpinTheWheel)
	Paths.Modules.Playtime = require(script.Achievements.Playtime)
	Paths.Modules.AllAchievements = require(script.Achievements.AllAchievements)
	Paths.Modules.Quests = require(script.Achievements.Quests)

	print("store modules")
	-- Store Modules
	Paths.Modules.Store = require(script.Store)
	Paths.Modules.Gamepasses = require(script.Store.Gamepasses)
	Paths.Modules.Money = require(script.Store.Money)
	Paths.Modules.Gems = require(script.Store.Gems)
	Paths.Modules.Boosts = require(script.Store.Boosts)
	Paths.Modules.Accessories = require(script.Store.Accessories)
	
	print("penguin modules")
	-- Penguin Modules
	Paths.Modules.PenguinsUI = require(script.Penguins.PenguinsUI)
	Paths.Modules.Penguins = require(script.Penguins)
	Paths.Modules.Customization = require(script.Penguins.Customization)
	
	print("audio modules")
	-- Audio Modules
	Paths.Modules.Audio = require(Paths.Services.RStorage.Modules.Audio)
	Paths.Modules.AudioHandler = require(script.AudioHandler)
	
	print("tycoon/fishing modules")
	-- Other Modules (That have to be required after)
	Paths.Modules.Tycoon = require(script.Tycoon)
	Paths.Modules.Fishing = require(script.Tycoon.Fishing)
	Paths.Modules.TycoonProgressBar = require(script.UI.TycoonProgressBar)
	
--- Load Version ---
	Paths.UI.Main.Version.Text = Paths.Modules.GameInfo.Version
	
	print("Load pets module")
	-- Pets
	Paths.Modules.Pets = require(script.Pets)
end

return Paths
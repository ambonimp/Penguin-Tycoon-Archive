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
	
	
	Paths.Dependency = Paths.Services.RStorage:WaitForChild("ClientDependency")
	
--- Initializing UI ---
	local PlayerGui = game.Players.LocalPlayer.PlayerGui
	Paths.UI.Main = PlayerGui:WaitForChild("Main")
	Paths.UI.Left = Paths.UI.Main:WaitForChild("Left")
	Paths.UI.Right = Paths.UI.Main:WaitForChild("Right")
	Paths.UI.Center = Paths.UI.Main:WaitForChild("Center")
	Paths.UI.Bottom = Paths.UI.Main:WaitForChild("Bottom")
	Paths.UI.Top = Paths.UI.Main:WaitForChild("Top")
	Paths.UI.Full = Paths.UI.Main:WaitForChild("Full")
	Paths.UI.BLCorner = Paths.UI.Main:WaitForChild("BLCorner")
	Paths.UIFx = PlayerGui:WaitForChild("SpecialEffects")
	
	
--- Initializing Remotes ---
	Paths.Remotes = Paths.Services.RStorage.Remotes;
	
	
--- Initializing Player Variables ---
	Paths.Player = game.Players.LocalPlayer;

	-- Other Variables
	Paths.Audio = script.Parent.Audio
	
	
--- Initializing Modules ---
	-- Other Modules
	Paths.Modules.Setup = require(script.Setup);
	Paths.Modules.Format = require(Paths.Services.RStorage.Modules.Format)
	Paths.Modules.GameFunctions = require(Paths.Services.RStorage.Modules.GameFunctions)
	Paths.Modules.GameInfo = require(Paths.Services.RStorage.Modules.GameInfo)
	Paths.Modules.Camera = require(script.Camera)
	Paths.Modules.AllAccessories = require(Paths.Services.RStorage.Modules.AllAccessories)
	Paths.Modules.FuncLib = require(Paths.Services.RStorage.Modules.FuncLib)
	Paths.Modules.AllAchievements = require(Paths.Services.RStorage.Modules.AllAchievements)
	Paths.Modules.AllOutfits = require(Paths.Services.RStorage.Modules.AllOutfits)
	Paths.Modules.AllEyes = require(Paths.Services.RStorage.Modules.AllEyes)
	Paths.Modules.AllEmotes = require(Paths.Services.RStorage.Modules.AllEmotes)
	Paths.Modules.SettingDetails = require(Paths.Services.RStorage.Modules.SettingDetails)
	Paths.Modules.Emotes = require(script.Emotes)	
	Paths.Modules.GroupReward = require(script.GroupReward)
	Paths.Modules.Lighting = require(script.Lighting)
	Paths.Modules.Verification = require(script.Verification)
	Paths.Modules.DiscordVerification = require(script.DiscordVerification)
	
	-- Event Modules
	Paths.Modules.EventsConfig = require(Paths.Services.RStorage.Modules.EventsConfig)
	Paths.Modules.MiningDetails = require(Paths.Services.RStorage.Modules.MiningDetails)
	Paths.Modules.FishingConfig = require(Paths.Services.RStorage.Modules.FishingConfig)
	Paths.Modules.SpeedLines = require(script.UI.SpecialEffects.SpeedLines)
	Paths.Modules.Spectate = require(script.Events.Spectate)
	Paths.Modules.EventsUI = require(script.UI.Events)
	Paths.Modules.Events = require(script.Events)
	
	-- Character Modules
	Paths.Modules.DoubleJump = require(script.Character.DoubleJump);
	Paths.Modules.Character = require(script.Character);
	Paths.Modules.CharacterSelect = require(script.Character.CharacterSelect);
	
	-- UI Modules
	Paths.Modules.UpdatingUI = require(script.UI.Updating)
	Paths.Modules.UIAnimations = require(script.UI.Animations)
	Paths.Modules.Index = require(script.UI.Index)
	Paths.Modules.Teleporting = require(script.UI.Teleporting)
	Paths.Modules.PlatformAdjustments = require(script.UI.PlatformAdjustments)
	Paths.Modules.UI = require(script.UI)
	Paths.Modules.Milestones = require(script.Milestones)
	-- Paths.Modules.SpinTheWheel = require(script.Milestones.SpinTheWheel)
	-- Paths.Modules.Playtime = require(script.Milestones.Playtime)
	Paths.Modules.Achievements = require(script.Milestones.Achievements)
	Paths.Modules.Quests = require(script.Milestones.Quests)
	-- Hearts Modules
	Paths.Modules.Hearts = require(script.Hearts);
	
	-- Store Modules
	Paths.Modules.DeviceDetector = require(script.DeviceDetector)
	Paths.Modules.Feedback = require(script.Feedback)
	Paths.Modules.Store = require(script.Store)
	Paths.Modules.Gamepasses = require(script.Store.Gamepasses)
	Paths.Modules.Money = require(script.Store.Money)
	Paths.Modules.Gems = require(script.Store.Gems)
	Paths.Modules.Boosts = require(script.Store.Boosts)
	Paths.Modules.Accessories = require(script.Store.Accessories)
	
	-- Penguin Modules
	--Paths.Modules.PenguinsUI = require(script.Penguins.PenguinsUI)
	Paths.Modules.Penguins = require(script.Penguins)
	Paths.Modules.Customization = require(script.Penguins.Customization)
	
	-- Audio Modules
	Paths.Modules.Audio = require(Paths.Services.RStorage.Modules.Audio)
	Paths.Modules.AudioHandler = require(script.AudioHandler)

	
	Paths.Modules.Settings = require(script.Settings)
	
	--- Load Version ---
	Paths.UI.Main.Version.Text = Paths.Modules.GameInfo.Version
	
	-- Pets
	Paths.Modules.PetDetails = require(Paths.Services.RStorage.Modules.PetDetails)
	Paths.Modules.Pets = require(script.Pets)

	
	Paths.Modules.Buttons = require(script.UI.Buttons)
end

return Paths
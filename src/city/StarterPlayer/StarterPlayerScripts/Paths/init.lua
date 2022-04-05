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
	Paths.Modules.AllEyes = require(Paths.Services.RStorage.Modules.AllEyes)
	Paths.Modules.AllEmotes = require(Paths.Services.RStorage.Modules.AllEmotes)
	Paths.Modules.Settings = require(script.Settings)
	Paths.Modules.Emotes = require(script.Emotes)	
	Paths.Modules.GroupReward = require(script.GroupReward)
	Paths.Modules.Lighting = require(script.Lighting)
	Paths.Modules.Verification = require(script.Verification)
	
	-- Event Modules
	Paths.Modules.EventsConfig = require(Paths.Services.RStorage.Modules.EventsConfig)
	Paths.Modules.Events = require(script.Events)
	Paths.Modules.Spectate = require(script.Events.Spectate)
	
	-- Character Modules
	Paths.Modules.DoubleJump = require(script.Character.DoubleJump);
	Paths.Modules.Character = require(script.Character);
	Paths.Modules.CharacterSelect = require(script.Character.CharacterSelect);
	
	-- UI Modules
	Paths.Modules.UpdatingUI = require(script.UI.Updating)
	Paths.Modules.UIAnimations = require(script.UI.Animations)
	Paths.Modules.Buttons = require(script.UI.Buttons)
	Paths.Modules.Teleporting = require(script.UI.Teleporting)
	Paths.Modules.PlatformAdjustments = require(script.UI.PlatformAdjustments)
	Paths.Modules.UI = require(script.UI)

	-- Hearts Modules
	Paths.Modules.Hearts = require(script.Hearts);
	
	-- Store Modules
	Paths.Modules.Store = require(script.Store)
	Paths.Modules.Gamepasses = require(script.Store.Gamepasses)
	Paths.Modules.Money = require(script.Store.Money)
	Paths.Modules.Accessories = require(script.Store.Accessories)
	
	-- Penguin Modules
	--Paths.Modules.PenguinsUI = require(script.Penguins.PenguinsUI)
	Paths.Modules.Penguins = require(script.Penguins)
	Paths.Modules.Customization = require(script.Penguins.Customization)
	
	-- Audio Modules
	Paths.Modules.Audio = require(Paths.Services.RStorage.Modules.Audio)
	Paths.Modules.AudioHandler = require(script.AudioHandler)
	
	-- Other Modules (That have to be required after)


	--- Load Version ---
	Paths.UI.Main.Version.Text = Paths.Modules.GameInfo.Version
	
	-- Pets
	Paths.Modules.Pets = require(script.Pets)
end

return Paths
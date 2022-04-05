-- Character spawning and spawned event

local Character = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Paths.Dependency:WaitForChild(script.Name)

--- Functions ---

-- Fires when the character is spawned, 
-- Player: Object, Character: Object, OldChar: Optional-used if you want to respawn the character in the same position rather than reseting, so the player is respawned in the same location rather than getting reset
function Character:Spawned(Player, Character, OldChar)
	task.wait()
	local Tycoon = Player:GetAttribute("Tycoon")
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Data then Player:Kick("Data Error | CODE: CHARACTER") return end
	
	if OldChar then
	-- Spawn at old character's point
		if OldChar:FindFirstChild("Humanoid") and OldChar:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("HumanoidRootPart") then
			if OldChar.Humanoid.Health > 0 then
				Character.HumanoidRootPart.CFrame = OldChar.HumanoidRootPart.CFrame
				return
			end
		end
		
		OldChar:Destroy()
	end
		
	-- Spawn at the tycoon location
	if workspace.Tycoons:FindFirstChild(Tycoon) then
		local SpawnLocation = workspace.Tycoons[Tycoon].Spawn
		Character:MoveTo(SpawnLocation.Position)
	end
end


-- Spawns the character
-- Player: Object, Type: String - no longer used, it was previously used to determine whether the player spawned as their 'Avatar' or a 'Penguin'
function Character:Spawn(Player, Type)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Data then Player:Kick("Data Error | CODE: CHARACTER") return end
	
	--if Type == "Avatar" then
	--	Player:LoadCharacter()
	--elseif Type == "Penguin" then
	
	local Penguin = Dependency.Penguin:Clone()
	Penguin.Name = Player.Name
	Player.Character = Penguin
	Penguin.Parent = workspace
	
	Modules.Tools.UnequipTool(Player)
	
	-- Set up new character
	Penguin.Humanoid.DisplayDistanceType = "None"
	Penguin:SetAttribute("PetAnimation","none")
	if Data["Settings"]["Faster Speed"] then
		Penguin.Humanoid.WalkSpeed *= Data["Walkspeed Multiplier"]
	end

	-- Insert custom nameplate
	local NamePlate = Dependency.CustomName:Clone()
	NamePlate.Parent = Penguin.HumanoidRootPart
	NamePlate.PlrName.Text = Data["My Penguin"]["Name"]
	--NamePlate.PlayerToHideFrom = Player
	
	Modules.Penguins:LoadPenguin(Penguin, Data["My Penguin"])
	
	
	-- connect character functions
	Penguin.Humanoid.Died:Connect(function()
		Modules.Tools.UnequipTool(Player)
	end)
	

	-- Make sure the penguin doesn't fall into unloaded parts
	Penguin.HumanoidRootPart.Anchored = true
	coroutine.wrap(function()
		wait()
		if Penguin:FindFirstChild("HumanoidRootPart") then
			Penguin.HumanoidRootPart.Anchored = false
		end
	end)()
end


--- Remote Events ---
local SpawnDB = {}

-- Connects the spawning remote that is fired from the client, as the server sometimes doesn't register the player reseting
-- Player: Object, Type: String - no longer used, it was previously used to determine whether the player spawned as their 'Avatar' or a 'Penguin'
Remotes.SpawnCharacter.OnServerEvent:Connect(function(Player, Type)
	if SpawnDB[Player.Name] then return end
	SpawnDB[Player.Name] = true
	
	Character:Spawn(Player, Type)
	
	task.wait(1.5)
	SpawnDB[Player.Name] = false
end)


return Character
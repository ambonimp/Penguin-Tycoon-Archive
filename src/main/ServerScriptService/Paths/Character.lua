-- Character spawning and spawned event

local Character = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Paths.Dependency:WaitForChild(script.Name)
local AllOutfits = Modules.AllOutfits

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
		Character:MoveTo(SpawnLocation.Position + Vector3.new(0,20,0))
	end
end


function Character:EquipShirt(Character,ShirtName)
	if Character == nil then return end
	if Character:FindFirstChild("Shirt") then
		Character:FindFirstChild("Shirt"):Destroy()
	end
	if ShirtName == "None" then
		return
	end
	local Shirt = Paths.Services.RStorage.Assets.Shirts:FindFirstChild(ShirtName):Clone()
	local Model = Instance.new("Model")
	Model.Parent = Character
	Model.Name = "Shirt"
	Model:SetAttribute("ItemName",ShirtName)
	for i,part in pairs (Shirt:GetChildren()) do
		if Character:FindFirstChild(part.Name) and part.Name ~= "Accessory" then
			for _,realPart in pairs (part:GetChildren()) do
				local old = Character:FindFirstChild(part.Name)
				local new = realPart

				new.CFrame = old.CFrame * part.CFrame:toObjectSpace(new.CFrame)
				
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = old
				weld.Part1 = new
				weld.Parent = new
				new.Anchored = false
				new.Parent = Model
				new.Massless = true
			end
		end
	end
	Shirt:Destroy()
end


-- Spawns the character
-- Player: Object, Type: String - no longer used, it was previously used to determine whether the player spawned as their 'Avatar' or a 'Penguin'
function Character:Spawn(Player, Type, Anchor)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Data then Player:Kick("Data Error | CODE: CHARACTER") return end
	
	--if Type == "Avatar" then
	--	Player:LoadCharacter()
	--elseif Type == "Penguin" then
	
	local Penguin = Dependency.Penguin:Clone()
	Penguin.PrimaryPart.Anchored = Anchor or false
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

	Penguin.Humanoid.WalkSpeed *= Modules.Pets.getBonus(Player,"Walk","Speed")

	local lastChange = os.time()
	Penguin:GetAttributeChangedSignal("PetAnimation"):Connect(function()
		local lastc = lastChange
		lastChange = os.time()
		local last = Penguin:GetAttribute("PetAnimation")
		if last ~= "none" then
			task.wait(8)
			if Penguin:GetAttribute("PetAnimation") == last and os.time()-lastc >= 7 then
				Penguin:SetAttribute("PetAnimation","none")
			end
		end
	end)
	local c
	c = Player:GetAttributeChangedSignal("PetsEquipped"):Connect(function()
		Penguin.Humanoid.WalkSpeed = 32
		if Data["Settings"]["Faster Speed"] then
			Penguin.Humanoid.WalkSpeed *= Data["Walkspeed Multiplier"]
		end
	
		Penguin.Humanoid.WalkSpeed *= Modules.Pets.getBonus(Player,"Walk","Speed")
	end)

	-- Insert custom nameplate
	local NamePlate = Dependency.CustomName:Clone()
	NamePlate.Parent = Penguin.HumanoidRootPart
	NamePlate.PlrName.Text = Data["My Penguin"]["Name"]
	--NamePlate.PlayerToHideFrom = Player
	
	Modules.Penguins:LoadPenguin(Penguin, Data["My Penguin"])
	
	
	-- connect character functions
	Penguin.Humanoid.Died:Connect(function()
		c:Disconnect()
		Modules.Tools.UnequipTool(Player)
	end)
	

	-- Make sure the penguin doesn't fall into unloaded parts
	Penguin.HumanoidRootPart.Anchored = true
	coroutine.wrap(function()
		task.wait(.5)
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
local Character = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local Dependency = Paths.Dependency:FindFirstChild(script.Name)
local AllOutfits = Modules.AllOutfits
--- Functions ---
function Character:Spawned(Player, Character, OldChar)
	wait()
	local Tycoon = Player:GetAttribute("Tycoon")
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Data then Player:Kick("Data Error | CODE: CHARACTER") return end
	
	--if OldChar then
	---- Spawn at old character's point
	--	if OldChar:FindFirstChild("Humanoid") and OldChar:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("HumanoidRootPart") then
	--		if OldChar.Humanoid.Health > 0 then
	--			Character.HumanoidRootPart.CFrame = OldChar.HumanoidRootPart.CFrame
	--			return
	--		end
	--	end
		
	--	OldChar:Destroy()
	--end
end

local Spawns = workspace.Spawns:GetChildren()

function Character:MoveTo(Player, SpecificLocation)
	if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") then
		local Character = Player.Character
		
		if SpecificLocation then
			Character.HumanoidRootPart.CFrame = SpecificLocation * CFrame.new(0, Character.HumanoidRootPart.Size.Y/2 + Character.Humanoid.HipHeight, 0)
			
		else
			local SpawnLocation = Spawns[Random.new():NextInteger(1, #Spawns)]
			Character:MoveTo(SpawnLocation.Position)
		end
		
		return Character
	else
		return Character:Spawn(Player, SpecificLocation)
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
			end
		end
	end
	Shirt:Destroy()
end

function Character:Spawn(Player, SpecificLocation,DontLoad)
	local Data = Modules.PlayerData.sessionData[Player.Name]
	if not Data then Player:Kick("Data Error | CODE: CHARACTER") return end
	
	local Penguin = Dependency.Penguin:Clone()
	Penguin.Name = Player.Name
	Player.Character = Penguin
	Penguin.Parent = workspace
	
	-- Move the character to a specific location if applicable
	if SpecificLocation then
		Penguin.HumanoidRootPart.CFrame = SpecificLocation
		
	else
		-- Spawn at the tycoon location
		local SpawnLocation = Spawns[Random.new():NextInteger(1, #Spawns)]
		Penguin:MoveTo(SpawnLocation.Position)
		
		Remotes.Lighting:FireClient(Player, "Night Skating")
	end
	
	-- Set up new character
	Penguin.Humanoid.DisplayDistanceType = "None"
	Penguin:SetAttribute("PetAnimation","none")
	if Data["Settings"]["Faster Speed"] then
		Penguin.Humanoid.WalkSpeed *= Data["Walkspeed Multiplier"]
	end
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

	-- Insert custom nameplate
	local NamePlate = Dependency.CustomName:Clone()
	NamePlate.Parent = Penguin.HumanoidRootPart
	NamePlate.PlrName.Text = Data["My Penguin"]["Name"]
	NamePlate.Hearts.Amount.Text = Modules.Format:FormatComma(Data["Hearts"])
	NamePlate.Hearts.Visible = Data["Settings"]["Show Hearts"]
	--NamePlate.PlayerToHideFrom = Player


	Modules.Penguins:LoadPenguin(Penguin, Data["My Penguin"],nil,nil,nil)
	
 

	-- Make sure the penguin doesn't fall into unloaded parts
	Penguin.HumanoidRootPart.Anchored = true
	coroutine.wrap(function()
		wait(0.1)
		if Penguin:FindFirstChild("HumanoidRootPart") then
			Penguin.HumanoidRootPart.Anchored = false
		end
		--[[]]
	end)()

	return Penguin
end


--- Remote Events ---
local SpawnDB = {}

Remotes.SpawnCharacter.OnServerEvent:Connect(function(Player, Type)
	if SpawnDB[Player.Name] then return end
	SpawnDB[Player.Name] = true
	
	Character:Spawn(Player)
	
	wait(1.5)
	SpawnDB[Player.Name] = false
end)


return Character
local Character = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local Dependency = Paths.Dependency:FindFirstChild(script.Name)

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

function Character:EquipShirt(Player,ShirtName)
	local Shirt = Paths.Services.RStorage.Assets.Shirts:FindFirstChild(ShirtName):Clone()
	local Character = Player.Character
	if Character == nil then return end
	for i,part in pairs (Shirt:GetChildren()) do
		if part.Name == "Left" then
			if Character:FindFirstChild("Left") then
				Character:FindFirstChild("Left"):Destroy()
			end
			local newLeft = part
			local weld = Instance.new("WeldConstraint")
			
			newLeft.CFrame = Character["Arm L"].CFrame * CFrame.new(0,.175,0)
			newLeft.Parent = Character
			weld.Part0 = Character["Arm L"]
			weld.Part1 = newLeft
			weld.Parent = newLeft
		elseif part.Name == "Right" then
			if Character:FindFirstChild("Right") then
				Character:FindFirstChild("Right"):Destroy()
			end
			local newRight = part
			local weld = Instance.new("WeldConstraint")

			newRight.CFrame = Character["Arm R"].CFrame * CFrame.new(0,.175,0)
			newRight.Parent = Character
			weld.Part0 = Character["Arm R"]
			weld.Part1 = newRight
			weld.Parent = newRight
		elseif part.Name == "Center" then
			if Character:FindFirstChild("Center") then
				Character:FindFirstChild("Center"):Destroy()
			end
			local newMain = part
			local weld = Instance.new("WeldConstraint")

			newMain.CFrame = Character["Main"].CFrame * CFrame.new(0,-.175,-.42) * CFrame.Angles(0,math.rad(180),0)
			newMain.Parent = Character
			weld.Part0 = Character["Main"]
			weld.Part1 = newMain
			weld.Parent = newMain
		end
	end
end

function Character:Spawn(Player, SpecificLocation)
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

	-- Insert custom nameplate
	local NamePlate = Dependency.CustomName:Clone()
	NamePlate.Parent = Penguin.HumanoidRootPart
	NamePlate.PlrName.Text = Data["My Penguin"]["Name"]
	NamePlate.Hearts.Amount.Text = Modules.Format:FormatComma(Data["Hearts"])
	NamePlate.Hearts.Visible = Data["Settings"]["Show Hearts"]
	--NamePlate.PlayerToHideFrom = Player

	
	Modules.Penguins:LoadPenguin(Penguin, Data["My Penguin"])


	-- Make sure the penguin doesn't fall into unloaded parts
	Penguin.HumanoidRootPart.Anchored = true
	coroutine.wrap(function()
		wait(0.1)
		if Penguin:FindFirstChild("HumanoidRootPart") then
			Penguin.HumanoidRootPart.Anchored = false
		end
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
local Character = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Camera = workspace.CurrentCamera

local CurrentCharacter = false
local IsInvisible = false

local LoadedAnimations = {}
local PreviousToolAnimation = nil

--- Character Functions ---
function Character.CharacterAdded(Character)
	IsInvisible = false
	LoadedAnimations = {}
	
	if Modules.Fishing then
		Modules.Fishing.CancelThrow(false, true)
	end
	
	-- Initiate/load character in other modules
	Modules.DoubleJump:NewCharacter(Character)
	Modules.Emotes:NewCharacter(Character)
	
	if Character:GetAttribute("Penguin") then
		local Animate = script.Animate:Clone()
		Animate.Parent = Character
		Animate.Disabled = false
	end
	
	local Humanoid = Character:WaitForChild("Humanoid", 5)
	
	if Humanoid then
		CurrentCharacter = Character
		Modules.Camera:ResetToCharacter()

		Humanoid.Died:Connect(function()
			--- Death Effect ---
			for i, v in pairs(Character:GetDescendants()) do
				if v.ClassName == "Motor6D" then
					v:Destroy()
				elseif v:IsA("BasePart") then
					v.CanCollide = true
				end
			end
			task.wait(1)
			Modules.CharacterSelect:Respawn()
		end)
		
		
		--- Tools stuff ---
		if Character:WaitForChild("HumanoidRootPart", 1) then
			local A1 = Instance.new("Attachment", Character.HumanoidRootPart)
			A1.Name = "Attachment1"
			
			
			if Character:FindFirstChild("HumanoidRootPart") then
				local RootPart = Character.HumanoidRootPart
				
				local AlignPos = RootPart:FindFirstChild("GliderPower") or Instance.new("AlignPosition", RootPart)
				AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
				AlignPos.Name = "GliderPower"
				
				AlignPos.Attachment0 = A1
				AlignPos.Enabled = false
			end
		end
	end
end


--- Tool animations
function Character:PlayToolAnimation(Animation)
	--Animation = "Glider Up"
	if not CurrentCharacter or not Paths.Services.RStorage.Animations:FindFirstChild(Animation) then return end
	local Humanoid = CurrentCharacter:WaitForChild("Humanoid", 3)

	if PreviousToolAnimation and not LoadedAnimations[Animation] then 
		Character:StopToolAnimation()
	elseif PreviousToolAnimation and LoadedAnimations[Animation] and not (LoadedAnimations[Animation] == PreviousToolAnimation) then
		Character:StopToolAnimation()
	end
	
	if Humanoid and Humanoid.Health > 0 and not PreviousToolAnimation then
		if not LoadedAnimations[Animation] then
			local Track = Humanoid:LoadAnimation(Paths.Services.RStorage.Animations[Animation])
			Track.Priority = Enum.AnimationPriority.Action
			LoadedAnimations[Animation] = Track
		end
		
		LoadedAnimations[Animation]:Play()
		PreviousToolAnimation = LoadedAnimations[Animation]
	end
end

function Character:StopToolAnimation()
	if PreviousToolAnimation then
		PreviousToolAnimation:Stop()
		PreviousToolAnimation = nil
	end
end


-- Character manipulation functions
function Character:Freeze()
	local Char = Paths.Player.Character

	if Char and Char:FindFirstChild("HumanoidRootPart") then
		Char.HumanoidRootPart.Anchored = true
	end
end

function Character:Unfreeze()
	local Char = Paths.Player.Character

	if Char and Char:FindFirstChild("HumanoidRootPart") then
		Char.HumanoidRootPart.Anchored = false
	end
end

function Character:Invisible(Freeze)
	if IsInvisible == false then -- if the player is currently visible then
		IsInvisible = true
		local Char = Paths.Player.Character
		
		if Char then
			for i, v in pairs(Char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency += 1
				elseif string.match(v.ClassName, "Gui") then
					v.Enabled = false
				end
			end
		end
		
		if Freeze then
			if Char:FindFirstChild("HumanoidRootPart") then
				Char.HumanoidRootPart.Anchored = true
			end
		end
	end
end

function Character:Visible()
	if IsInvisible == true then -- if the player is currently invisible then
		IsInvisible = false
		local Char = Paths.Player.Character

		if Char then
			for i, v in pairs(Char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency -= 1
				elseif string.match(v.ClassName, "Gui") then
					v.Enabled = true
				end
			end
		end
	end
end


--- Initialize Character
Paths.Player.CharacterAdded:Connect(Character.CharacterAdded)
if Paths.Player.Character then
	Character.CharacterAdded(Paths.Player.Character)
end

return Character
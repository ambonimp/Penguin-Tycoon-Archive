local Character = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Camera = workspace.CurrentCamera

local IsInvisible = false

--- Character Functions ---
function Character.CharacterAdded(Character)
	IsInvisible = false

	Modules.DoubleJump:NewCharacter(Character)
	Modules.Emotes:NewCharacter(Character)
	
	if Character:GetAttribute("Penguin") then
		local Animate = script.Animate:Clone()
		Animate.Parent = Character
		Animate.Disabled = false
	end
	
	local Humanoid = Character:WaitForChild("Humanoid", 5)
	
	if Humanoid then
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
			wait(1)
			Modules.CharacterSelect:Respawn()
		end)
	end
end


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
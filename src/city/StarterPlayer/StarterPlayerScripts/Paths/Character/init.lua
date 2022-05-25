local Character = {}

--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Camera = workspace.CurrentCamera

local IsInvisible = false
local CurrentCharacter = false
local Mouse = Paths.Player:GetMouse()
local snowballInput = nil
local LoadedAnimations = {}
local PreviousToolAnimation = nil
--- Character Functions ---
function Character.CharacterAdded(Character)
	IsInvisible = false
	LoadedAnimations = {}

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

		local hockeyAnim = Services.RStorage.Animations.Hockey
		local ThrowAnim = Services.RStorage.Animations.ThrowToy
		local loaded = Humanoid:WaitForChild("Animator"):LoadAnimation(hockeyAnim)
		local throwloaded = Humanoid:WaitForChild("Animator"):LoadAnimation(ThrowAnim)
		if snowballInput then
			snowballInput:Disconnect()
		end

		local camera = workspace.CurrentCamera

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {CurrentCharacter,workspace.Zones.Snowball.Part}
		params.FilterType = Enum.RaycastFilterType.Blacklist 

		local function rayResult(x, y)
			local unitRay = camera:ScreenPointToRay(x, y) -- :ViewportPointToRay() is another choice
			return workspace:Raycast(unitRay.Origin, unitRay.Direction * 300, params)
		end
		local throwing = false
		local pos = nil
		throwloaded:GetMarkerReachedSignal("THROW"):Connect(function()
			Paths.Audio.Throw:Play()
			local snowball = Remotes.GetSnowball:InvokeServer()
			if snowball and pos then
				Character.Snowball.Handle.Transparency = 1
				local currentpos = rayResult(pos.X,pos.Y)
				if currentpos then
					local dis = ((Character.Main.CFrame * Vector3.new(0, 3, -3))-currentpos.Position).magnitude
					local t = dis/20
					if dis > 30 then
						t = .75
					else
						t = .4
					end
					local g = Vector3.new(0, -workspace.Gravity, 0);
					local x0 = Character.Main.CFrame * Vector3.new(0, 3, -3)
					local v0 = (currentpos.Position - x0 - 0.5*g*t*t)/t;
					snowball.CFrame = Character.Main.CFrame * CFrame.new(0,3,-3)
					snowball.Velocity = v0
				else
					snowball.CFrame = Character.Main.CFrame * CFrame.new(0,0,-3)
					snowball.Velocity = (camera.CFrame.LookVector+Vector3.new(0,.75,0)) * 90
				end
				task.wait(1.75)
				throwing = false
				Character.Snowball.Handle.Transparency = 0
			end
		end)

		Character.ChildAdded:Connect(function(Child)
			local n = Child.Name 
			if n == "Hockey Stick" then
				loaded:Play()
			elseif n == "Snowball" then
				snowballInput = game:GetService("UserInputService").InputBegan:Connect(function(input,gpe)
					if gpe then return end
					if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonR2) and not throwing then
						throwing = true
						pos = game:GetService("UserInputService"):GetMouseLocation()
						throwloaded:Play(.2,nil,1.75)
					end
				end)
			end
		end)

		Character.ChildRemoved:Connect(function(Child)
			local n = Child.Name 
			if n == "Hockey Stick" then
				loaded:Stop()
			elseif n == "Snowball" then
				if snowballInput then
					snowballInput:Disconnect()
				end
			end
		end)
	end

	
end

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
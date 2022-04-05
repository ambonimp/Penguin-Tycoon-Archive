local DoubleJump = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local SettingsUI = UI.Center.Settings.Holder

--- Double jump variables
local Character
local Humanoid
local Animation

local TIME_BETWEEN_JUMPS = 0.22

local candj = false
local jump1 = false
local State = ""

function DoubleJump:NewCharacter(Character)
	Character = Character
	Humanoid = Character:WaitForChild("Humanoid")
	Animation = Humanoid:LoadAnimation(Character:WaitForChild("Animations"):WaitForChild("Double Jump"))
	Animation.Looped = false
	
	Humanoid.StateChanged:Connect(function(old,new)
		State = new.Name
		if State == "Landed" or State == "Running" or State == "RunningNoPhysics" then
			Humanoid.JumpPower = 60
			candj = true
		end

		if State == "Jumping" and (old ~= "Jumping" and old ~= "Freefall") then
			if jump1 == false then
				jump1 = true
				task.wait(TIME_BETWEEN_JUMPS)
				jump1 = false
			end
		end
	end)
end


Services.InputService.JumpRequest:Connect(function()
	if SettingsUI["Double Jump"].Locked.Visible == false and SettingsUI["Double Jump"].Toggle.IsToggled.Value == true then
		if State == "Freefall" or State == "Jumping" then
			if candj and not jump1 then
				candj = false
				Humanoid.JumpPower = 70
				Animation:Play(0.1)

				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)


return DoubleJump
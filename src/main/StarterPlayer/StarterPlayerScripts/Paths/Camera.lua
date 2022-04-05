local Camera = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local CurrentCamera = workspace.CurrentCamera

local AttachTweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)


--- Camera Functions ---
function Camera:AttachTo(CF, Tween)
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	
	local TweenGoal = {CFrame = CF}
	local AttachTween = Services.TweenService:Create(CurrentCamera, AttachTweenInfo, TweenGoal)
	
	AttachTween:Play()
end

function Camera:ResetToCharacter(Tween)
	for i = 1, 3, 1 do -- Will retry twice if character isn't found
		local Character = Paths.Player.Character

		if Character then
			local Humanoid = Character:WaitForChild("Humanoid", 3)

			if Humanoid then
				if Tween then


				else
					CurrentCamera.CameraSubject = Humanoid
					CurrentCamera.CameraType = "Custom"
				end

				break
			end
		end

		task.wait(1)
	end
end

--function Camera:ResetToCharacter(Humanoid)
--	print(1)
--	Camera.CameraSubject = Humanoid
--	print(2)
--end


return Camera
local Glider = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local DEST_CONST = 21 -- used to determine the speed of the acceleration
local LOWERING_CONST = 10 -- constant used to determine how fast the player is moving towards the ground (higher = slower)

local IsHoldingSpace = false

Services.InputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed and input.KeyCode ~= Enum.KeyCode.ButtonA then
		return
	else
		local KeyPressed = input.KeyCode
		
		if KeyPressed == Enum.KeyCode.Space or KeyPressed == Enum.KeyCode.ButtonA then
			IsHoldingSpace = true
		end
	end
end)

Services.InputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed and input.KeyCode ~= Enum.KeyCode.ButtonA then
		return
	else
		local KeyPressed = input.KeyCode

		if KeyPressed == Enum.KeyCode.Space or KeyPressed == Enum.KeyCode.ButtonA then
			IsHoldingSpace = false
		end
	end
end)

coroutine.wrap(function()
	repeat wait() until Modules.PlatformAdjustments and Modules.PlatformAdjustments.CurrentPlatform
	
	if Modules.PlatformAdjustments.CurrentPlatform == "Mobile" then
		local PlayerGui = Paths.Player.PlayerGui
		if PlayerGui:WaitForChild("TouchGui", 3) and PlayerGui.TouchGui:WaitForChild("TouchControlFrame", 1) and PlayerGui.TouchGui.TouchControlFrame:WaitForChild("JumpButton", 1) then
			PlayerGui.TouchGui.TouchControlFrame.JumpButton.MouseButton1Down:Connect(function()
				IsHoldingSpace = true
			end)
			
			PlayerGui.TouchGui.TouchControlFrame.JumpButton.MouseButton1Up:Connect(function()
				IsHoldingSpace = false
			end)
		end
	end
end)()
	
	
--- Functions ---
task.spawn(function()
	Services.RunService.RenderStepped:Connect(function()
		if string.match(Paths.Player:GetAttribute("Tool"), "Glider") then
			if Paths.Player:GetAttribute("Tool") == "Glider" then
				DEST_CONST = 21
				LOWERING_CONST = 10
			elseif Paths.Player:GetAttribute("Tool") == "Powered Glider" then
				DEST_CONST = 40
				LOWERING_CONST = 15
			end
			
			local Char = Paths.Player.Character
			if Char and Char:FindFirstChild("HumanoidRootPart") and Char.HumanoidRootPart:FindFirstChild("GliderPower") then
				local RootPart = Paths.Player.Character.HumanoidRootPart
				local AlignPos = RootPart.GliderPower
				
				if Char.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					local upVector = 0
					if IsHoldingSpace then
						Modules.Character:PlayToolAnimation("Glider Up")
						upVector = 10
					else
						Modules.Character:PlayToolAnimation(Paths.Player:GetAttribute("Tool"))
					end
					
					local cFrameRP = RootPart.CFrame
					local lv = cFrameRP.LookVector

					AlignPos.Position = RootPart.Position + Vector3.new(lv.X * DEST_CONST, (-DEST_CONST) / LOWERING_CONST + upVector, lv.Z * DEST_CONST)
					AlignPos.Enabled = true
					

					if Char:FindFirstChild("Tool") and Char.Tool:FindFirstChild("Trail1") and Char.Tool:FindFirstChild("Trail2") then
						Char.Tool.Trail1.Trail.Enabled = true
						Char.Tool.Trail2.Trail.Enabled = true
					end
				else
					AlignPos.Enabled = false

					if Char:FindFirstChild("Tool") and Char.Tool:FindFirstChild("Trail1") and Char.Tool:FindFirstChild("Trail2") then
						Char.Tool.Trail1.Trail.Enabled = false
						Char.Tool.Trail2.Trail.Enabled = false
					end
				end
			end
			
		else
			if Paths.Player.Character and Paths.Player.Character:FindFirstChild("HumanoidRootPart") and Paths.Player.Character.HumanoidRootPart:FindFirstChild("GliderPower") then
				local RootPart = Paths.Player.Character.HumanoidRootPart
				local AlignPos = RootPart.GliderPower
				
				AlignPos.Enabled = false
			end
		end
	end)

end)



return Glider
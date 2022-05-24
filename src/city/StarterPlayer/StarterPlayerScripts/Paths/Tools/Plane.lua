local Plane = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Rep = game:GetService("ReplicatedStorage")
local Player = Paths.Player
local Mouse = Player:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")


local Character 
local Humanoid 
local HumaoidRP 

local c = Player.Character or Player.CharacterAdded:Wait()
local lastPlane = nil
Character = c
Humanoid = Character:WaitForChild("Humanoid")
HumaoidRP = Character:WaitForChild("HumanoidRootPart")
local tweenService = game:GetService("TweenService")
local info = TweenInfo.new(.5)
local control = require(Player:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
local planeAmount = 10
local Power = 80
local keysDown = {}
local istouch = UIS.TouchEnabled

local last = Vector3.new(0,0,0)
local justStarted = tick()
local Forward = nil
local Gyro 
local lastDir = CFrame.new()
local flyOn = false
local didlastDir = false

function doFly(dir,dir2,dir3)
	didlastDir = false
	Forward.Velocity = (dir).lookVector*Power * (dir3 or 1)
	Gyro.D = 800
	Gyro.P = 50000
	if dir2 then
		lastDir = dir2
		local tween = tweenService:Create(Gyro,info,{CFrame = (dir2)*CFrame.new(0,0,-100) })
		tween:Play()
	else
		lastDir = dir
		local tween = tweenService:Create(Gyro,info,{CFrame = (dir)*CFrame.new(0,0,-100) })
		tween:Play()
	end
end

function Rotate(vector, angle)
	return Vector2.new(
		vector.X * math.cos(angle) + vector.Y * math.sin(angle),
		-vector.X * math.sin(angle) + vector.Y * math.cos(angle)
	)
end

function endFlight()
	if flyOn == false then return end
	if lastPlane then
		lastPlane.MainPart.Sound:Stop()
	end
	flyOn = false
	Gyro.D = 00
	Gyro.P = 0
	Gyro.CFrame = CFrame.new()
	RunService:UnbindFromRenderStep("flying")
    HumaoidRP.Anchored = false
    local Children = HumaoidRP:GetChildren()
	if Forward then Forward:Destroy() end
    for i, child in pairs(Children) do
        if child:IsA("BodyVelocity") or child:IsA("BodyGyro") then
            child:Destroy()
        end
    end
end


UIS.InputChanged:Connect(function(input, gameProcessed)
	if flyOn and input.Position and input.Delta and gameProcessed then
		local oldPosition = (input.Position - input.Delta)
		local l = Vector3.new(0,0,0)
		if (input.Position - oldPosition).Magnitude < .7 then
			if input.Position.Y < oldPosition.Y then
				l = l + Vector3.new(1,0,0)
			elseif input.Position.Y > oldPosition.Y  then
				l = l + Vector3.new(-1,0,0)
			end
			if input.Position.X < oldPosition.X  then
				l = l + Vector3.new(0,0,1)
			elseif input.Position.X > oldPosition.X  then
				l = l + Vector3.new(0,0,-1)
			end
			last = l
		end
	end
end)



function flying()
	if Humanoid == nil or Humanoid.SeatPart == nil then return end
	if istouch or UIS.GamepadConnected and not UIS.KeyboardEnabled then
		if control:GetMoveVector() ~= Vector3.new(0,0,0) then
		--[[	local cf1 = HumaoidRP.CFrame
			local change = last

			if change.X > 0 then
				cf1 = cf1 * CFrame.Angles(math.rad(planeAmount),0,0)
			else
				cf1 = cf1 * CFrame.Angles(math.rad(-planeAmount),0,0)
			end
			if change.Z > 0 then
				cf1 = cf1 * CFrame.Angles(0,math.rad(planeAmount),0)
			else
				cf1 = cf1 * CFrame.Angles(0,math.rad(-planeAmount),0)
			end
			doFly(cf1,cf1*CFrame.new(0,0,100))--]]
			doFly(Camera.CFrame,Camera.CFrame*CFrame.new(0,0,100))
		else
			doFly(HumaoidRP.CFrame,HumaoidRP.CFrame*CFrame.new(0,0,100))
		end
	else
		local keys = {
			[Enum.KeyCode.W] = CFrame.Angles(math.rad(planeAmount),0,0),
			[Enum.KeyCode.S] = CFrame.Angles(math.rad(-planeAmount),0,0),
			[Enum.KeyCode.D] = CFrame.Angles(0,math.rad(-planeAmount+3),0),
			[Enum.KeyCode.A] = CFrame.Angles(0,math.rad(planeAmount+3),0)
		}
		local cf1 = HumaoidRP.CFrame
		local down = false
		for key,cf in pairs (keys) do
			if keysDown[key] then
				down = true
				cf1 = cf1*cf
			end
		end
		if down then
			doFly(cf1,cf1*CFrame.new(0,0,100))
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {Character,unpack(Humanoid.SeatPart.Parent:GetDescendants())}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(Character.HumanoidRootPart.Position-Vector3.new(0,8,0), Vector3.new(0,-10,0), raycastParams)

	if raycastResult then
		local hit = raycastResult.Instance
		if hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid") then
			--don't land on player
		elseif tick()-justStarted > 2 then
			Paths.UI.Bottom.StartEngine.Visible = true
			Paths.UI.Bottom.StopEngine.Visible = false
			endFlight()
		end
	end
end


function checkflight()
	if flyOn then return end
	flyOn = true
	if HumaoidRP:FindFirstChildOfClass("BodyVelocity") then
		HumaoidRP:FindFirstChildOfClass("BodyVelocity"):Destroy()
	end
	lastPlane = Humanoid.SeatPart.Parent
	lastPlane.MainPart.Sound:Play()
	last = Vector3.new(0,0,0)
	Forward = Instance.new("BodyVelocity",HumaoidRP)
	Forward.Name = "Movement"
	Forward.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	
	Gyro = Instance.new("BodyGyro")
	Gyro.MaxTorque = Vector3.new(math.huge,math.huge,0)
	Gyro.D = 0--100
	Gyro.P = 0--50000
	Gyro.Parent = HumaoidRP
	Gyro.CFrame = HumaoidRP.CFrame*CFrame.Angles(math.rad(5),0,0)*CFrame.new(0,0,100)
	RunService:BindToRenderStep("flying",Enum.RenderPriority.Character.Value,flying)

	doFly(HumaoidRP.CFrame*CFrame.Angles(math.rad(15),0,0),HumaoidRP.CFrame*CFrame.Angles(math.rad(15),0,0)*CFrame.new(0,0,100))
end

UIS.InputBegan:Connect(function(Input,gpe)
	if gpe then return end
	keysDown[Input.KeyCode] = true
end)
UIS.InputEnded:Connect(function(Input,gpe)
	if gpe then return end
	keysDown[Input.KeyCode] = false
end)

Player.CharacterAdded:Connect(function(character)
	repeat task.wait() until character:IsDescendantOf(workspace)
	Humanoid = character:WaitForChild("Humanoid")
	HumaoidRP = character:WaitForChild("HumanoidRootPart")
end)

Paths.UI.Bottom.StartEngine.Button.MouseButton1Down:Connect(function()
	local ve = Player:GetAttribute("Vehicle")
	if ve == "Plane" then
		Paths.UI.Bottom.StartEngine.Visible = false
		Paths.UI.Bottom.StopEngine.Visible = true
		Power = 120
		justStarted = tick()
		checkflight()
	elseif ve == "Robux Plane" then
		Paths.UI.Bottom.StartEngine.Visible = false
		Paths.UI.Bottom.StopEngine.Visible = true
		Power = 200
		justStarted = tick()
		checkflight()
	end
end)

Paths.UI.Bottom.StopEngine.Button.MouseButton1Down:Connect(function()
	Paths.UI.Bottom.StartEngine.Visible = true
	Paths.UI.Bottom.StopEngine.Visible = false
	endFlight()
end)

Player:GetAttributeChangedSignal("Vehicle"):Connect(function()
	local ve = Player:GetAttribute("Vehicle")
	if ve == "Plane" then
		Paths.UI.Bottom.StartEngine.Visible = true
	elseif ve == "Robux Plane" then
		Paths.UI.Bottom.StartEngine.Visible = true
	else
		Paths.UI.Bottom.StopEngine.Visible = false
		Paths.UI.Bottom.StartEngine.Visible = false
		endFlight()
	end
end)


return Plane
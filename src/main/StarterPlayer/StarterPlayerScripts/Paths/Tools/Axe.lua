local Axe = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local ParticleSystem = require(Services.RStorage.Modules.FreshParticles)

local Animation = nil
local treeParticles = {}

function tweenModel(model,cf)
	local c = Instance.new("CFrameValue")
	local og = model:GetPrimaryPartCFrame()
	c.Value = og
	c:GetPropertyChangedSignal("Value"):Connect(function()
		model:SetPrimaryPartCFrame(c.Value)
	end)
	task.defer(function()
		local tween = Services.TweenService:Create(c,TweenInfo.new(.23),{Value = cf})
		tween:Play()
		task.wait(.3)
		local tween2 = Services.TweenService:Create(c,TweenInfo.new(.23),{Value = og})
		tween2:Play()
		task.wait(.3)
		c:Destroy()
	end)
end


--- Functions ---
coroutine.wrap(function()
	local n1 = 2
	while true do
		s = 1
		if string.match(Paths.Player:GetAttribute("Tool"), "Axe") then
			s = Remotes.GetBonus:InvokeServer("Woodcutting","Speed")
			local Char = Paths.Player.Character
			if Char and Char:FindFirstChild("HumanoidRootPart") then
				if Char:FindFirstChild("WoodcuttingAnim") == nil then
					local new = Services.RStorage.Animations.Woodcutting:Clone()
					new.Name = "WoodcuttingAnim"
					new.Parent = Char
					Animation = Char.Humanoid.Animator:LoadAnimation(new)
				end
 				local parts = workspace:GetPartBoundsInRadius((Char:GetPrimaryPartCFrame()*CFrame.new(0,0,-5)).Position,3)
				local trees = {}
				for i,v in pairs (parts) do
					if v.Parent.Parent:GetAttribute("Tree") and v.Parent.Parent:GetAttribute("Health") > 0 and Paths.Player:GetAttribute("Tree"..v.Parent.Parent.Name)  then
						local dis = v.Parent.Parent.Name ~= "GrandTree" and 12 or 14
						if table.find(trees,v.Parent.Parent) == nil and (Char.PrimaryPart.Position-v.Parent.Parent.PrimaryPart.Position).magnitude < dis then
							table.insert(trees,v.Parent.Parent)
						end
					end
				end
				if #trees > 0 then
					local n = "Chopping"..n1
					Paths.Audio:FindFirstChild(n):Play()
					n1+=1 
					if n1 > 3 then
						n1 = 1
					end
					Animation:Play(nil,nil,1.25 * s)
					Animation.Looped = false
				elseif Animation then
					Animation:Stop()
				end
				for i,v in pairs (trees) do
					if treeParticles[v] then
						treeParticles[v]:Spawn()
					else
						treeParticles[v] = ParticleSystem.new()
						treeParticles[v].ParticlePart = Services.RStorage.Assets.WoodParticle
						treeParticles[v].Size = 2
						treeParticles[v].Color = v.PrimaryPart.Color
						treeParticles[v].Offset = Vector3.new(0,3.5,0)
						treeParticles[v].EmissionPart = v.PrimaryPart
						treeParticles[v].Speed = 16
						treeParticles[v].RotSpeed = 6
						treeParticles[v].Lifetime = .6
						treeParticles[v].EasingStyle = Enum.EasingStyle.Quad
						treeParticles[v].ExtraWeight = .29
						treeParticles[v].Amount = 4
						treeParticles[v]:Spawn()
					end
					local am = 7
					if v.Name == "GrandTree" then
						am = 2
					end
					tweenModel(v,v:GetPrimaryPartCFrame()*CFrame.Angles(math.rad(math.random(-am,am)),0,math.rad(math.random(-am,am))))

					Remotes.Axe:FireServer(v)
					Modules.Index.TreeCut(v.Name)
				end

			end

		elseif Animation then
			Animation:Stop()
		end
		task.wait(.5/s)
	end
end)()



return Axe
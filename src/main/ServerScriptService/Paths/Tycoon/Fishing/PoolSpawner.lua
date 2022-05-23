local runService = game:GetService("RunService")
local physicsService = game:GetService("PhysicsService")

local Dependency = game:GetService("ServerStorage"):WaitForChild("ServerDependency"):FindFirstChild(script.Name)
-- variables
local rand = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local PlayerPools = {}
local PlayerPoolCount = 0
local config = {
	MaxPools = 15,
	Lifespan = 3 * 60, -- seconds
	InitialPosition = Vector3.new(0, 100, 0),
	Direction = Vector3.new(0, -500, 0),
	Radius = 5000,
	MinDistance = 500,
	SpawnOffset = 5,
	SpawnFolder = workspace:WaitForChild("ActivePools")
}

local buffer = {
	Debounce = false,
	DisposeDebounce = false,
	CurrentCount = 0,
	Pools = nil
}

local tycoons = workspace.Tycoons
local islands = workspace.Islands


local PoolSpawner = {}
PoolSpawner.ActivePools = {}

function PoolSpawner.HandshakePosition(position)
	for _, object: Folder in pairs(tycoons:GetChildren()) do
		local center = object:FindFirstChild("Center")
		
		if center and (center.Position - position).Magnitude < config.MinDistance then
			return false
		end
	end
	
	for _, object: Model in pairs(islands:GetChildren()) do
		local objectPos = object:GetPivot().Position

		if (objectPos - position).Magnitude < config.MinDistance then 
			return false
		end
	end
	
	return true
end

function PoolSpawner.GetPosition()
	while task.wait() do
		local position = config.InitialPosition + Vector3.new(
			rand:NextNumber(-config.Radius, config.Radius), 0,
			rand:NextNumber(-config.Radius, config.Radius))
		
		local result = workspace:Raycast(position, config.Direction, raycastParams)

		if result and result.Material == Enum.Material.Water then
			if PoolSpawner.HandshakePosition(result.Position) then
				return result.Position
			end
		end
	end
end

function PoolSpawner.GetModel(pos)
	local position = pos or PoolSpawner.GetPosition()
	local y_rotation = (os.clock() * 18) % 360
	local offset = Vector3.new(0, -3.3, 0)
	
	local model = Dependency.Pool:Clone()
	model:PivotTo(CFrame.new(position + offset) * CFrame.Angles(0, math.rad(y_rotation), 0))
	model.Name = "Pool-" .. rand:NextInteger(1, 250)
	model.Parent = config.SpawnFolder
	return model
end

function PoolSpawner.createCustom(Player,pos)
	if PlayerPools[Player.Name] then
		return
	end
	for i,pool in pairs (buffer.Pools) do
		local pos1 = pool:GetPivot().Position
		if (pos-pos1).Magnitude <= 15 then
			return
		end
	end
	local n = Player.Name
	PlayerPoolCount += 1
	local randomNumber = rand:NextInteger(3, 10)
	
	local model = PoolSpawner.GetModel(pos)
	model:SetAttribute("CreatedTime", os.clock())
	model:SetAttribute("OffsetTime", randomNumber)
	for i,v in pairs (model.Fish:GetChildren()) do
		local anim = v.Animation
		local con = v.AnimationController
		local p = con:LoadAnimation(anim)
		p:Play()
	end
	PlayerPools[n] = model
	model.Catch.CatchArea.Timer.Enabled = true
	model.Catch.Fire.Shiny.Enabled = true
	for i = 29,0,-1 do
		if game.Players:FindFirstChild(n) == nil then
			break
		end
		model.Catch.CatchArea.Timer.TextLabel.Text = i
		task.wait(1)
	end
	model:Destroy() 
	PlayerPoolCount -= 1
	PlayerPools[n] = nil
end

function PoolSpawner.Init()
	local randomNumber = rand:NextInteger(3, 10)
	
	local model = PoolSpawner.GetModel()
	model:SetAttribute("CreatedTime", os.clock())
	model:SetAttribute("OffsetTime", randomNumber)
	
	buffer.Debounce = true
	task.wait(randomNumber)
	
	--warn("[+] Created Pool: " .. randomNumber .. "s (WaitTime)")
	buffer.Debounce = false
end

function PoolSpawner.Dispose(model)
	local createdTime = model:GetAttribute("CreatedTime")
	local offset = model:GetAttribute("OffsetTime")
	
	if (createdTime and offset) and (os.clock() > createdTime + (config.Lifespan - offset)) then
		--warn("[-] Removed Pool")
		model:Destroy()
	end
end

function PoolSpawner.Animate(pool)
	local y_rotation = (os.clock() * 24) % 360
	local currentPosition = pool:GetPivot().Position
	pool:PivotTo(CFrame.new(currentPosition) * CFrame.Angles(0, math.rad(y_rotation), 0))
end

function PoolSpawner.Main()
	for i, pool in pairs(buffer.Pools) do
		PoolSpawner.Animate(pool)
		PoolSpawner.Dispose(pool)	
	end
end

runService.Heartbeat:Connect(function()
	buffer.Pools = workspace.ActivePools:GetChildren()
	
	if #buffer.Pools < config.MaxPools+PlayerPoolCount and not buffer.Debounce then
		coroutine.wrap(function() PoolSpawner.Init() end)()
	end
	
	PoolSpawner.Main()
end)

return PoolSpawner


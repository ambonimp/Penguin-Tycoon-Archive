local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local pose = "Standing"

local userNoUpdateOnLoopSuccess, userNoUpdateOnLoopValue = pcall(function() return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop") end)
local userNoUpdateOnLoop = userNoUpdateOnLoopSuccess and userNoUpdateOnLoopValue

local AnimationSpeedDampening = .4
local HumanoidHipHeight = Humanoid.HipHeight

local currentAnim = ""
local currentAnimInstance = nil
local currentAnimTrack = nil
local currentAnimKeyframeHandler = nil
local currentAnimSpeed = 1

local runAnimTrack = nil
local runAnimKeyframeHandler = nil

local PreloadedAnims = {}

local Animations = script.Parent:WaitForChild("Animations")

local animTable = {}

local animNames = { 
	idle = 	{{id = Animations.Idle.AnimationId, weight = 1 }},
	walk = 	{{id = Animations.Run.AnimationId, weight = 10 }}, 
	run = 	{{id = Animations.Run.AnimationId, weight = 10 }}, 
	fall = 	{{id = Animations.Fall.AnimationId, weight = 1 }}, 
	climb = 	{{id = Animations.Climb.AnimationId, weight = 1 }}, 
	jump =	{{id = Animations.Jump.AnimationId, weight = 10 }},
	sit =	{{id = Animations.Sit.AnimationId, weight = 10 }},
	swim =	{{id = Animations.Swim.AnimationId, weight = 1 }},
	swimidle =  {{id = Animations.SwimIdle.AnimationId, weight = 10 }},
}

math.randomseed(tick())

function findExistingAnimationInSet(set, anim)
	if set == nil or anim == nil then
		return 0
	end
	
	for idx = 1, set.count, 1 do 
		if set[idx].anim.AnimationId == anim.AnimationId then
			return idx
		end
	end
	
	return 0
end

function configureAnimationSet(name, fileList)
	if (animTable[name] ~= nil) then
		for _, connection in pairs(animTable[name].connections) do
			connection:disconnect()
		end
	end
	animTable[name] = {}
	animTable[name].count = 0
	animTable[name].totalWeight = 0	
	animTable[name].connections = {}

	local allowCustomAnimations = true

	local success, msg = pcall(function() allowCustomAnimations = game:GetService("StarterPlayer").AllowCustomAnimations end)
	if not success then
		allowCustomAnimations = true
	end

	-- check for config values
	local config = script:FindFirstChild(name)
	if (allowCustomAnimations and config ~= nil) then
		table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
		table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
		
		local idx = 0
		for _, childPart in pairs(config:GetChildren()) do
			if (childPart:IsA("Animation")) then
				local newWeight = 1
				local weightObject = childPart:FindFirstChild("Weight")
				if (weightObject ~= nil) then
					newWeight = weightObject.Value
				end
				animTable[name].count = animTable[name].count + 1
				idx = animTable[name].count
				animTable[name][idx] = {}
				animTable[name][idx].anim = childPart
				animTable[name][idx].weight = newWeight
				animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
				table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
				table.insert(animTable[name].connections, childPart.ChildAdded:connect(function(property) configureAnimationSet(name, fileList) end))
				table.insert(animTable[name].connections, childPart.ChildRemoved:connect(function(property) configureAnimationSet(name, fileList) end))
			end
		end
	end
	
	-- fallback to defaults
	if (animTable[name].count <= 0) then
		for idx, anim in pairs(fileList) do
			animTable[name][idx] = {}
			animTable[name][idx].anim = Instance.new("Animation")
			animTable[name][idx].anim.Name = name
			animTable[name][idx].anim.AnimationId = anim.id
			animTable[name][idx].weight = anim.weight
			animTable[name].count = animTable[name].count + 1
			animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
		end
	end
	
	-- preload anims
	for i, animType in pairs(animTable) do
		for idx = 1, animType.count, 1 do
			if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
				Humanoid:LoadAnimation(animType[idx].anim)
				PreloadedAnims[animType[idx].anim.AnimationId] = true
			end				
		end
	end
end

------------------------------------------------------------------------------------------------------------

function configureAnimationSetOld(name, fileList)
	if (animTable[name] ~= nil) then
		for _, connection in pairs(animTable[name].connections) do
			connection:disconnect()
		end
	end
	animTable[name] = {}
	animTable[name].count = 0
	animTable[name].totalWeight = 0	
	animTable[name].connections = {}

	local allowCustomAnimations = true

	local success, msg = pcall(function() allowCustomAnimations = game:GetService("StarterPlayer").AllowCustomAnimations end)
	if not success then
		allowCustomAnimations = true
	end

	-- check for config values
	local config = script:FindFirstChild(name)
	if (allowCustomAnimations and config ~= nil) then
		table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
		table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
		local idx = 1
		for _, childPart in pairs(config:GetChildren()) do
			if (childPart:IsA("Animation")) then
				table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
				animTable[name][idx] = {}
				animTable[name][idx].anim = childPart
				local weightObject = childPart:FindFirstChild("Weight")
				if (weightObject == nil) then
					animTable[name][idx].weight = 1
				else
					animTable[name][idx].weight = weightObject.Value
				end
				animTable[name].count = animTable[name].count + 1
				animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
				idx = idx + 1
			end
		end
	end

	-- fallback to defaults
	if (animTable[name].count <= 0) then
		for idx, anim in pairs(fileList) do
			animTable[name][idx] = {}
			animTable[name][idx].anim = Instance.new("Animation")
			animTable[name][idx].anim.Name = name
			animTable[name][idx].anim.AnimationId = anim.id
			animTable[name][idx].weight = anim.weight
			animTable[name].count = animTable[name].count + 1
			animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
			-- print(name .. " [" .. idx .. "] " .. anim.id .. " (" .. anim.weight .. ")")
		end
	end
	
	-- preload anims
	for i, animType in pairs(animTable) do
		for idx = 1, animType.count, 1 do 
			Humanoid:LoadAnimation(animType[idx].anim)
		end
	end
end

-- Setup animation objects
function scriptChildModified(child)
	local fileList = animNames[child.Name]
	if (fileList ~= nil) then
		configureAnimationSet(child.Name, fileList)
	end	
end

script.ChildAdded:connect(scriptChildModified)
script.ChildRemoved:connect(scriptChildModified)


for name, fileList in pairs(animNames) do 
	configureAnimationSet(name, fileList)
end	

-- ANIMATION

-- declarations
local jumpAnimTime = 0
local jumpAnimDuration = 0.31

local fallTransitionTime = 0.2

-- functions

function stopAllAnimations()
	local oldAnim = currentAnim

	currentAnim = ""
	currentAnimInstance = nil
	if (currentAnimKeyframeHandler ~= nil) then
		currentAnimKeyframeHandler:disconnect()
	end

	if (currentAnimTrack ~= nil) then
		currentAnimTrack:Stop()
		currentAnimTrack:Destroy()
		currentAnimTrack = nil
	end

	-- clean up walk if there is one
	if (runAnimKeyframeHandler ~= nil) then
		runAnimKeyframeHandler:disconnect()
	end
	
	if (runAnimTrack ~= nil) then
		runAnimTrack:Stop()
		runAnimTrack:Destroy()
		runAnimTrack = nil
	end
	
	return oldAnim
end

function getHeightScale()
	if Humanoid then
		if not Humanoid.AutomaticScalingEnabled then
			return 1
		end
		
		local scale = Humanoid.HipHeight / HumanoidHipHeight
		if AnimationSpeedDampening == nil then
			AnimationSpeedDampening = .4
		end
		if AnimationSpeedDampening ~= nil then
			scale = 1 + (Humanoid.HipHeight - HumanoidHipHeight) * AnimationSpeedDampening / HumanoidHipHeight
		end
		return scale
	end	
	return 1
end

function setAnimationSpeed(speed)
	if currentAnim ~= "walk" then
		if speed ~= currentAnimSpeed then
			currentAnimSpeed = speed
			currentAnimTrack:AdjustSpeed(currentAnimSpeed)
		end
	end
end

function keyFrameReachedFunc(frameName)
	if (frameName == "End") then
		if currentAnim == "walk" then
			if userNoUpdateOnLoop == true then
				if runAnimTrack.Looped ~= true then
					runAnimTrack.TimePosition = 0.0
				end
				if currentAnimTrack.Looped ~= true then
					currentAnimTrack.TimePosition = 0.0
				end
			else
				runAnimTrack.TimePosition = 0.0
				currentAnimTrack.TimePosition = 0.0
			end
		else
			local repeatAnim = currentAnim
			
			local animSpeed = currentAnimSpeed
			playAnimation(repeatAnim, 0.15, Humanoid)
			setAnimationSpeed(animSpeed)
		end
	end
end

function rollAnimation(animName)
	local roll = math.random(1, animTable[animName].totalWeight) 
	local origRoll = roll
	local idx = 1
	while (roll > animTable[animName][idx].weight) do
		roll = roll - animTable[animName][idx].weight
		idx = idx + 1
	end
	return idx
end

local function switchToAnim(anim, animName, transitionTime, humanoid)
	-- switch animation		
	if (anim ~= currentAnimInstance) then
		if (currentAnimTrack ~= nil) then
			currentAnimTrack:Stop(transitionTime)
			currentAnimTrack:Destroy()
		end

		if (runAnimTrack ~= nil) then
			runAnimTrack:Stop(transitionTime)
			runAnimTrack:Destroy()
			if userNoUpdateOnLoop == true then
				runAnimTrack = nil
			end
		end

		currentAnimSpeed = 1.0
	
		-- load it to the humanoid; get AnimationTrack
		currentAnimTrack = humanoid:LoadAnimation(anim)
		currentAnimTrack.Priority = Enum.AnimationPriority.Core
		 
		-- play the animation
		currentAnimTrack:Play(transitionTime)
		currentAnim = animName
		currentAnimInstance = anim

		-- set up keyframe name triggers
		if (currentAnimKeyframeHandler ~= nil) then
			currentAnimKeyframeHandler:disconnect()
		end
		currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)
		
		-- check to see if we need to blend a walk/run animation
		if animName == "walk" then
			--local runAnimName = "run"
			--local runIdx = rollAnimation(runAnimName)
			
			runAnimTrack = humanoid:LoadAnimation(Animations.Run)
			runAnimTrack.Priority = Enum.AnimationPriority.Core
			runAnimTrack:Play(transitionTime)		
			
			if (runAnimKeyframeHandler ~= nil) then
				runAnimKeyframeHandler:disconnect()
			end
			runAnimKeyframeHandler = runAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)	
		end
	end
end

function playAnimation(animName, transitionTime, humanoid)
	local idx = rollAnimation(animName)
	local anim = animTable[animName][idx].anim
	
	switchToAnim(anim, animName, transitionTime, humanoid)
end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- STATE CHANGE HANDLERS

function onRunning(speed)	
	if speed > 0.75 then
		playAnimation("walk", 0.2, Humanoid)
		pose = "Running"
	else
		playAnimation("idle", 0.2, Humanoid)
		pose = "Standing"
	end
end

function onDied()
	pose = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, Humanoid)
	jumpAnimTime = jumpAnimDuration
	pose = "Jumping"
end

function onClimbing(speed)
	local scale = 5.0
	playAnimation("climb", 0.1, Humanoid)
	setAnimationSpeed(speed / scale)
	pose = "Climbing"
end

function onGettingUp()
	pose = "GettingUp"
end

function onFreeFall()
	if (jumpAnimTime <= 0) then
		playAnimation("fall", fallTransitionTime, Humanoid)
	end
	pose = "FreeFall"
end

function onSeated()
	pose = "Seated"
end

function onFallingDown()
	pose = "FallingDown"
end

function onPlatformStanding()
	pose = "PlatformStanding"
end

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

function onSwimming(speed)
	if speed > 1.00 then
		local scale = 10.0
		playAnimation("swim", 0.4, Humanoid)
		setAnimationSpeed(speed / scale)
		pose = "Swimming"
	else
		playAnimation("swimidle", 0.4, Humanoid)
		pose = "Standing"
	end
end

local lastTick = 0

function stepAnimate(currentTime)
	local amplitude = 1
	local frequency = 1
  	local deltaTime = currentTime - lastTick
  	lastTick = currentTime

	local climbFudge = 0
	local setAngles = false

  	if (jumpAnimTime > 0) then
  		jumpAnimTime = jumpAnimTime - deltaTime
  	end

	if (pose == "FreeFall" and jumpAnimTime <= 0) then
		playAnimation("fall", fallTransitionTime, Humanoid)
	elseif (pose == "Seated") then
		playAnimation("sit", 0.5, Humanoid)
		return
	elseif (pose == "Running") then
		playAnimation("walk", 0.2, Humanoid)
	elseif (pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding") then
		stopAllAnimations()
		amplitude = 0.1
		frequency = 1
		setAngles = true
	end
end

-- connect events
Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.Seated:connect(onSeated)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.PlatformStanding:connect(onPlatformStanding)
Humanoid.Swimming:connect(onSwimming)

-- initialize to idle
playAnimation("idle", 0.1, Humanoid)
pose = "Standing"

-- loop to handle timed state transitions and tool animations
while Character.Parent ~= nil do
	local _, currentGameTime = wait(0.1)
	stepAnimate(currentGameTime)
end
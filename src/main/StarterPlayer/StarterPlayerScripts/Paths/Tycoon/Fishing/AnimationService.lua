-- animationTypes
local idle, catch, throw = nil, nil, nil

local replicatedStorage = game.ReplicatedStorage
local animationPriority = Enum.AnimationPriority
local animations = replicatedStorage:WaitForChild("Animations")

local AnimationService = {}

function AnimationService.InitializeAnimation(localPlayer, animationType, priority)
	local character = localPlayer.Character
	local animator: Animator = character.Humanoid.Animator
		
	local animation = animator:LoadAnimation(animationType)
	animation.Priority = priority
	animation:play()
	return animation
end

function AnimationService.ThrowAnimation(localPlayer, fishingModule)
	fishingModule.LastUpdate.FishingAnimationActive = true	
	throw = AnimationService.InitializeAnimation(localPlayer, animations.Throw, animationPriority.Action)
	throw.KeyframeReached:Connect(function()
		AnimationService.IdleAnimation(localPlayer)
		fishingModule.Throw()
	end)
end

function AnimationService.CatchAnimation(localPlayer)
	AnimationService.Destroy(idle)
	catch = AnimationService.InitializeAnimation(localPlayer, animations.Throw, animationPriority.Action)
end

function AnimationService.IdleAnimation(localPlayer)
	AnimationService.Destroy(idle)
	
	idle = AnimationService.InitializeAnimation(localPlayer, animations.Idle, animationPriority.Idle)
	idle.Looped = true
end

function AnimationService.Cancel(fishingModule)
	AnimationService.Destroy(idle)
	AnimationService.Destroy(catch)
	AnimationService.Destroy(throw)
	
	fishingModule.LastUpdate.FishingAnimationActive = false	
end

function AnimationService.Destroy(animation)
	if animation then
		animation:Stop()
		animation:Destroy()
		animation = nil
	end
end

return AnimationService

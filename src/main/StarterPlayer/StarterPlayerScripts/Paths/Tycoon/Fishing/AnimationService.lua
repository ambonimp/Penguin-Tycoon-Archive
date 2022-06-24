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
	animation:play(.1,nil,1 * replicatedStorage.Remotes.GetBonus:InvokeServer("Fishing","Speed"))
	return animation
end

function AnimationService.ThrowAnimation(localPlayer, fishingModule,wasAFK)
	fishingModule.LastUpdate.FishingAnimationActive = true	
	throw = AnimationService.InitializeAnimation(localPlayer, animations.Throw, animationPriority.Action)
	throw.KeyframeReached:Connect(function()
		if fishingModule.LastUpdate.isAFKFishing ~= wasAFK then
			AnimationService.Cancel(fishingModule)
			return
		end
		AnimationService.IdleAnimation(localPlayer,fishingModule)
		fishingModule.Throw()
	end)
end

function AnimationService.CatchAnimation(localPlayer)
	AnimationService.Destroy(idle)
	catch = AnimationService.InitializeAnimation(localPlayer, animations.Throw, animationPriority.Action)
end

function AnimationService.IdleAnimation(localPlayer,fishingModule)
	AnimationService.Destroy(idle)

	idle = AnimationService.InitializeAnimation(localPlayer, animations.Idle, animationPriority.Idle)
	idle.Looped = true	
end

function AnimationService.Cancel(fishingModule)
	fishingModule.LastUpdate.RunningMain = false
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

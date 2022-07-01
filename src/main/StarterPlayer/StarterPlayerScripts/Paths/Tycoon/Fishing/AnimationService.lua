local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationPriority = Enum.AnimationPriority
local Animations = ReplicatedStorage:WaitForChild("Animations")

local AnimationService = {}

local Player = Players.LocalPlayer
local Character

local Throw, Idle, Catch

local FishingModule

local function LoadAnimation(Animation, Priority, Looped)
	local Humanoid = Character:WaitForChild("Humanoid")
	Humanoid:WaitForChild("Animator")

	local Track = Humanoid:LoadAnimation(Animation)
	Track.Priority = Priority
	Track.Looped = Looped

	return Track
end

local function LoadCharacter(Char)
	if not Char then return end
	Character = Char

	Throw = LoadAnimation(Animations.Throw, AnimationPriority.Action)
	Idle = LoadAnimation(Animations.Idle, AnimationPriority.Idle, true)
	Catch = LoadAnimation(Animations.Catch, AnimationPriority.Action)

end


function AnimationService.ConnectFishingModule(FM)
	FishingModule = FM
end

function AnimationService.PlayThrow(AFK)
	FishingModule.LastUpdate.FishingAnimationActive = true

	Throw:Play(0.1, nil , 1 * ReplicatedStorage.Remotes.GetBonus:InvokeServer("Fishing","Speed"))
	local Conn
	Conn = Throw.KeyframeReached:Connect(function()
		Conn:Disconnect()
		if FishingModule.LastUpdate.isAFKFishing ~= AFK then
			AnimationService.Cancel()
			return
		end

		-- AnimationService.PlayIdle()
		task.wait(0.1)
		FishingModule.Throw()

	end)

end

function AnimationService.PlayCatch()
	Throw:Stop()
	Catch:Play(0.1, nil , 1 * ReplicatedStorage.Remotes.GetBonus:InvokeServer("Fishing","Speed"))
end

function AnimationService.PlayIdle()
	if not Idle.IsPlaying then
		Idle:Play(0.1, nil , 1 * ReplicatedStorage.Remotes.GetBonus:InvokeServer("Fishing","Speed"))
	end
end

function AnimationService.Cancel()
	FishingModule.LastUpdate.RunningMain = false
	
	Idle:Stop()
	Throw:Stop()
	Catch:Stop()

	FishingModule.LastUpdate.FishingAnimationActive = false
end

LoadCharacter(Player.Character)
Player.CharacterAdded:Connect(LoadCharacter)

return AnimationService

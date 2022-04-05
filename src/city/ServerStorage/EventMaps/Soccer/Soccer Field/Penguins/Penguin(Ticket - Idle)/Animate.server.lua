local Penguin = script.Parent
local Animator = Penguin:FindFirstChild("Humanoid") or Penguin:FindFirstChild("AnimationController").Animator

local Idle = Animator:LoadAnimation(Penguin.Animations.Idle)
local Actions = {}

for i, Animation in pairs(Penguin.Animations:GetChildren()) do
	if string.match(Animation.Name, "Action") then
		local Track = Animator:LoadAnimation(Animation)

		table.insert(Actions, Track)

		Track.Stopped:Connect(function()
			Idle:Play()
		end)
	end
end

Idle:Play()

if #Actions == 0 then
	return
end

while task.wait(Random.new():NextInteger(2, 5)) do
	local ActionToPlay = Random.new():NextInteger(1, #Actions)
	Actions[ActionToPlay]:Play()
end
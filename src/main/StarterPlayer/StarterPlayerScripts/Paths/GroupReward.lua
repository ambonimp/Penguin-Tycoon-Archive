local GroupReward = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local UI = Paths.UI.Center.GroupReward
GroupReward.IsClaimed = false

--- Group Reward Function ---
Remotes.GroupReward.OnClientEvent:Connect(function(IsClaimed)
	if IsClaimed then
		UI.Visible = true
		GroupReward.IsClaimed = true
	end
end)


UI.Claim.MouseButton1Down:Connect(function()
	UI:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), "In", "Back", 0.3, true)
	wait(0.3)
	UI:Destroy()
end)



return GroupReward
local Indicators = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Indicator Variables ---
local AllIndicators = Services.RStorage.Preload
AllIndicators.Parent = workspace


--- Indicator Functions ---
function Indicators:UpdateIsland(Island)
	local Owner = Island.Owner
	local Indicator = AllIndicators[Island.Name.." Island Indicator"]

	if Owner.Value ~= "None" then
		local Player = game.Players:FindFirstChild(Owner.Value)

		if Player then
			local Success, PlayerImage = pcall(function()
				return game.Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
			end)
			
			Indicator.GUI.PlayerIcon.Image = PlayerImage
			Indicator.GUI.Enabled = true
			
		else
			Indicator.GUI.Enabled = false
		end
		
	else
		Indicator.GUI.Enabled = false
	end
end

-- Load player indicators
coroutine.wrap(function()
	for i, Island in pairs(workspace.Tycoons:GetChildren()) do
		Indicators:UpdateIsland(Island)
		
		Island.Owner.Changed:Connect(function()
			Indicators:UpdateIsland(Island)
		end)
	end
end)()

	
return Indicators
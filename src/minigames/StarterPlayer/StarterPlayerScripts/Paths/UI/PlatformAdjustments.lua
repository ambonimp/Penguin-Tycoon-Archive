local PlatformAdjustments = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI



--- Platform Variables ---
local CurrentPlatform = nil

local function UpdatePlatform(InputType)
	if InputType == Enum.UserInputType.Gamepad1 then
		CurrentPlatform = "Console"
	elseif Services.InputService.TouchEnabled and not Services.InputService.MouseEnabled and not Services.InputService.GamepadEnabled and not Services.GuiService:IsTenFootInterface() then 
		CurrentPlatform = "Mobile"
	else
		CurrentPlatform = "PC"
	end
end

Services.InputService.LastInputTypeChanged:Connect(UpdatePlatform)
UpdatePlatform(Services.InputService:GetLastInputType())


--- Make Adjustments ---
coroutine.wrap(function()
	while true do
		if not CurrentPlatform then return end
		
		if CurrentPlatform == "Mobile" then
			Modules.Emotes.FullSize = UDim2.new(0.54, 0, 0.317, 0)
			
		elseif CurrentPlatform == "PC" or CurrentPlatform == "Console" then
			Modules.Emotes.FullSize = UDim2.new(0.54, 0, 0.317, 0)
		end
			
		wait(5)
	end
end)()



return PlatformAdjustments
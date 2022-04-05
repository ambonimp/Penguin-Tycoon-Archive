local PlatformAdjustments = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI



--- Platform Variables ---
PlatformAdjustments.CurrentPlatform = nil

local function UpdatePlatform(InputType)
	if InputType == Enum.UserInputType.Gamepad1 then
		PlatformAdjustments.CurrentPlatform = "Console"
	elseif Services.InputService.TouchEnabled and not Services.InputService.MouseEnabled and not Services.InputService.GamepadEnabled and not Services.GuiService:IsTenFootInterface() then 
		PlatformAdjustments.CurrentPlatform = "Mobile"
	else
		PlatformAdjustments.CurrentPlatform = "PC"
	end
end

Services.InputService.LastInputTypeChanged:Connect(UpdatePlatform)
UpdatePlatform(Services.InputService:GetLastInputType())


--- Make Adjustments ---
coroutine.wrap(function()
	while true do
		if not PlatformAdjustments.CurrentPlatform then return end
		
		if PlatformAdjustments.CurrentPlatform == "Mobile" then
			Paths.UI.Top.Position = UDim2.new(0.5, 0, 0, -36)
			
		elseif PlatformAdjustments.CurrentPlatform == "PC" then
			Paths.UI.Top.Position = UDim2.new(0.5, 0, 0, -36)
			
		elseif PlatformAdjustments.CurrentPlatform == "Console" then
			Paths.UI.Top.Position = UDim2.new(0.5, 0, 0, 0)
			
		end
			
		wait(5)
	end
end)()



return PlatformAdjustments
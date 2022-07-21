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

	-- warn(PlatformAdjustments.CurrentPlatform)
end

Services.InputService.LastInputTypeChanged:Connect(UpdatePlatform)
UpdatePlatform(Services.InputService:GetLastInputType())


--- Make Adjustments ---
coroutine.wrap(function()
	while true do
		if not PlatformAdjustments.CurrentPlatform then return end
		
		if PlatformAdjustments.CurrentPlatform == "Mobile" then
			Modules.Emotes.FullSize = UDim2.new(0.54, 0, 0.317, 0)
			
		elseif PlatformAdjustments.CurrentPlatform == "PC" or PlatformAdjustments.CurrentPlatform == "Console" then
			Modules.Emotes.FullSize = UDim2.new(0.165, 0, 0.8, 0)
		end
			
		task.wait(5)
	end
end)()



return PlatformAdjustments
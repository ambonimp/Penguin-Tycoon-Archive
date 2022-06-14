local DeviceDetector = {}

local GS = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")

function DeviceDetector:GetPlatform()
    if (GS:IsTenFootInterface()) then
        return "Console"
    elseif (UIS.TouchEnabled and not UIS.MouseEnabled) then
        return "Mobile"
    else
        return "Desktop"
    end
end

return DeviceDetector
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Postie = require(game.ReplicatedStorage.VoldexAdmin.Libs.Postie)

local function getDeviceType()
	if GuiService:IsTenFootInterface() then
		return "Console"
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "Mobile"
	else
		return "Desktop"
	end
end

Postie.SetCallback("GetPlayerDevice", getDeviceType)
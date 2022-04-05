local GS = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Postie = require(ReplicatedStorage.Postie)
local LS = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local EnableFocusEvents = not RunService:IsStudio()
local ForceFocus = true

-- Create A ScreenGUI to get screen size
local GUI = Instance.new("ScreenGui",game.Players.LocalPlayer.PlayerGui)

local function getDeviceType()

	if GS:IsTenFootInterface() then
		return "Console"
	elseif UIS.TouchEnabled and not UIS.MouseEnabled then
		return "Mobile"
	else
		return "Desktop"
	end
end

local function getTimestamp()
	return os.time()
end

local function getTimezone()
	return os.date("%z", os.time())
end

local function getLanguage()
	return LS.RobloxLocaleId
end

local function getScreenSize()
	return {
		width = GUI.AbsoluteSize.X,
		height = GUI.AbsoluteSize.Y
	}
end
local function getDeviceData()
	return {
		device_type = getDeviceType(),
		timestamp = getTimestamp(),
		timezone = getTimezone(),
		language = getLanguage(),
		screen = getScreenSize()
	}
end

local GetDeviceTypeFunction : RemoteFunction = ReplicatedStorage:WaitForChild("GetDeviceTypeFunction", 3)

if GetDeviceTypeFunction then
	GetDeviceTypeFunction.OnClientInvoke = getDeviceData
end

if EnableFocusEvents then
	local AppForegroundEvent : RemoteEvent = ReplicatedStorage:WaitForChild("AppForegroundEvent", 3)

	--This is being constantly fired while moving mouse in Studio
	local focusLost = false -- fire only once AppForegroundEvent

	if AppForegroundEvent then
		UserInputService.WindowFocused:Connect(function()
			if ForceFocus and focusLost then
				return
			end

			AppForegroundEvent:FireServer()
		end)
	end

	local AppBackgroundEvent : RemoteEvent = ReplicatedStorage:WaitForChild("AppBackgroundEvent", 3)
	if AppBackgroundEvent then
		UserInputService.WindowFocusReleased:Connect(function()
			if ForceFocus then
				focusLost = true
				return
			end

			AppBackgroundEvent:FireServer()
		end)
	end
end



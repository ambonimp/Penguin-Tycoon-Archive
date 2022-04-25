--[[
    THIS IS AN ADMIN SCRIPT TO CHECK HOW MANY PLAYERS ARE AFK FISHING WHEN PRESSING LEFT SHITF + K 
--]]

local userInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local remotesFolder = game:GetService("ReplicatedStorage").Remotes
local remoteFunction = remotesFolder:WaitForChild("CountPlayersFishingAFK")

if not remoteFunction then
    warn("Couldn't find remote function")
    return
end

-- CONSTANTS
local GROUP_ID = 12843903
local GROUP_RANK = 240

-- Members
local player = Players.LocalPlayer

-- Handles the keybind to open and close the menu
local function onInputBegan(input: InputObject, gpe: any)
	-- Check for Game Processed Event, which means if this input was programmatically requested
	if gpe then
		return
	end

	-- Check for Admin Input
	if
		input.KeyCode == Enum.KeyCode.K
		and (userInputService:IsKeyDown(Enum.KeyCode.LeftShift) or userInputService:IsKeyDown(Enum.KeyCode.RightShift))
	then
        if player:GetRankInGroup(GROUP_ID) >= GROUP_RANK then
            remoteFunction:InvokeServer() 
        end
	end
end

userInputService.InputBegan:Connect(onInputBegan)
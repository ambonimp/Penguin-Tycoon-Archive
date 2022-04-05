local paths = require(script.Parent.Parent)

local remotes = paths.Remotes

-- services
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- player
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

local objectHandler = require(script.ObjectHandler)
local bobberHandler = require(script.BobberHandler)
local animationService = require(script.AnimationService)
local uiAnimations = require(script.UIAnimations)


local funcLib = paths.Modules.FuncLib
local config = require(script.Config)
local poolHandler = require(script.PoolHandler)

local remotes = paths.Remotes
local FishingRemote: RemoteEvent = remotes:WaitForChild("FishingRemote")

local reelDebounce = false
local MAX_THROWING_DISTANCE = 150 -- studs
local Fishing = {}

bobberHandler.InitFishingModule(Fishing)

------ Module Variables ------

Fishing.LastUpdate = {
	IsFishing = false,
	Bobber = nil,
	lastClickPos = nil,
	InWaterTimer = nil,
	BobberReturning = false,
	FishingAnimationActive = false,
	EquippedTool = nil
}

local LastUpdate = Fishing.LastUpdate

function ResetLastUpdate()
	LastUpdate.IsFishing = false
	LastUpdate.lastClickPos = nil
	LastUpdate.InWaterTimer = nil
	LastUpdate.BobberReturning = false
	LastUpdate.EquippedTool = nil
	LastUpdate.FishingAnimationActive = false
end

function Fishing.CancelThrow(callEvent, died)
	if died then
		ResetLastUpdate()
		return
	end

	if not LastUpdate.IsFishing then
		return
	end
	
	ResetLastUpdate()
	
	if callEvent then
		FishingRemote:FireServer('Cancel')
	end
	
	animationService.Cancel(Fishing)
end

function Fishing.Throw()
	if LastUpdate.BobberReturning then 
		return
	elseif LastUpdate.IsFishing  then
		Fishing.CancelThrow(true)
	end
	
	local tool = localPlayer.Character:FindFirstChild("Tool")
	if LastUpdate.lastClickPos and tool then
		local tip = tool.Tip
		
		if (localPlayer.Character:GetPivot().Position - LastUpdate.lastClickPos).Magnitude > MAX_THROWING_DISTANCE then
			Fishing.CancelThrow(true)
			return
		end
			
		LastUpdate.IsFishing = true
		
		local data = {
			StartPosition = tip.Position,
			ClickPosition = LastUpdate.lastClickPos
		}
		
		FishingRemote:FireServer('Create', data)
	else
		Fishing.CancelThrow(true)
		animationService.Cancel(Fishing)
	end
end

function Fishing.Main()
	Fishing.CancelThrow(true)
	
	LastUpdate.EquippedTool = localPlayer:GetAttribute("Tool")
	LastUpdate.lastClickPos = bobberHandler.GetLocation()
	if LastUpdate.lastClickPos then
		local distance = funcLib.DistanceBetween(LastUpdate.lastClickPos, localPlayer.Character:GetPivot().Position)
		if distance > MAX_THROWING_DISTANCE then return end
	else
		return
	end
	
	localPlayer.Character:FindFirstChild("Main").CanCollide = false
	
	local toolAttribute = localPlayer:GetAttribute("Tool")
	if toolAttribute == "Fishing Rod" or toolAttribute == "Gold Fishing Rod" then	
		animationService.ThrowAnimation(localPlayer, Fishing)
	end		
end

function WaitForDelete()
	while task.wait() and LastUpdate.BobberReturning do end
end

function RetrieveFish()
	if reelDebounce then return end
	reelDebounce = true
	
	-- entry point for GUI probably
	local reelFish: RemoteFunction = remotes:WaitForChild("ReelFish")
	local result = reelFish:InvokeServer(Fishing.LastUpdate.lastClickPos)
	
	-- Will only show notification and GUI animation for fish
	if result.LootInfo.Type == "Fish" then
		uiAnimations.FishRetrievedAnimation(result)
		paths.Modules.Index.FishCaught(result, true)
		
	elseif result.LootInfo.Type == "Junk" then
		uiAnimations.JunkRetrievedAnimation(result)
		
	elseif result.LootInfo.Type == "Gem" then
		uiAnimations.GemsRetrievedAnimation(result)
	end
	
	FishingRemote:FireServer('Delete')
	
	WaitForDelete()
	LastUpdate.lastClickPos = nil
	LastUpdate.InWaterTimer = nil
	reelDebounce = false
end 

-- if fish has been in water for x seconds
function VerifyFishTimer()
	local debounce 
	if LastUpdate.EquippedTool and LastUpdate.EquippedTool == 'Gold Fishing Rod' then
		debounce = 1.5
	else
		debounce = 3
	end
	
	if LastUpdate.InWaterTimer and (os.clock() - LastUpdate.InWaterTimer > debounce) then
		RetrieveFish()
	end
end

function UpdateRopeLength()
	if LastUpdate.Bobber then
		local primary = LastUpdate.Bobber.PrimaryPart
		local rope: RopeConstraint = primary:WaitForChild("Rope")
		local tip = localPlayer.Character.Tool.Tip
		
		rope.Length = funcLib.DistanceBetween(primary.Position, tip.Position) * 1.15
	else
		LastUpdate.InWaterTimer = nil
	end
end

function IsPlayerMovingCancelFishing()
	if funcLib.PlayerIsMoving(localPlayer.Character) and LastUpdate.IsFishing and not LastUpdate.BobberReturning then
		Fishing.CancelThrow(true)
	elseif funcLib.PlayerIsMoving(localPlayer.Character) then
		localPlayer.Character:FindFirstChild("Main").CanCollide = true
	end
end

function GameLoop()
	poolHandler.Main()
	IsPlayerMovingCancelFishing()
	VerifyFishTimer()
end

InputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
		input.UserInputType == Enum.UserInputType.Touch or 
		input.KeyCode == Enum.KeyCode.ButtonR2) and 
		not funcLib.PlayerIsSwimming(paths.Player.Character) and localPlayer.Character:FindFirstChild("Tool") then
		if funcLib.CursorWithinFrame(localPlayer) then return end
		
		Fishing.Main()
	end
end)

InputService.JumpRequest:Connect(function()
	Fishing.CancelThrow(true)
end)


localPlayer.CharacterRemoving:Connect(function()
	Fishing.CancelThrow(true)
end)


RunService.RenderStepped:Connect(GameLoop)
return Fishing

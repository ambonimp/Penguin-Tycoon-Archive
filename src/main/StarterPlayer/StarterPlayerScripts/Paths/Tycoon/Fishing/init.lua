local paths = require(script.Parent.Parent)

local Fishing = {}

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
local uiAnimations = require(script.UIAnimations)


local AnimationService = require(script.AnimationService)
AnimationService.ConnectFishingModule(Fishing)


local funcLib = paths.Modules.FuncLib
local config = require(script.Config)
local poolHandler = require(script.PoolHandler)

local remotes = paths.Remotes
local FishingRemote: RemoteEvent = remotes:WaitForChild("FishingRemote")

local reelDebounce = false
local MAX_THROWING_DISTANCE = 150 -- studs
local totalEarned = {
	Money = 0,
	Gems = 0
}


bobberHandler.InitFishingModule(Fishing)

------ Module Variables ------

Fishing.LastUpdate = {
	isAFKFishing = false,
	IsFishing = false,
	Bobber = nil,
	lastClickPos = nil,
	InWaterTimer = nil,
	BobberReturning = false,
	FishingAnimationActive = false,
	RunningMain = false,
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

	AnimationService.Cancel()
end

function Fishing.Throw()
	if LastUpdate.BobberReturning then 
		LastUpdate.RunningMain = false
		return
	elseif LastUpdate.IsFishing then
		Fishing.CancelThrow(true)
	end
	
	local tool = localPlayer.Character:FindFirstChild("Tool")
	if LastUpdate.lastClickPos and tool and tool:FindFirstChild("Tip") then
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
		LastUpdate.RunningMain = false

	else
		LastUpdate.RunningMain = false
		Fishing.CancelThrow(true)
		AnimationService.Cancel(Fishing)
	end
end

function Fishing.Main()
	if LastUpdate.RunningMain then return end
	LastUpdate.RunningMain = true
	Fishing.CancelThrow(true)

	LastUpdate.EquippedTool = localPlayer:GetAttribute("Tool")
	LastUpdate.lastClickPos = bobberHandler.GetLocation()
	if LastUpdate.lastClickPos then
		local distance = funcLib.DistanceBetween(LastUpdate.lastClickPos, localPlayer.Character:GetPivot().Position)
		if distance > MAX_THROWING_DISTANCE then LastUpdate.RunningMain = false return end
	else
		LastUpdate.RunningMain = false
		return
	end
	
	localPlayer.Character:FindFirstChild("Main").CanCollide = false
	
	local toolAttribute = localPlayer:GetAttribute("Tool")
	if toolAttribute == "Fishing Rod" or toolAttribute == "Gold Fishing Rod" or toolAttribute == "Rainbow Fishing Rod" then	
		AnimationService.PlayThrow(LastUpdate.isAFKFishing)
	else
		LastUpdate.RunningMain = false
	end		
end

function WaitForDelete()
	while task.wait() and LastUpdate.BobberReturning do end
end

local SuffixList = { "", "K", "M", "B", "T", "Q" }

local function abbreviateNumber(value, idp)
	local exp = math.floor(math.log(math.max(1, math.abs(value)), 1000))
	local suffix = SuffixList[1 + exp] or ("e+" .. exp)
	local norm = math.floor(value * ((10 ^ idp) / (1000 ^ exp))) / (10 ^ idp)

	return ("%." .. idp .. "f%s"):format(norm, suffix)
end

function updateAFKText(money,gems)
	--You have earned <font color="#DADF22">XXXX Money</font> & <font color="#2C96FF">YYYY Gems</font>!
	local ui = paths.UI.Top.AFKFishing
	if money >= 1000 then
		ui.Amount.Text = "You have earned <font color=\"#DADF22\">$"..abbreviateNumber(money,2).."</font> & <font color=\"#2C96FF\">"..gems.." Gems</font>!"
	else
		ui.Amount.Text = "You have earned <font color=\"#DADF22\">$"..money.."</font> & <font color=\"#2C96FF\">"..gems.." Gems</font>!"
	end
end

function RetrieveFish()
	if reelDebounce then return end
	reelDebounce = true
	
	-- entry point for GUI probably
	local reelFish: RemoteFunction = remotes:WaitForChild("ReelFish")
	local result = reelFish:InvokeServer(Fishing.LastUpdate.lastClickPos,nil,Fishing.LastUpdate.isAFKFishing)
	-- Will only show notification and GUI animation for fish
	if result and game.Players.LocalPlayer:GetAttribute("ThreeFish") then
		for i, result in pairs (result) do
			if result and (result.LootInfo.Type == "Fish" or result.LootInfo.Type == "Junk") then
				totalEarned.Money += result.Worth
			elseif result and result.LootInfo.Type == "Gem" then
				totalEarned.Gems += result.LootInfo.Gems
			end
		end

		uiAnimations.TripleFish(result)
	else
		if result and result.LootInfo.Type == "Fish" then
			totalEarned.Money += result.Worth
			uiAnimations.FishRetrievedAnimation(result)
			paths.Modules.Index.FishCaught(result, true)
			
		elseif result and result.LootInfo.Type == "Junk" then
			totalEarned.Money += result.Worth
			uiAnimations.JunkRetrievedAnimation(result)
			paths.Modules.Index.FishCaught("Junk", result.LootInfo.Id)
		elseif result and result.LootInfo.Type == "Gem" then
			totalEarned.Gems += result.LootInfo.Gems
			uiAnimations.GemsRetrievedAnimation(result)
		end
	end
	
	FishingRemote:FireServer('Delete')

	if LastUpdate.isAFKFishing then
		updateAFKText(totalEarned.Money,totalEarned.Gems)
	end

	WaitForDelete()
	LastUpdate.lastClickPos = nil
	LastUpdate.InWaterTimer = nil
	LastUpdate.IsFishing = false
	LastUpdate.RunningMain = false
	
	reelDebounce = false
end 

-- if fish has been in water for x seconds
function VerifyFishTimer()
	local debounce 
	if LastUpdate.EquippedTool and (LastUpdate.EquippedTool == 'Gold Fishing Rod' or LastUpdate.EquippedTool == 'Rainbow Fishing Rod') then
		debounce = 1.5 / remotes.GetBonus:InvokeServer("Fishing","Speed")
	else
		debounce = 3 / remotes.GetBonus:InvokeServer("Fishing","Speed")
	end
	if LastUpdate.isAFKFishing then
		debounce = debounce * 1.5
	end
	--[[if Fishing.LastUpdate.isAFKFishing then
		if LastUpdate.EquippedTool and LastUpdate.EquippedTool == 'Gold Fishing Rod' then
			debounce = 10
		else
			debounce = 15
		end
	end]]
	if LastUpdate.InWaterTimer and (os.clock() - LastUpdate.InWaterTimer > debounce) and LastUpdate.IsFishing then
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
	if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character:FindFirstChild("Humanoid").SeatPart ~= nil and localPlayer.Character:FindFirstChild("Humanoid").SeatPart.Parent.Name == "Boat#1" then
		Fishing.LastUpdate.isAFKFishing = true
		if paths.UI.Top.AFKFishing.Visible == false then
			paths.UI.Top.AFKFishing.Visible = true
			localPlayer.Character.Humanoid.JumpPower = 0
			updateAFKText(0,0)
			remotes.AFKFishing:FireServer(true)
		end
		
		if Fishing.LastUpdate.IsFishing == false and not Fishing.LastUpdate.RunningMain then
			localPlayer:SetAttribute("AFKFishing",true)
			if localPlayer:GetAttribute("Tool") == "None" or localPlayer:GetAttribute("Tool") == "Glider" or localPlayer:GetAttribute("Tool") == "Powered Glider" then
				Fishing.LastUpdate.RunningMain = true
				if paths.UI.Tools:FindFirstChild("Rainbow Fishing Rod") then
					paths.Remotes.Tools:FireServer("Equip Tool", "Rainbow Fishing Rod")
				elseif paths.UI.Tools:FindFirstChild("Gold Fishing Rod") then
					paths.Remotes.Tools:FireServer("Equip Tool", "Gold Fishing Rod")
				else
					paths.Remotes.Tools:FireServer("Equip Tool", "Fishing Rod")
				end
				repeat task.wait() until (localPlayer:GetAttribute("Tool") ~= "None" and localPlayer:GetAttribute("Tool") ~= "Glider" and localPlayer:GetAttribute("Tool") ~= "Powered Glider") or Fishing.LastUpdate.isAFKFishing == false
				Fishing.LastUpdate.RunningMain = false
			end
			if Fishing.LastUpdate.isAFKFishing then
				task.wait(.5)
				if Fishing.LastUpdate.isAFKFishing then
					Fishing.Main()	
				end
			end
		end
	else
		localPlayer:SetAttribute("AFKFishing",false)
		if paths.UI.Top.AFKFishing.Visible ~= false then
			remotes.AFKFishing:FireServer(false)
		end
		totalEarned.Money = 0
		totalEarned.Gems = 0
		Fishing.LastUpdate.isAFKFishing = false
		if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
			localPlayer.Character.Humanoid.JumpPower = 60
		end
		paths.UI.Top.AFKFishing.Visible = false
	end

	
	poolHandler.Main()
	if Fishing.LastUpdate.isAFKFishing == false then
		IsPlayerMovingCancelFishing()
	end
	VerifyFishTimer()
end

InputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or Fishing.LastUpdate.isAFKFishing then return end
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
		input.UserInputType == Enum.UserInputType.Touch or 
		input.KeyCode == Enum.KeyCode.ButtonR2) and 
		not funcLib.PlayerIsSwimming(paths.Player.Character) and localPlayer.Character:FindFirstChild("Tool") then
		if funcLib.CursorWithinFrame(localPlayer) then return end
		if LastUpdate.IsFishing and input.UserInputType == Enum.UserInputType.Touch then
			return
		end
		Fishing.Main()
	end
end)

paths.UI.Top.AFKFishing.Exit.MouseButton1Down:Connect(function()
	if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
		paths.Audio.Celebration:Play()
		localPlayer.Character.Humanoid.Sit = false
		localPlayer.Character.Humanoid.JumpPower = 60
		paths.UI.Top.AFKFishing.Visible = false

		Fishing.CancelThrow(true)
		remotes.AFKFishing:FireServer(false)

	end
end)

localPlayer.Idled:Connect(function(time)
	local afk = 2*60
	if game.PlaceId == 7951464846 then
		afk = 19*60
	end
	if time > afk and LastUpdate.isAFKFishing then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,game.Players.LocalPlayer,nil,"AFKFishing")
	end
end)


InputService.JumpRequest:Connect(function()
	if not LastUpdate.isAFKFishing then
		Fishing.CancelThrow(true)
	end
end)


localPlayer.CharacterRemoving:Connect(function()
	Fishing.CancelThrow(true)
	remotes.AFKFishing:FireServer(false)
end)

remotes.FishRewards.OnClientEvent:Connect(function(rarity,reward)
	if reward == nil then
		paths.Modules.Setup:Notification("You were awarded with "..rarity.." for collecting 200 of it's kind!",Color3.new(.5,0.4,1),4.5)
	else
		paths.Modules.Setup:Notification("You were awarded with  <font color=\"rgb(62, 210, 255)\">"..reward.." gems</font> for catching all "..rarity.." fish!",Color3.new(.5,0.4,1),6.5)
	end
end)

RunService.RenderStepped:Connect(GameLoop)
return Fishing

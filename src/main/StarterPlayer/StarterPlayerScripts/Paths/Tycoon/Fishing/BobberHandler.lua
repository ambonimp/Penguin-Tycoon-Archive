local paths = require(script.Parent.Parent.Parent)


-- services
local RunService = game:GetService("RunService")
local InputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local camera = workspace.CurrentCamera

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local remotes = paths.Remotes
local FishingRemote: RemoteEvent = remotes:WaitForChild("FishingRemote")
local funcLib = paths.Modules.FuncLib
local config = paths.Modules.FishingConfig
local frameTime
local AnimationService = require(script.Parent.AnimationService)

-- fishing module
local fishingModule = nil

local localPlayer = game.Players.LocalPlayer

local CurrentBobberData = {}
local hasBobber = {}
local BobberHandler = {}

function BobberHandler.InitFishingModule(fishing)
	fishingModule = fishing
end

function BobberHandler.CreateBopper(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	local bpd = CurrentBobberData[player.UserId]
	if hasBobber[character] and os.time()-hasBobber[character] < 1 then 
		return 
	elseif bpd and hasBobber[character] and bpd.Bobber and os.time()-hasBobber[character] >= 1 then
		hasBobber[character] = nil
		bpd.Bobber:Destroy()
		bpd.Bobber = nil
	end
	if player and player:GetAttribute("Tool") == "Fishing Rod" or  player:GetAttribute("Tool") == "Gold Fishing Rod" or  player:GetAttribute("Tool") == "Rainbow Fishing Rod" then
		hasBobber[character] = os.time()
		local hrp = character:FindFirstChild("HumanoidRootPart")

		if not hrp:FindFirstChild("Attachment") then
			local attachment = Instance.new("Attachment")
			attachment.Position = Vector3.new(0, 2, 0)
			attachment.Name = "PlayerAttachment"
			attachment.Parent = hrp
		end
		if workspace.Bobbers:FindFirstChild(character.Name) then
			workspace.Bobbers:FindFirstChild(character.Name):Destroy()
		end
		local tool = character:WaitForChild("Tool")
		local tip = tool:FindFirstChild("Tip")
		if not tip then return false end
		
		local bobber = replicatedStorage.Bobber:Clone()
		bobber.Name = character.Name
		bobber.Parent = workspace.Bobbers
		bobber:PivotTo(CFrame.new(hrp.Position + Vector3.new(0, 7, 0)))
		bobber.PrimaryPart:FindFirstChild("Rope").Attachment1 = tip.Attachment
		
		return bobber
	end
	return nil
end

function BobberHandler.GetLocation()
	if fishingModule.LastUpdate.isAFKFishing then
		local ray = Ray.new((localPlayer.Character.PrimaryPart.CFrame*CFrame.new(0,0,-20)).Position, Vector3.new(0, -100, 0))
		local hit, position, normal, mat = workspace:FindPartOnRay(ray,localPlayer.Character)

		if mat and mat == Enum.Material.Water then
			return position
		end
	else
		local mousePos = InputService:GetMouseLocation()
		local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)	
	
		local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, raycastParams)
	
		if result and result.Material == Enum.Material.Water then
			return result.Position
		end
	end
end

function BobberHandler.MoveTo(startPos, bobber, lastPosition, isPlayer)
	local endPos = lastPosition
	local topPos = ((startPos + endPos) / 2) + Vector3.new(0, (startPos - endPos).Magnitude / 2, 0)
	

	for t = 0,1, 0.03 * frameTime do
		local TargetPosition = funcLib.QuadraticBezier(t , startPos, topPos, endPos)
		bobber:PivotTo(CFrame.new(TargetPosition))
		task.wait()
	end
	
	if isPlayer then
		fishingModule.LastUpdate.InWaterTimer = os.clock()
	end
end

function BobberHandler.MoveFrom(character, bobber, isPlayer)
	if isPlayer then
		fishingModule.LastUpdate.BobberReturning = true
		AnimationService.PlayCatch(localPlayer)
	end
	
	local hrp = character.HumanoidRootPart
	
	local startPos = bobber:GetPivot().Position
	local endPos = character.HumanoidRootPart.Position
	local topPos = ((startPos + endPos) / 2) + Vector3.new(0, (startPos - endPos).Magnitude / 2, 0)
	
	-- remove bobber collision
	bobber.PrimaryPart.CanCollide = false
	
	if frameTime < 1 then frameTime = 1 / remotes.GetBonus:InvokeServer("Fishing","Speed") end
	
	for t = 0,1, 0.06 * frameTime do
		local TargetPosition = funcLib.QuadraticBezier(t , startPos, topPos, endPos)
		bobber:PivotTo(CFrame.new(TargetPosition))
		task.wait()
	end
	
	if isPlayer then
		coroutine.wrap(function()
			fishingModule.LastUpdate.BobberReturning = false
			task.wait(0.15)
			AnimationService.Cancel(fishingModule)
		end)()
	end
end

function DestroyBobber(userId)
	if not CurrentBobberData[userId] or not CurrentBobberData[userId]["Bobber"] then return end
	
	CurrentBobberData[userId].Bobber:Destroy()
	local player = game.Players:GetPlayerByUserId(userId)
	if player and player.Character then
		hasBobber[player.Character] = nil
	end
	CurrentBobberData[userId] = {}
end

FishingRemote.OnClientEvent:Connect(function(player: Player, handlingType: string, data)
	
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
		--warn(string.format("You're too far away from %s to render the fishing animations.", player.Name))
		return 
	end
	
	local character = player.Character or player.CharacterAdded:Wait()
	local isPlayer = false
	
	if player.UserId == localPlayer.UserId then
		isPlayer = true	
	end
	
	if not CurrentBobberData[player.UserId] then
		CurrentBobberData[player.UserId] = {}
	end
	
	local bpd = CurrentBobberData[player.UserId]
	
	if handlingType == 'Create' then
		if hasBobber[character] and bpd.Bobber and os.time()-hasBobber[character] >= 1 then
			hasBobber[character] = nil
			bpd.Bobber:Destroy()
			bpd.Bobber = nil
		end
		bpd['Bobber'] = BobberHandler.CreateBopper(character)
		
		if not bpd['Bobber'] then return end
		
		BobberHandler.MoveTo(data.StartPosition, bpd.Bobber, data.ClickPosition, isPlayer)
	elseif handlingType == 'Delete' and bpd.Bobber then
		BobberHandler.MoveFrom(character, bpd.Bobber, isPlayer)		
		if typeof(bpd.Bobber) == "Instance" then
			bpd.Bobber:Destroy()
			bpd.Bobber = nil
			if character then
				hasBobber[character] = nil
			end
		end
	elseif handlingType == 'Cancel' and bpd.Bobber then
		if typeof(bpd.Bobber) == "Instance" then
			bpd.Bobber:Destroy()
			bpd.Bobber = nil
			if character then
				hasBobber[character] = nil
			end
		end
	end
end)


local runService = game:GetService("RunService")

function UpdateRopeLength()
	for userId, data in pairs(CurrentBobberData) do
		if not data.Bobber then 
			if userId == localPlayer.UserId then
				fishingModule.LastUpdate.InWaterTimer = nil
			end
			continue 
		end
		local player = game.Players:GetPlayerByUserId(userId)
		
		if not player or not player.Character then 
			CurrentBobberData[userId] = nil
			continue
		end
				
		if data.Bobber then
			local pPart = data.Bobber.PrimaryPart
			
			local rope: RopeConstraint = pPart:FindFirstChild("Rope")		
			local tool = player.Character:FindFirstChild("Tool")

			if not tool or not rope then
				DestroyBobber(CurrentBobberData[userId])
				continue
			end
			
			rope.Length = (funcLib.DistanceBetween(pPart.Position, tool.Tip.Position) * 1.05) + 7
		else
			DestroyBobber(CurrentBobberData[userId])
			continue
		end
	end
end


RunService.RenderStepped:Connect(function(step)
	frameTime = step * 60
	UpdateRopeLength()
end)


return BobberHandler


-- update button UI prices
function format(n)
	local formatted = n
	local k

	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end

	return formatted
end
for i, v in pairs(workspace.Template.Buttons:GetChildren()) do 
	local Info = v.InfoPart.Info 
	Info.Price.Text = "$ "..format(v:GetAttribute("Price"))
	Info.ItemName.Text = string.split(v:GetAttribute("Object"), "#")[1] 
	
	if v:GetAttribute("CurrencyType") == "Robux" then
		Info.Price.Text = "ROBUX"
	end
end


-- get total tycoon income and cost
local x = 0 
local y = 0 
for i, v in pairs(workspace.Template.Buttons:GetChildren()) do 
	x+=v:GetAttribute("Income") 
	y+= v:GetAttribute("Price") 
end 
print(x,y)


-- Add Attachments (HatAttachment, EyesAttachment) TO PENGUIN
for i, v in pairs(workspace.Template.Upgrades:GetChildren()) do
	for i, Penguin in pairs(v:GetChildren()) do
		if Penguin:GetAttribute("Type") then
			if Penguin:GetAttribute("Type") == "Penguin" then
				if Penguin.Main:FindFirstChildOfClass("Attachment") then
					Penguin.Main:FindFirstChildOfClass("Attachment"):Destroy()
				end
				
				local Attachment = Instance.new("Attachment", Penguin.Main)
				Attachment.Name = "HatAttachment"
				local YPos = Penguin.Main.Size.Y/2 - 0.03
				Attachment.Position = Vector3.new(0, YPos, -0.393)
				
				
				
				if Penguin.Main:FindFirstChild("EyesAttachment") then
					Penguin.Main:FindFirstChild("EyesAttachment"):Destroy()
				end

				local Attachment = Instance.new("Attachment", Penguin.Main)
				Attachment.Name = "EyesAttachment"
				local YPos = Penguin.Main.Size.Y/2 * 0.618
				local ZPos = -Penguin.Main.Size.Z/2 * 0.91
				Attachment.Position = Vector3.new(0, YPos, ZPos)
			end
		end
	end
end




-- add accessory to penguin
local penguin = workspace.Penguin
local itemtype = "Accessory"
local item = "Detective's Hat"
local model = game.ServerStorage.Accessories[item]:Clone()
model.Name = "Customization_"..itemtype
penguin.Humanoid:AddAccessory(model)



-- make new cameraangle part for penguin
local p = Instance.new("Part", workspace)
p.Anchored = true
p.CanCollide = false
p.CanTouch = false
p.Transparency = 1
p.CFrame = workspace.CurrentCamera.CFrame
p.Name = "CameraAngle"


-- change penguin plates to blue
for i, v in pairs(workspace.Template.Buttons:GetChildren()) do 
	if v:GetAttribute("Type") == "Penguin" then 
		v.InfoPart.Attachment.ParticleEmitter.Color = ColorSequence.new(
			{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(51, 148, 209)), 
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110, 179, 209)), 
				ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 148, 209))
			})

		for i, v in pairs(v:GetChildren()) do 
			if v.Name == "Part" then 
				v.Color = Color3.fromRGB(51, 148, 209)
			end
		end

		v.InfoPart.Info.CostBG.BackgroundColor3 = Color3.fromRGB(53, 141, 207)
		v.InfoPart.Info.Price.TextColor3 = Color3.fromRGB(53, 141, 207) 
	end 
end


-- change robux plates to orange
for i, v in pairs(workspace.Template.Buttons:GetChildren()) do 
	if v:GetAttribute("Type") == "Robux" then 
		v.InfoPart.Attachment.ParticleEmitter.Color = ColorSequence.new(
			{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 128, 38)), 
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 128, 38)), 
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 128, 38))
			})

		for i, v in pairs(v:GetChildren()) do 
			if v.Name == "Part" then 
				v.Color = Color3.fromRGB(218, 150, 23)
			end
		end

		v.InfoPart.Info.CostBG.BackgroundColor3 = Color3.fromRGB(218, 150, 23)
		v.InfoPart.Info.Price.TextColor3 = Color3.fromRGB(218, 150, 23) 
	end 
end



-- add info UI part to penguins 
for i, penguin in pairs(workspace.Template.Upgrades:GetDescendants()) do
	if penguin:GetAttribute("Type") and (penguin:FindFirstChild("Humanoid") or penguin:FindFirstChild("AnimationController")) and not penguin:FindFirstChild("Info") then
		print(penguin)
		local info = workspace.Info:Clone()
		info.PenguinInfo.PenguinName.Text = string.split(penguin.Name, "#")[1]
		info.CFrame = penguin.Main.CFrame
		info.MainPart.Part0 = info
		info.MainPart.Part1 = penguin.Main
		info.Parent = penguin
	end
end

--- add penguin price and income attributes
for i, v in pairs(workspace.Template.Buttons:GetChildren()) do
	if v:GetAttribute("Type") then
		if v:GetAttribute("Type") == "Penguin" then
			if workspace.Template.Upgrades:FindFirstChild(v:GetAttribute("Island")) then
				workspace.Template.Upgrades[v:GetAttribute("Island")][v.Name]:SetAttribute("Price", v:GetAttribute("Price"))
				workspace.Template.Upgrades[v:GetAttribute("Island")][v.Name]:SetAttribute("Income", v:GetAttribute("Income"))
			end
		end
	end
end




--- Check penguin size diff
local penguins = 0
local sum = 0 
local max = 0 
local min = 1000 
for i, v in pairs(workspace.Template.Upgrades:GetDescendants()) do 
	if v:GetAttribute("Type") and v:GetAttribute("Type") == "Penguin" then 
		sum += v.Main.Size.Y
		penguins += 1
		if v.Main.Size.Y > max then 
			max = v.Main.Size.Y
		end 
		if v.Main.Size.Y < min then 
			min = v.Main.Size.Y 
		end 
		
		if v.Main.Size.Y > 5.6 then
			print(v)
		end
	end 
end 
print(max, min)
print("average:", sum/penguins)









--old pet code


--[[
--only move pet if player is moving
if Pet[2] and Pet[2].Humanoid.MoveDirection.Magnitude > 0 and (spawnPos5.Material) ~= Enum.Material.Water and (spawnPos5.Material) ~= Enum.Material.Sand and (spawnPos5.Material) ~= Enum.Material.Air and (spawnPos5.Material) ~= nil  then
	Pet[13] = CFrame.new()
	if LastPetStats[Character] then
		if PetModel and PetModel.PrimaryPart and LastPetStats[Character] and (LastPetStats[Character].Position-Character.PrimaryPart.Position).magnitude > 0 then
			LastPetStats[Character].Position = Character.PrimaryPart.Position
			
			--set pet states
			PetModel:SetAttribute("State","Walk")
			PetModel:SetAttribute("Status","Moving")
			
			--create path from pet to player
			local path = PathfindingService:CreatePath({
				AgentRadius = math.max(PetModel.PrimaryPart.Size.X,PetModel.PrimaryPart.Size.Y,PetModel.PrimaryPart.Size.Z),
				AgentHeight = PetModel.PrimaryPart.Size.Y,
				AgentCanJump = true,
				WaypointSpacing = 15,
			})
			local spawnPos = getSpawnPosition(Character,-2) --get position behind player
			local doTp = false
			if spawnPos then
				Pet[11]:Stop()
				path:ComputeAsync(PetModel.PrimaryPart.Position, spawnPos.Position)
				local lastPoint = nil
				if path.Status == Enum.PathStatus.Success then --path exists, go through waypoints
					local waypoints = path:GetWaypoints()
					for i = 1,#waypoints do
						local ray = Ray.new(Character.Torso.Position, (Character.Torso.CFrame*CFrame.new(0,100,0)):vectorToWorldSpace(Vector3.new(0, -200, 0)) )
						local hit, position, normal, material = workspace:FindPartOnRay(ray,Character)
						if material == Enum.Material.Water then
							break
						end
						--cancel movement if pet is close enough or player moves far (4.5 studs) from position
						if PetModel == nil or PetModel.PrimaryPart == nil or LastPetStats[Character] == nil or (LastPetStats[Character].Position-Character.PrimaryPart.Position).magnitude > 4.5 or (PetModel.PrimaryPart.Position-Character.PrimaryPart.Position).magnitude < 7 then 
							break
						end
						--tween part smoothly to position
						local pos = waypoints[i].Position
						local tween = TweenService:Create(Pet[3],PartTweenInfo,{
							CFrame = CFrame.new(Vector3.new(pos.X,height,pos.Z),Vector3.new(Character.PrimaryPart.Position.X,height,Character.PrimaryPart.Position.Z))
						})
						tween:Play()
						local w = 0
						if waypoints[i].Action == Enum.PathWaypointAction.Jump and Pet[6].IsPlaying == false then
							Pet[6]:Play()
						end
						repeat w = w + RunService.RenderStepped:wait() until w > .01 or PetModel == nil or PetModel.PrimaryPart == nil or LastPetStats[Character] == nil or (LastPetStats[Character].Position-Character.PrimaryPart.Position).magnitude > 3 or (PetModel.PrimaryPart.Position-Character.PrimaryPart.Position).magnitude < 7 
					end	
				else
					-- path didn't exist, tp pet
					doTp = true
				end 
			end
			if doTp then
				local height = (spawnPos5.Position.Y  + PetModel:GetExtentsSize().Y/2) 
				Pet[3].CFrame = CFrame.new(Vector3.new(spawnPos5.Position.X ,height,spawnPos5.Position.Z),Vector3.new(Character.PrimaryPart.Position.X,height,Character.PrimaryPart.Position.Z))
				PetModel:SetPrimaryPartCFrame(Pet[3].CFrame)
			end
			if Pet[2] and Pet[2].Humanoid.MoveDirection.Magnitude == 0 then
				PetModel:SetAttribute("State","Idle")
				PetModel:SetAttribute("Status","Idling")
			end
		end
	else
		LastPetStats[Character] = {
			Position = Character.PrimaryPart.Position
		}
	end
end]]
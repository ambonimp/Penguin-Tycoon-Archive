
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
	
	if v:GetAttribute("Type") then
		if v:GetAttribute("Type") == "Robux" then
			Info.Price.Text = "R$ "..format(v:GetAttribute("Price"))
		end
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


-- Add HatAttachment TO PENGUIN
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
			end
		end
	end
end


-- add accessory to penguin
local penguin = workspace.Template.Upgrades.Island9["Gardener#1"]
local accessory = game.ServerStorage.Accessories["Gardening Hat"]
penguin.Humanoid:AddAccessory(accessory:Clone())



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
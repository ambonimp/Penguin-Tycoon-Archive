local Placement = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


--- Purchasing Animation ---
function Placement:MoveModel(Model, Pos, Rotation)
	local x, y, z = Model:GetPivot():ToOrientation()
	local TycoonRotation = CFrame.Angles(x, y, z)-- + math.rad(Rotation), z)

	local NewCFrame = CFrame.new(Pos) * TycoonRotation
		
	Model:PivotTo(NewCFrame)
end

function Placement:LoadExtra(Player,Model)
	local PlayerTycoon = Modules.Ownership:GetPlayerTycoon(Player)
	local CenterPos = Paths.Template.Center.Position
	local ModelPos = Model:GetPivot().p
	local DiffPos = ModelPos - CenterPos
	
	local TycoonPos = PlayerTycoon.Center.Position
	local RelativePos = TycoonPos + DiffPos
	
	-- Get tycoon rotation
	local Rotation = PlayerTycoon.Center.Orientation.Y
	
	Placement:MoveModel(Model, RelativePos, Rotation)

	Model.Parent = PlayerTycoon
end


function Placement:GetRelativePos(Tycoon, Item, IsButton)
	local Tycoon = workspace.Tycoons:FindFirstChild(Tycoon)
	if not Tycoon then return end
	
	local Button = Paths.Template.Buttons:FindFirstChild(Item)
	if Item == "Sailboat#1" then
		Button = Paths.Template.Buttons:FindFirstChild("Dock#2")
	elseif Item == "Plane#1" then
		Button = Paths.Template.Buttons:FindFirstChild("Hot Springs#1")
	elseif Item == "Rocketship#1" then
		Button = Paths.Template.Buttons:FindFirstChild("New Island!#12")
	end

	if not Button then return end
	
	local Model 
	
	if IsButton then
		Model = Button
	else
		local Island = Button:GetAttribute("Island")
		Model = Paths.Template.Upgrades[Island][Item]
		if not Model then return end
	end
	
	-- Get difference from center to the item
	local CenterPos = Paths.Template.Center.Position
	if Button:GetAttribute("World") == 2 or Model:GetAttribute("World") == 2  then
		CenterPos = Paths.Template.World2Center.Position
	end
	
	local ModelPos = Model:GetPivot().p
	local DiffPos = ModelPos - CenterPos
	
	local TycoonPos = Tycoon.Center.Position
	if Button:GetAttribute("World") == 2 or Model:GetAttribute("World") == 2  then
		TycoonPos = Tycoon.World2Center.Position
	end
	local RelativePos = TycoonPos + DiffPos
	
	-- Get tycoon rotation
	local Rotation = Tycoon.Center.Orientation.Y
	if Button:GetAttribute("World") == 2 or Model:GetAttribute("World") == 2  then
		Rotation = Tycoon.World2Center.Orientation.Y
	end
	return RelativePos, Rotation
end


function Placement:NewItem(Player, Item, IsAnimated)
	-- Variables
	local Button = Paths.Template.Buttons:FindFirstChild(Item)
	if Item == "Sailboat#1" then
		Button = Paths.Template.Buttons:FindFirstChild("Dock#2")
	elseif Item == "Plane#1" then
		Button = Paths.Template.Buttons:FindFirstChild("Hot Springs#1")
	elseif Item == "Rocketship#1" then
		Button = Paths.Template.Buttons:FindFirstChild("New Island!#12")
	end

	if not Button then return end
	
	local Island = Button:GetAttribute("Island")
	local Island = Paths.Template.Upgrades:FindFirstChild(Island)
	if not Island then print("Island name possibly incorrect for: ", Island, "Item is:", Item, "Player:", Player) return end
	
	local Model = Island:FindFirstChild(Item)
	if not Model then print("Item name possibly incorrect for: ", Item, " - On island: ", Island) return end

	local PlayerTycoon = Modules.Ownership:GetPlayerTycoon(Player)
	
	if PlayerTycoon.Tycoon:FindFirstChild(Item) then return end
	
	local Model = Model:Clone()
	Model.Parent = PlayerTycoon.Tycoon

	-- Turn it invisible for the animation before it gets placed
	if IsAnimated and not (Model:FindFirstChild("Humanoid") or Model:FindFirstChild("AnimationController")) then
		for i, v in pairs(Model:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency += 1
			end
		end
	end

	-- Place model into place
	local Position, Rotation = self:GetRelativePos(Player:GetAttribute("Tycoon"), Item)
	self:MoveModel(Model, Position, Rotation)
	
	-- Loading Penguins
	local Data = Modules.PlayerData.sessionData[Player.Name]
	local ItemType = Model:GetAttribute("Type")
	
	if Data and ItemType then
		if ItemType == "Penguin" then
			Modules.Penguins:LoadPenguin(Model, Data["Penguins"][Model.Name])
		elseif ItemType == "Vehicle" then
			Modules.Vehicles:SetupVehicleButton(Player, Model)
		elseif ItemType == "Leaderboard" then
			Modules.Leaderboards:LeaderboardAdded(Model)
		elseif ItemType == "Tool" and Model:GetAttribute("Tool") then
			Modules.Tools.AddTool(Player, Model:GetAttribute("Tool"))
		end
	end
	-- Play animation, if applicapble
	if IsAnimated and not (Model:FindFirstChild("Humanoid") or Model:FindFirstChild("AnimationController")) then
		self:AnimateIn(Model)
	end
	task.defer(function()
		if Item == "Dock#2" then
			Modules.Vehicles:SetUpSailboatBuild(Player)
		elseif Item == "Hot Springs#1" then
			Modules.Vehicles:SetUpPlaneBuild(Player)
		elseif Item == "New Island!#12" then
			Modules.Rocket.Load(Player)
		end
	end)


	if Button:GetAttribute("Woodcutting") then
		Modules.Tools.ToolFunctions.Axe.LoadPlayer(Player)
	end
end


--- Animations ---
local AnimateInInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local AnimateOutInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

function Placement:AnimateIn(Model)
	if Model:FindFirstChild("Humanoid") or Model:FindFirstChild("AnimationController") then return end
	
	for i, v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			local PreviousProperties = {CanCollide = v.CanCollide, Color = v.Color}
			v.CanCollide = false
			v.Size = v.Size * 2
			v.Color = Color3.fromRGB(255, 255, 255)

			local TweenGoal = {Size = v.Size / 2, Transparency = v.Transparency - 1, Color = PreviousProperties.Color}
			local Tween = Services.TweenService:Create(v, AnimateInInfo, TweenGoal)

			Tween:Play()
			
			Tween.Completed:Connect(function()
				v.CanCollide = PreviousProperties.CanCollide
			end)
		end
	end
end


function Placement:AnimateOut(Model)
	for i, v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			local PreviousProperties = {Color = v.Color}
			v.CanCollide = false

			local TweenGoal = {Size = Vector3.new(v.Size.X * 6, v.Size.Y * 1.2, v.Size.Z * 1.2), Transparency = v.Transparency + 1}
			local Tween = Services.TweenService:Create(v, AnimateOutInfo, TweenGoal)

			Tween:Play()

			--Tween.Completed:Connect(function()
			--	print(7)
			--	Model:Destroy()
			--end)
		end
	end
	
	coroutine.wrap(function()
		task.wait(0.3)
		Model:Destroy()
	end)()
end


return Placement
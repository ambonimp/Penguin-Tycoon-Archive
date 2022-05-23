--Handles all things pets on client
local Pets = {}
local MarketplaceService = game:GetService("MarketplaceService")
local Paths = require(script.Parent)
local ScriptModules = Paths.Modules
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local PetsFolder = workspace:WaitForChild("Pets")
local PetsAssets = Assets:WaitForChild("Pets")
local PetDetails = require(Modules:WaitForChild("PetDetails"))
local PetModels = {}
local LastPetStats = {}
local DidAdd = {}

local PetUI = require(script:WaitForChild("PetUI"))
local PartTweenInfo = TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.In)

local isAdopting = false

local testing = false

local RenderDistance = 1000 --distance in studs to render movement of other players pets
local radius = 3
local fullCircle = 2 * math.pi

function newPart(cframe)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.Transparency = .5
	p.Size = Vector3.new(.1,.1,.1)
	p.CFrame = cframe 
	p.Parent = workspace
end

function resizeModel(model, a)
	local base = model.PrimaryPart
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Position = base.Position:Lerp(part.Position, a)
			part.Size *= a
			if part:FindFirstChildOfClass("SpecialMesh") then
				part:FindFirstChildOfClass("SpecialMesh").Scale *= a
			end
		end
	end
end

function tweenModelSize(model, duration, factor, easingStyle, easingDirection)
	local s = factor - 1
	local i = 0
	local oldAlpha = 0
	while i < 1 do
		local dt = RunService.Heartbeat:Wait()
		i = math.min(i + dt/duration, 1)
		local alpha = TweenService:GetValue(i, easingStyle, easingDirection)
		resizeModel(model, (alpha*s + 1)/(oldAlpha*s + 1))
		oldAlpha = alpha
	end
end

function getBone(Part,BoneName)
	for i,v in pairs (Part:GetDescendants()) do
		if v:IsA("Bone") and string.lower(v.Name) == string.lower(BoneName) then
			return v
		end
	end
	return nil
end

--Raycast behind player to find spawn position of pet
function getSpawnPosition(Character,distance,dist2) 
	local rayOrigin
	if type(Character) == "userdata" and Character.PrimaryPart == nil then
		repeat RunService.RenderStepped:wait() until Character.PrimaryPart --i hate having to do this
	end
	local ignore = {workspace.Pets}
	for i,v in pairs (game.Players:GetPlayers()) do
		if v.Character then
			table.insert(ignore,v)
		end
	end
	if type(Character) == "userdata" then
		local cf = Character:GetPrimaryPartCFrame() * CFrame.new(dist2 or 4,0,distance)
		rayOrigin = cf.Position
	elseif type(Character) == "vector" then
		rayOrigin = Character
	end
	
	local rayDirection = Vector3.new(0, -1000, 0)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignore
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if testing and raycastResult then
		newPart(CFrame.new(raycastResult.Position))
	end
	return raycastResult
end

local function IsBehind(Part1,Part2)
	local point1,point2 = (Part1.CFrame + Part1.CFrame.LookVector),(Part1.CFrame + Part1.CFrame.LookVector*-1)
	local mag1,mag2 = (point1.Position-Part2.Position).Magnitude,(point2.Position-Part2.Position).Magnitude
	return not (mag1 <= mag2)
end


--Handles pet removing and equipping 
function Pets.addPetToPlayer(Player)
	if DidAdd[Player] then return end
	DidAdd[Player] = true
	if Player.Character == nil then
		repeat RunService.RenderStepped:wait() until Player.Character --i hate having to do this
	end
	local Character = Player.Character
	local Pet = nil -- Pet[1] pet model, Pet[2] owner character Pet[3] tracking part Pet[4] - [6] pet walk, idle anim
	local CurrentSpawn = 0
	local Feeding = false
	local Throwing = false
	--remove unneccessary pets from client processing
	local function removePet()
		if Pet then
			if Pet[1] then
				Pet[1]:Destroy()
			end
			if Pet[3] then
				Pet[3]:Destroy()
			end
			if Pet[9] then
				Pet[9]:Disconnect()
			end
			if Pet[7] then
				Pet[7]:Destroy()
			end
			if Pet[8] then
				Pet[8]:Destroy()
			end
			if Pet[18] then
				Pet[18]:Disconnect()
			end
			pcall(function()
				PetUI.CleanConnections()
			end)
			RunService:UnbindFromRenderStep("PetInteractUI")
			if table.find(PetModels,Pet) then
				table.remove(PetModels,table.find(PetModels,Pet))
			end
		end
	end
	
	local function sitPet()
		Pet[12]:Play(.25)
		task.wait(Pet[12].Length*.75)
		Pet[12]:AdjustSpeed(0)
	end
	
	local function playerInBoat()
		if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.SeatPart and (string.find(string.lower(Character.Humanoid.SeatPart.Parent.Name),"boat") or string.find(string.lower(Character.Humanoid.SeatPart.Parent.Name),"raft")) then
			Character:SetAttribute("InBoat",false)
			return true
		elseif Character and Character:FindFirstChild("Humanoid") then
			local result = getSpawnPosition(Character,0,0)
			if result and result.Instance then
				local name = result.Instance.Parent.Name
				local name2 = result.Instance.Parent.Parent.Name
				Character:SetAttribute("InBoat",true)
				if (string.find(string.lower(name),"boat") or string.find(string.lower(name),"raft")) or (string.find(string.lower(name2),"boat") or string.find(string.lower(name2),"raft")) then
					return true	
				end
			end
		end
		Character:SetAttribute("InBoat",false)
		return false
	end
	
	local function resetPetAnimation()
		spawn(function()
			repeat 
				ReplicatedStorage.Remotes.ResetPetAnimation:FireServer()
				wait(.75)
			until game.Players.LocalPlayer.Character == nil or game.Players.LocalPlayer.Character:GetAttribute("PetAnimation") == "none"
			Pet[1]:SetAttribute("State","Idle")
			Pet[1]:SetAttribute("Status","Idling")
		end)
	end
	
	--handles penguin throw animation and moving pet to object thrown
	local function ThrowFunction(toy,amount)
		if Pet then
			if Throwing then return end
			local t=  tick()
			Throwing = true
			if Pet[12].IsPlaying then
				Pet[12]:Stop()
			end
			local Pet = Pet
			local HeadBone = getBone(Pet[1].PrimaryPart,"Mouth")
			local headCF = Pet[14].CatchCFrame
			local throwAnim = ReplicatedStorage.Animations.ThrowToy
			local loadedAnim = Player.Character.Humanoid.Animator:LoadAnimation(throwAnim)
			local model = Assets.Toys:FindFirstChild(toy):Clone()
			for i,v in pairs (model:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
			local throw = Instance.new("Sound")
			throw.RollOffMaxDistance = 35
			throw.RollOffMinDistance = 10
			throw.SoundId = "rbxassetid://9221813109"
			throw.Parent = model.PrimaryPart
			throw.Volume = .5
			model:SetPrimaryPartCFrame(Player.Character["Arm L"].CFrame*CFrame.new(-.5,-1.75,0))
			model.Parent = workspace.Pets
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = Player.Character["Arm L"]
			weld.Part1 = model.PrimaryPart
			weld.Parent = model.PrimaryPart
			local con
			con = loadedAnim:GetMarkerReachedSignal("THROW"):Connect(function()
				local s,m = pcall(function()
					weld:Destroy()
					if IsBehind(Character.PrimaryPart,Pet[3]) then
						model.PrimaryPart.Velocity = (Character.PrimaryPart.CFrame).LookVector * math.random(15,40)
					else
						local t = 1
						local g = Vector3.new(0, -game.Workspace.Gravity, 0);
						local x0 = model.PrimaryPart.CFrame
						local p =(Character.PrimaryPart.CFrame*CFrame.new(math.random(-10,10),0,math.random(-20,-14))).Position
						local v0 = (p - x0.Position - .2*g*t*t)/t;
						
						model.PrimaryPart.Velocity = v0 
						
					end
					throw:Play()
					for i,v in pairs (model:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = true
						end
					end
					wait(1)
					model.PrimaryPart.Anchored = true
					for i,v in pairs (model:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end
					local ray = Ray.new(Character.PrimaryPart.Position, Character.PrimaryPart.CFrame:vectorToWorldSpace(Vector3.new(0, -100, 0)) )
					local hit, position, normal, getPos = workspace:FindPartOnRay(ray,Character)
					if getPos == nil or (getPos) == Enum.Material.Water or (getPos) == Enum.Material.Sand or (getPos) == Enum.Material.Air or (getPos) == nil  then
						wait(2)
						resetPetAnimation()
						model:Destroy()
						con:Disconnect()
						return
					end
					Pet[5]:Stop(.25)
					Pet[4]:Play()
					local lastPoint = nil
					local ypos = Pet[3].Position.Y
					
					if (Pet[3].Position-Character.PrimaryPart.Position).magnitude < 8 and IsBehind(Character.PrimaryPart,Pet[3]) then
						local neg = math.random(1,2) == 1 and -1 or 1
						local pos = (Character.PrimaryPart.CFrame*CFrame.new(math.random(3,7)*neg,0,0))
						local tween = TweenService:Create(Pet[3],TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{
							CFrame = CFrame.new(Pet[3].Position,Vector3.new(pos.X,ypos,pos.Z)) --* CFrame.new(0,0,-2)
						})
						tween:Play()
						wait(.15)
						pos = Vector3.new(pos.X,ypos,pos.Z)
						local rotation = Pet[3].CFrame - Pet[3].Position
						local tween = TweenService:Create(Pet[3],TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{
							CFrame = CFrame.new(pos)* rotation
						})
						tween:Play()
						wait(.4)
					end
					local tween = TweenService:Create(Pet[3],TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{
						CFrame = CFrame.new(Pet[3].Position,Vector3.new(model.PrimaryPart.Position.X,ypos,model.PrimaryPart.Position.Z)) --* CFrame.new(0,0,-2)
					})
					tween:Play()
					wait(.15)
					
					local pos = (model.PrimaryPart.CFrame*CFrame.new(0,0,-1)).Position
					pos = Vector3.new(pos.X,ypos,pos.Z)
					local rotation = Pet[3].CFrame - Pet[3].Position
					local tween = TweenService:Create(Pet[3],TweenInfo.new(1.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{
						CFrame = CFrame.new(pos) * rotation --* CFrame.new(0,0,-2)
					})
					tween:Play()
					wait(1.5)
					local att = Instance.new("Attachment")
					att.Parent = model.PrimaryPart
					local weld = Instance.new("RigidConstraint")
					weld.DestructionEnabled	= false
					weld.Attachment0 = HeadBone
					model.PrimaryPart.Anchored = false
					weld.Attachment1 = att
					weld.Parent = model.PrimaryPart
					model:SetPrimaryPartCFrame(HeadBone.TransformedWorldCFrame * headCF)
					local tween = TweenService:Create(Pet[3],TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{
						CFrame = CFrame.new(Pet[3].Position,Vector3.new(Character.PrimaryPart.Position.X,ypos,Character.PrimaryPart.Position.Z)) --* CFrame.new(0,0,-2)
					})
					tween:Play()
					wait(.15)
					RunService:BindToRenderStep("LookAtPlayer"..Player.Name,Enum.RenderPriority.Last.Value,function()
						local pos = getSpawnPosition(Character,-1.5).Position
						pos = Vector3.new(pos.X,ypos,pos.Z)
						local cfRot = CFrame.new(Pet[3].Position,Vector3.new(Character.PrimaryPart.Position.X,ypos,Character.PrimaryPart.Position.Z))-Pet[3].Position
						local tween = TweenService:Create(Pet[3],TweenInfo.new(.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{
							CFrame = CFrame.new(pos) * cfRot
						})
						tween:Play()
					end)
					wait(1.5)
					Pet[4]:Stop(.25)
					Pet[5]:Play(.25)
					RunService:UnbindFromRenderStep("LookAtPlayer"..Player.Name)
					wait(2)
					model:Destroy()
					if Player == game.Players.LocalPlayer then
						resetPetAnimation()
					end
					if Pet[2]:FindFirstChild("Humanoid") and Pet[2].Humanoid:GetState() == Enum.HumanoidStateType.Seated then
						sitPet()
					end
					Throwing = false
					con:Disconnect()
					Pet[1]:SetAttribute("State","Idle")
					Pet[1]:SetAttribute("Status","Idling")
				end)
				if s == false then
					warn(m)
					RunService:UnbindFromRenderStep("LookAtPlayer"..Player.Name)
					if model then
						model:Destroy()
					end
					if Player == game.Players.LocalPlayer then
						resetPetAnimation()
					end
					Throwing = false
					con:Disconnect()
					Pet[1]:SetAttribute("State","Idle")
					Pet[1]:SetAttribute("Status","Idling")
				end
			end)
			
			loadedAnim:Play()
		end
	end
	
	--handles penguin feed animation and hearts
	local function FeedFunction(food,amount)
		if Pet then
			if Feeding then return end
			Feeding = true
			if Pet[12].IsPlaying then
				Pet[12]:Stop()
			end
			local Pet = Pet
			local foodModel
			local heart
			local s,m = pcall(function()
				if Player == game.Players.LocalPlayer then
					local tween = TweenService:Create(Character.PrimaryPart,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
						CFrame = CFrame.new(Character.PrimaryPart.Position,Vector3.new(Pet[1].PrimaryPart.Position.X,Character.PrimaryPart.Position.Y,Pet[1].PrimaryPart.Position.Z))
					})
					tween:Play()
					local tween2 = TweenService:Create(Pet[3],TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
						CFrame = CFrame.new(Pet[3].Position,Vector3.new(Character.PrimaryPart.Position.X,Pet[3].Position.Y,Character.PrimaryPart.Position.Z))
					})
					tween2:Play()
					wait(.5)
					Paths.Modules.Emotes:PlayEmote(8210287558)
				end
				foodModel = Assets.Foods:FindFirstChild(food):Clone()
				local rot1 = math.random(-360,360)
				local rot2 = math.random(-360,360)
				local rot3 = math.random(-360,360)
				foodModel:SetPrimaryPartCFrame((Pet[1].PrimaryPart.CFrame*CFrame.Angles(math.rad(rot1),math.rad(rot2),math.rad(rot3)))+Vector3.new(0,3,0))
				local pos = foodModel:GetPrimaryPartCFrame()
				resizeModel(foodModel,.01)
				RunService:BindToRenderStep("foodRotate"..Player.Name,Enum.RenderPriority.Last.Value,function()
					rot1 += 1
					rot2 += 1
					rot3 += 1
					foodModel:SetPrimaryPartCFrame(pos*CFrame.Angles(math.rad(rot1),math.rad(rot2),math.rad(rot3)))
				end)

				foodModel.Parent = PetsFolder
				if Pet and Pet[3] then
					tweenModelSize(foodModel,.8,75,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out)
					local tween = TweenService:Create(foodModel.PrimaryPart,TweenInfo.new(1.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
						CFrame = Pet[3].CFrame
					})
					spawn(function()
						wait(.25)
						tweenModelSize(foodModel,.45,.01,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
						foodModel:Destroy()
						RunService:UnbindFromRenderStep("foodRotate"..Player.Name)
					end)

					if Pet and Pet[6] then
						tween:Play()
						Pet[6]:Play()
						Pet[16]["Eat"]:Play()
						heart = Assets.Hearts:Clone()
						heart.Size = Pet[1].PrimaryPart.Size
						heart.CFrame = Pet[1].PrimaryPart.CFrame
						heart.Parent = workspace.Pets
						wait(Pet[6].Length*.9)
						Pet[6]:Play()
						wait(Pet[6].Length*.9)
						heart:Destroy()
						if Player == game.Players.LocalPlayer then
							resetPetAnimation()
						end
						if Pet[2]:FindFirstChild("Humanoid") and Pet[2].Humanoid:GetState() == Enum.HumanoidStateType.Seated then
							sitPet()
						end
						Feeding = false
						Pet[1]:SetAttribute("State","Idle")
						Pet[1]:SetAttribute("Status","Idling")
					end
				end
			end)
			if s == false then
				warn(m)
				Feeding = false
				if Player == game.Players.LocalPlayer then
					resetPetAnimation()
				end
				if foodModel then
					foodModel:Destroy()
				end
				if heart then
					heart:Destroy()
				end
				Pet[1]:SetAttribute("State","Idle")
				Pet[1]:SetAttribute("Status","Idling")
			end
		end
	end
	
	local function NewPet()
		removePet()
		if Player:GetAttribute("Pet") and Player:GetAttribute("Pet") ~= "none" then --double check the player has a pet equipped. only changed by server
			Paths.UI.Center.Pets.Certificate.Visible = true
			local spawn_ = CurrentSpawn
			if Player ~= game.Players.LocalPlayer and not (Player and Player.Character and Player.Character.PrimaryPart and (Player.Character.PrimaryPart.Position-game.Players.LocalPlayer.Character.PrimaryPart.Position).magnitude < 100 ) then
				repeat wait(5) until (Player and Player.Character and Player.Character.PrimaryPart and (Player.Character.PrimaryPart.Position-game.Players.LocalPlayer.Character.PrimaryPart.Position).magnitude < 100) or spawn_ ~= CurrentSpawn 
			end
			if spawn_ ~= CurrentSpawn then return end
			local PetName = Player:GetAttribute("Pet")
			Pet = {PetsAssets:WaitForChild(PetName):Clone(),Character} -- [1] = pet model, [2] = character of player, [3] = part that follows player used to move the pet, [4] = walk anim, [5] = idle anim, [6] = jump anim
			local spawnPos = getSpawnPosition(Character,-1.5) 
			if spawnPos then
				if Player == game.Players.LocalPlayer then
					resetPetAnimation()
				end
				local pos = spawnPos.Position 
				local height = (pos.Y  + Pet[1]:GetExtentsSize().Y/2) * .8
				local headBone = getBone(Pet[1].PrimaryPart,"Mouth")
				
				local PetAttachment = Instance.new("Attachment",Pet[1].PrimaryPart)
				PetAttachment.Name = "PetAttachment"
				
				local newAlignPosition = Instance.new("AlignPosition",Pet[1].PrimaryPart)
				local newAlignOrientation = Instance.new("AlignOrientation",Pet[1].PrimaryPart)
				newAlignPosition.MaxForce = 100000
				newAlignPosition.Responsiveness = 25
				newAlignOrientation.MaxTorque = 10000
				newAlignOrientation.Responsiveness = 15
				
				newAlignPosition.Attachment0 = PetAttachment
				newAlignOrientation.Attachment0 = PetAttachment
				
				--Create part that follows player, used for moving the pet smoothly
				Pet[3] = Instance.new("Part")
				Pet[3].CanCollide = false
				Pet[3].Transparency = 1
				Pet[3].CFrame = CFrame.new(Vector3.new(pos.X ,height,pos.Z),Vector3.new(Character.PrimaryPart.Position.X,height,Character.PrimaryPart.Position.Z))
				Pet[1]:SetPrimaryPartCFrame(Pet[3].CFrame)
				Pet[3].Anchored = true
				local Attachment = Instance.new("Attachment")
				Attachment.Parent = Pet[3]
				
				Pet[3].Parent = PetsFolder
				Pet[1].Parent = PetsFolder
				
				Pet[1].PrimaryPart.AlignOrientation.Attachment1 = Attachment
				Pet[1].PrimaryPart.AlignPosition.Attachment1 = Attachment

				local petDetails = nil
				
				for petKind,details in pairs (PetDetails) do
					if string.find(PetName,petKind) then
						petDetails = details
						break
					end
				end
				Pet[15] = Player
				Pet[14] = petDetails
				Pet[13] = CFrame.Angles(0,0,0)
				
				--load pet animations
				Pet[12] = Pet[1].AnimationController:LoadAnimation(Pet[1].Animations.Sit)
				Pet[11] = Pet[1].AnimationController:LoadAnimation(Pet[1].Animations.Trick)
				Pet[4] = Pet[1].AnimationController:LoadAnimation(Pet[1].Animations.Walk)
				Pet[5] = Pet[1].AnimationController:LoadAnimation(Pet[1].Animations.Idle)
				Pet[6] = Pet[1].AnimationController:LoadAnimation(Pet[1].Animations.Jump)
				Pet[1]:SetAttribute("State","Idle")
				Pet[1]:SetAttribute("Status","Idling")
				
				if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid"):GetState() == Enum.HumanoidStateType.Seated then 
					spawn(function()
						sitPet()
					end)
				elseif Character and Character:FindFirstChild("Humanoid") then
					Pet[5]:Play()
				else
					removePet()
					return
				end
				
				
				Pet[9] =  Pet[6].DidLoop:Connect(function()
					Pet[6]:Stop(.25)
				end)
				
				--detect state changes and handle anim accordingly
				Pet[1]:GetAttributeChangedSignal("State"):Connect(function() 
					if Pet[1]:GetAttribute("State") == "Idle" then
						Pet[12]:Stop(.25)
						Pet[4]:Stop(.25)
						Pet[5]:Play(.25)
					elseif Pet[1]:GetAttribute("State") == "Walk" then
						Pet[12]:Stop(.25)
						Pet[5]:Stop(.25)
						Pet[4]:Play(.25)
					elseif Pet[1]:GetAttribute("State") == "Sit" then
						Pet[5]:Stop(.25)
						Pet[4]:Stop(.25)
						sitPet()
					end
				end)
				
				--jump with the player
				Pet[18] = Character.Humanoid:GetPropertyChangedSignal("Jump"):Connect(function() 
					local ray = Ray.new(Character.PrimaryPart.Position+Vector3.new(0,50,0), Character.PrimaryPart.CFrame:vectorToWorldSpace(Vector3.new(0, -100, 0)) )
					local hit, position, normal, material = workspace:FindPartOnRay(ray,Character)
					if material == Enum.Material.Water then
						return
					end
					if Pet[6].IsPlaying then return end
					Pet[6]:Play(.25)
				end)
				print("Do pet UI")
				--Handle Pet interaction UI
				local PetName = Dependency.Parent.PetUI.PetName:Clone()
				PetName.Parent = Paths.UI.Main.Parent
				PetName.Adornee = Pet[1].PrimaryPart
				PetName.PetName.Text = Player:GetAttribute("PetName")
				if Player == game:GetService("Players").LocalPlayer then
					local PetUI,PetClick = PetUI.StartInteractPetUI(Pet,Paths,ScriptModules,ThrowFunction,FeedFunction,sitPet,playerInBoat)
					
					Pet[7] = PetUI
					Pet[8] = PetClick
				end
				Pet[16] = {}
				for i,sound in pairs (Dependency.PetSounds:GetChildren()) do
					local new = sound:Clone()
					new.Parent = Pet[1].PrimaryPart
					Pet[16][sound.Name] = new
				end
				Pet[16].Trick.SoundId = Pet[14].TrickSound
				--[[local HeadBone = getBone(Pet[1].PrimaryPart,"Head")
				
				if HeadBone then
					print("added emote ui")
				end--]]
				local EmoteUI = Dependency.Parent.PetUI.Emote:Clone()
				EmoteUI.Parent = Pet[1].PrimaryPart
				EmoteUI.Adornee = Pet[1].PrimaryPart
				Pet[10] = EmoteUI
				print("end pet adding")
				table.insert(PetModels,Pet) --insert Pet table into PetModels, used in RenderStep to handle all players pets, locally
			else
				Paths.UI.Center.Pets.Certificate.Visible = false
			end
		end
	end
	
	local function PetAnimationChanged()
		if Character:GetAttribute("PetAnimation") ~= "none" then
			local split = string.split(Character:GetAttribute("PetAnimation"),"_")
			if split[1] == "Toy" then
				ThrowFunction(split[2],0)
			elseif split[1] == "Feed" then
				FeedFunction(split[2],0)
			end
		end
	end
	
	--Handles new character being added
	Player.CharacterAdded:Connect(function(NewChar)
		Character = NewChar
		CurrentSpawn = CurrentSpawn + 1
		NewPet()

		NewChar:WaitForChild("Humanoid").Died:Connect(function()
			removePet()
		end)
		if Player ~= game.Players.LocalPlayer then
			NewChar:GetAttributeChangedSignal("PetAnimation"):Connect(PetAnimationChanged)
		end
	end)
	
	Player:GetAttributeChangedSignal("PetID"):Connect(function()
		NewPet()
	end)
	
	Player:GetAttributeChangedSignal("PetTrick"):Connect(function()
		if Player ~= game.Players.LocalPlayer and Pet[11].IsPlaying == false then
			if Pet[12].IsPlaying then
				Pet[12]:Stop()
			end
			Pet[16].Trick:Play()
			Pet[13] = Pet[14].TrickCFrame
			Pet[5]:Stop(.15)
			Pet[11]:Play(.25)
			wait(Pet[11].Length*.95)
			Pet[11]:Stop(.25)
			Pet[5]:Play(.25)
			Pet[13] = CFrame.new()
			if Pet[2]:FindFirstChild("Humanoid") and Pet[2].Humanoid:GetState() == Enum.HumanoidStateType.Seated then
				sitPet()
			end
		end
	end)
	
	local changedNumber = 0
	local function changeHappinessIcon(Amount)
		if Pet[10] and Pet[10]:FindFirstChild("ImageLabel") then
			changedNumber = changedNumber + 1
			local number = changedNumber
			local icons = {
				[6] = {"rbxassetid://9184554398",90},
				[5] = {"rbxassetid://9184554810",70},
				[4] = {"rbxassetid://9184554646",50},
				[3] = {"rbxassetid://9184555092",30},
				[2] = {"rbxassetid://9184554961",15},
				[1] ={ "rbxassetid://9184555197",0},
			}
			local oldImage = Pet[10].ImageLabel.Image 
			for i = 1,6 do
				local v = icons[i]
				if Amount >= v[2] then
					Pet[10].ImageLabel.Image = v[1]
				end
			end
			if oldImage == Pet[10].ImageLabel.Image then
				return
			end
			Pet[10].ImageLabel.Visible = false
			Pet[10].ImageLabel.Size = UDim2.fromScale(0,0)
			Pet[10].ImageLabel.Visible = true
			Pet[10].ImageLabel:TweenSize(UDim2.fromScale(1,1),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,1,true)
			if changedNumber == number  then
				wait(2)
				Pet[10].ImageLabel:TweenSize(UDim2.fromScale(0,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,true)
				Pet[10].ImageLabel.Visible = false
				end
		end
	end
	
	Player:GetAttributeChangedSignal("PetHappiness"):Connect(function()
		if Player:GetAttribute("PetHappiness") and Pet and Pet[1] and Pet[10] then
			changeHappinessIcon(Player:GetAttribute("PetHappiness"))
		end
	end)
	
	Player.AncestryChanged:Connect(function() --detect when player leaves game
		if Player.Parent == nil then
			DidAdd[Player] = nil
			removePet()
		end
	end)
	
	Character:WaitForChild("Humanoid").Died:Connect(function()
		removePet()
	end)
	
	if Player ~= game.Players.LocalPlayer then
		Character:GetAttributeChangedSignal("PetAnimation"):Connect(PetAnimationChanged)
	end
	if Pet == nil then
		NewPet()
	end
	
	local lastTool = Player:GetAttribute("Tool")
	Player:GetAttributeChangedSignal("Tool"):Connect(function()
		if Player:GetAttribute("Tool") == "Glider" then
			removePet()
		elseif lastTool == "Glider" then
			NewPet()
		end
		lastTool = Player:GetAttribute("Tool")
	end)
end

local function getXAndZPositions(angle)
	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius
	return x, z
end

RunService:BindToRenderStep("PetHandling",Enum.RenderPriority.Character.Value,function(delta) --Handle all pets in the world
	for i,Pet in pairs (PetModels) do
		coroutine.wrap(function()
			local PetModel = Pet[1] 
			local Character = Pet[2]
			local waterUnder = false
			if Character then
				local ray = Ray.new(Character.PrimaryPart.Position, Character.PrimaryPart.CFrame:vectorToWorldSpace(Vector3.new(0, -100, 0)) )
				local hit, position, normal, material = workspace:FindPartOnRay(ray,Character)
				if material == Enum.Material.Water then
					waterUnder = true
				end
			end
			if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid").Health > 0 and (Character:FindFirstChild("Humanoid"):GetState() == Enum.HumanoidStateType.Swimming or waterUnder) then 
				PetModel:SetAttribute("State","Idle")
				PetModel:SetAttribute("Status","Idling")
			end
			if Pet[15] and Pet[15]:GetAttribute("Tool") ~= "Glider" and Character and Character:GetAttribute("PetAnimation") == "none" and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid").Health > 0 and Character:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Swimming and not waterUnder then
				--teleport pet if pet is further than 50 studs away, else only render pets of players within the render radius
				local spawnPos5 = getSpawnPosition(Character,-1.5) 
				local continu =true
				if Pet[15]:GetAttribute("Minigame") == "Falling Tiles" or spawnPos5 == nil then
					spawnPos5 = {
						Position = (Character.PrimaryPart.CFrame*CFrame.new(4,0,-1.5)).Position - Vector3.new(0,2.8,0),
						Material = Enum.Material.SmoothPlastic,
					}
				end
				if continu and PetModel and PetModel.PrimaryPart and (PetModel.PrimaryPart.Position-Character.PrimaryPart.Position).magnitude > 50 or Character:GetAttribute("InBoat") then
					local height = spawnPos5.Position.Y  + PetModel:GetExtentsSize().Y/2
					Pet[3].CFrame = CFrame.new(Vector3.new(spawnPos5.Position.X ,height,spawnPos5.Position.Z),Vector3.new(Character.PrimaryPart.Position.X,height,Character.PrimaryPart.Position.Z))
					PetModel:SetPrimaryPartCFrame(Pet[3].CFrame)
				elseif continu and PetModel and PetModel.PrimaryPart and game:GetService("Players").LocalPlayer.Character and (PetModel.PrimaryPart.Position-game:GetService("Players").LocalPlayer.Character.PrimaryPart.Position).magnitude < RenderDistance then
					--move towards player
					if Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid"):GetState() == Enum.HumanoidStateType.Seated then
						--player is sitting
						if Pet[17] == nil then
							-- if not already sitting, find valid position around player to sit at
							local spawnPos
							Pet[17] = true
							if string.find(Character.Humanoid.SeatPart.Parent.Name,"Bench") then --sit infront of player in benches
								spawnPos = getSpawnPosition(Character,-6,0) 
							elseif string.find(Character.Humanoid.SeatPart.Parent.Name,"SmallSeat") then --sit infront of player in small round seats
								spawnPos = getSpawnPosition(Character,-1,4) 
							else --sit around player, find position
								for i = 1,8 do
									local angle = i * (fullCircle / 8)
									local x, z = getXAndZPositions(angle)
									local position = (Character.PrimaryPart.CFrame * CFrame.new(x, 0, z)).p
									spawnPos = getSpawnPosition(position,x,z) 
									if spawnPos.Instance.CanCollide == false or (spawnPos.Material) == Enum.Material.Water or (spawnPos.Material) == Enum.Material.Sand or (spawnPos.Material) == Enum.Material.Air or (spawnPos.Material) == nil then
									else
										break
									end
								end
							end
							if Character:FindFirstChild("Humanoid") and Character:FindFirstChild("Humanoid"):GetState() == Enum.HumanoidStateType.Seated then
								local height = spawnPos.Position.Y + PetModel:GetExtentsSize().Y/2
								if string.find(Character.Humanoid.SeatPart.Parent.Name,"Bench") == nil then
									Pet[1]:SetPrimaryPartCFrame( CFrame.new(Vector3.new(spawnPos.Position.X ,height,spawnPos.Position.Z))  * Pet[14].SitCFrame * CFrame.Angles(0,math.rad(Character.PrimaryPart.Orientation.Y),0))
								end
								Pet[3].CFrame =  CFrame.new(Vector3.new(spawnPos.Position.X ,height,spawnPos.Position.Z))  * Pet[14].SitCFrame * CFrame.Angles(0,math.rad(Character.PrimaryPart.Orientation.Y),0)
								Pet[1].PrimaryPart.AlignPosition.RigidityEnabled = true
								Pet[1].PrimaryPart.AlignOrientation.RigidityEnabled = true
								Pet[17] = Character.PrimaryPart.CFrame:toObjectSpace(Pet[3].CFrame)
								PetModel:SetAttribute("State","Sit")
							end
						elseif Pet[17] and type(Pet[17]) == "userdata" then --found place to sit already, set position
							PetModel:SetAttribute("State","Sit")
							Pet[1].PrimaryPart.AlignPosition.RigidityEnabled = true
							Pet[1].PrimaryPart.AlignOrientation.RigidityEnabled = true
							Pet[1]:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * Pet[17] * Pet[14].SitCFrame)
							Pet[3].CFrame = Character.PrimaryPart.CFrame * Pet[17] * Pet[14].SitCFrame --* CFrame.Angles(0,math.rad(Character.PrimaryPart.Orientation.Y),0)
						end
					else --move to player
						Pet[1].PrimaryPart.AlignOrientation.RigidityEnabled = false
						Pet[1].PrimaryPart.AlignPosition.RigidityEnabled = false
						Pet[17] = nil
						local rot = Character:GetPrimaryPartCFrame()-Character.PrimaryPart.Position
						local height = spawnPos5.Position.Y + PetModel:GetExtentsSize().Y/2
						if (spawnPos5.Material) == nil or (spawnPos5.Material) == Enum.Material.Water or (spawnPos5.Material) == Enum.Material.Sand or (spawnPos5.Material) == Enum.Material.Air then
							Pet[3].CFrame = CFrame.new(Pet[3].Position) * rot --,Vector3.new(Pet[2].PrimaryPart.Position.X,Pet[3].Position.Y,Pet[2].PrimaryPart.Position.Z))	
						else
							Pet[3].CFrame = CFrame.new(Vector3.new(spawnPos5.Position.X ,height,spawnPos5.Position.Z)) * rot * Pet[13]--,Vector3.new(Pet[2].PrimaryPart.Position.X,height,Pet[2].PrimaryPart.Position.Z)) * Pet[13]
						end
						if Pet[2] and Pet[2].Humanoid.MoveDirection.Magnitude > 0 and (spawnPos5.Material) ~= Enum.Material.Water and (spawnPos5.Material) ~= Enum.Material.Sand and (spawnPos5.Material) ~= Enum.Material.Air and (spawnPos5.Material) ~= nil  then
							PetModel:SetAttribute("State","Walk")
							PetModel:SetAttribute("Status","Moving")
						else
							PetModel:SetAttribute("State","Idle")
							PetModel:SetAttribute("Status","Idling")
						end
					end
				end
			end
		end)()
	end
end)

--add pet for all existing players
spawn(function()
	for i,player in pairs (game:GetService("Players"):GetPlayers()) do
		if player ~= game.Players.LocalPlayer then
			Pets.addPetToPlayer(player)
		end
	end
end)

--detect any new players
game:GetService("Players").PlayerAdded:Connect(function(Player)
	Pets.addPetToPlayer(Player)
end)

--handle pet for local client
print("add pet to localplayer")
Pets.addPetToPlayer(game:GetService("Players").LocalPlayer)
print("load inventory")
PetUI.Inventory(Paths)
print("end load inventory")
game.Players.LocalPlayer:SetAttribute("BuyingEgg",false)

game.Players.LocalPlayer:GetAttributeChangedSignal("BuyingEgg"):Connect(function()
	if game.Players.LocalPlayer:GetAttribute("BuyingEgg") == false then
		isAdopting = false
	end
end)

Paths.UI.Center.BuyEgg.Exit.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer:SetAttribute("BuyingEgg",false)
end)

local ProximityPrompt
if Paths.Tycoon then
	ProximityPrompt = Paths.Tycoon:WaitForChild("BuyEgg").ProximityPart.Value:WaitForChild("ProximityPrompt")
elseif workspace:FindFirstChild("PetShop") then
	ProximityPrompt = workspace.PetShop.ProximityPart.Value:WaitForChild("ProximityPrompt")
end

if ProximityPrompt then
	ProximityPrompt.Triggered:Connect(function(player)
		if player == game.Players.LocalPlayer and Paths.UI.Center.TeleportConfirmation.Visible == false and Paths.UI.Center.BuyEgg.Visible == false and game.Players.LocalPlayer:GetAttribute("BuyingEgg") == false then
			PetUI.LoadEgg("Egg1",Paths)
			Paths.Modules.Buttons:UIOff(Paths.UI.Center.Pets,true)
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.BuyEgg,true)
		end
	end)
else
	print("no proximity prompt")
end

Paths.Remotes.ResetProductPurchase.OnClientEvent:Connect(function()
	Paths.Modules.Buttons:UIOff(Paths.UI.Center.BuyEgg,true)
	game.Players.LocalPlayer:SetAttribute("BuyingEgg",false)
end)

return Pets

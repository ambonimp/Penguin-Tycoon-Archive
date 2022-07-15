local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Pets = {}
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:WaitForChild("Pets")

local AllAudio = Paths.Player.PlayerScripts:WaitForChild("Audio")
local ButtonClick = Modules.Audio:GetSound(Modules.Audio.BUTTON_CLICKED, AllAudio, 0.2)
local LocalPlayer = Paths.Player
local PetDetails = Modules.PetDetails
local TweenService = Services.TweenService
local Assets = Services.RStorage.Assets
local PetsAssets = Assets.Pets
local PetsFolder = workspace.Pets
local PetSelected = UI.Full.PetSelected
local PetsFrame = UI.Center.Pets
local SelectedPetDetails = nil
local Example = Dependency.PetTemplate
local CurrentEggLoaded = nil
local BuyEgg = UI.Center.BuyEgg
local IndexPage = UI.Center.Index.Sections.Pets.Holder
local PetAdoptionUI = UI.Full.PetAdoption

local Deleting = {}
local State = "None"
local EditID = nil
local info = TweenInfo.new(.125)
local Loaded = {}
local PetAnims = {}  -- Equipped pets loaded animations
local TweenValues = {} --Used for tweening the pets smoothly
local clickdb = false
local openingEgg = false
local MergeSelected = {}
local RealData = nil
local PromptObj = nil
local autoHatching = false

local SMALL_GAMEPASS = 55102169
local HUGE_GAMEPASS = 55102286

local function getTotalPets()
	return #PetsFrame.Pets.Pets:GetChildren()-1
end

local function UpdateStorage()
	PetsFrame.Capacity.TextLabel.Text = getTotalPets() .. "/" .. LocalPlayer:GetAttribute("MaxPetsOwned")
end

LocalPlayer:GetAttributeChangedSignal("MaxPetsOwned"):Connect(function()
	UpdateStorage()
end)

function tweenModel(model,cf)
	local c = TweenValues[model] or Instance.new("CFrameValue")
	TweenValues[model] = c
	c.Value = model:GetPrimaryPartCFrame()
	c:GetPropertyChangedSignal("Value"):Connect(function()
		if model and model.PrimaryPart then
			model:SetPrimaryPartCFrame(c.Value)
		else
			c:Destroy()
		end
	end)
	if c then
		local tween = Services.TweenService:Create(c,info,{Value = cf})
		tween:Play()
	end
end

function getDis(Model1,Model2)
	if Model1 == nil or Model2 == nil then return 0 end
	if Model1.PrimaryPart == nil or Model2.PrimaryPart == nil then return 0 end
	return (Model1.PrimaryPart.Position-Model2.PrimaryPart.Position).magnitude
end

function loadPlayer(Player)
	if Loaded[Player.Name] then return end
	Loaded[Player.Name] = true
	local PetData = Remotes.PetsRemote:InvokeServer(Player)
	local PetTable = {}

	local function EquipPet(PetData,id)
		if Player.Character == nil or Player.Character:FindFirstChild(id.."_Pet") then return end
		local PetModel = nil
		local PetName = PetData[1]
		local PetKind = PetData[2]
		local newPart = Instance.new("Part")
		newPart.Transparency = 1
		newPart.CanCollide = false
		newPart.CanQuery = false
		newPart.Anchored = true

		local Constraint1 = Instance.new("AlignPosition")
		local Constraint2 = Instance.new("AlignOrientation")
		Constraint1.MaxVelocity = 50
		Constraint1.Responsiveness = 100
		Constraint2.RigidityEnabled = true
		local att1 = Instance.new("Attachment")
		local att2 = Instance.new("Attachment")
		if PetData[4] == "LEGACY" then
			PetModel = PetsAssets:FindFirstChild(PetName):FindFirstChild(PetKind):Clone()
			for i,v in PetModel:GetChildren() do
				if v:IsA("BasePart") then
					v.CanCollide = false
					v.Anchored = false
					v.Massless = true
				end
			end

			att1.Parent = PetModel.PrimaryPart
			att2.Parent = newPart

			Constraint1.Attachment0 = att1
			Constraint1.Attachment1 = att2
			Constraint2.Attachment0 = att1
			Constraint2.Attachment1 = att2

			Constraint1.Parent = PetModel.PrimaryPart
			Constraint2.Parent = PetModel.PrimaryPart
			PetModel:SetPrimaryPartCFrame(Player.Character:GetPrimaryPartCFrame()*CFrame.new(0,-10,10))

			PetModel.Name = id.."_Pet"
			newPart.Name = id.."_PetPart"

			newPart.Parent = Player.Character
			PetModel.Parent = Player.Character

			local PetName = Dependency.PetName:Clone()
			PetName.PetName.Text = PetData[3]
			PetName.Level.Text = ""
			PetName.StudsOffset = Vector3.new(0,2.5,0)
			PetName.Parent = PetModel.PrimaryPart
			if PetModel.AnimationController:FindFirstChild("Animator") then
				PetAnims[PetModel] = {
					Walk = PetModel.AnimationController.Animator:LoadAnimation(PetModel.Animations.Walk),
					Idle = PetModel.AnimationController.Animator:LoadAnimation(PetModel.Animations.Idle)
				}
			else
				PetAnims[PetModel] = {
					Walk = PetModel.AnimationController:LoadAnimation(PetModel.Animations.Walk),
					Idle = PetModel.AnimationController:LoadAnimation(PetModel.Animations.Idle)
				}
			end
		else
			PetModel = PetsAssets:FindFirstChild(string.upper(PetName)):FindFirstChild(string.upper(PetKind)).Model:Clone()
			local BlankModel = PetsAssets:FindFirstChild(string.upper(PetName)).BLANK.Model
			for i,v in PetModel:GetChildren() do
				if v:IsA("BasePart") then
					v.CanCollide = false
					v.Anchored = false
					v.Massless = true
				end
			end
			PetModel:SetPrimaryPartCFrame(Player.Character:GetPrimaryPartCFrame()*CFrame.new(0,-10,10))

			att1.Parent = PetModel.CenteredBase
			att2.Parent = newPart

			Constraint1.Attachment0 = att1
			Constraint1.Attachment1 = att2
			Constraint2.Attachment0 = att1
			Constraint2.Attachment1 = att2
			Constraint1.Parent = PetModel.CenteredBase
			Constraint2.Parent = PetModel.CenteredBase
			PetModel.PrimaryPart = PetModel.CenteredBase
			PetModel.Name = id.."_Pet"
			newPart.Name = id.."_PetPart"
			newPart.Parent = Player.Character
			PetModel.Parent = Player.Character
			if BlankModel.AnimationController.walk:FindFirstChild("Speed") then
				PetModel:SetAttribute("AnimWalkSpeed",BlankModel.AnimationController.walk:FindFirstChild("Speed").Value)
			else
				PetModel:SetAttribute("AnimWalkSpeed",1)
			end

			local PetName = Dependency.PetName:Clone()
			PetName.PetName.Text = PetData[3]
			PetName.Level.Text = "Lvl. "..PetData[5]
			PetName.Parent = PetModel.HumanoidRootPart.NametagAttachment
			PetAnims[PetModel] = {
				Walk = PetModel.AnimationController.Animator:LoadAnimation(BlankModel.AnimationController.walk),
				Idle = PetModel.AnimationController.Animator:LoadAnimation(BlankModel.AnimationController.idle)
			}
		end
		table.insert(PetTable,{newPart,PetModel})
	end
	local lastPos = nil
	Services.RunService:BindToRenderStep("Pets"..Player.Name,Enum.RenderPriority.Camera.Value-1,function(delta)
		if Player.Character and Player.Character.PrimaryPart and #PetTable > 0 then
			local dis = getDis(Player.Character,LocalPlayer.Character)
			if (Player ~= LocalPlayer and dis < 100 and dis ~= 0) or Player == LocalPlayer then
				local moving = Player.Character.Humanoid.MoveDirection ~= Vector3.new(0,0,0)
				for i = 1,#PetTable do
					local Part = PetTable[i][1]
					local Model = PetTable[i][2]
					local cfOffset = PetDetails.PetsOffset[#PetTable][i]
					if lastPos == nil then
						lastPos = Player.Character:GetPrimaryPartCFrame()
					end
					if (Player.Character:GetPrimaryPartCFrame().Position-lastPos.Position).magnitude > 80 then
						Part.CFrame = Player.Character.PrimaryPart.CFrame*cfOffset
						Model:SetPrimaryPartCFrame(Player.Character.PrimaryPart.CFrame*cfOffset)
						if i == #PetTable then
							lastPos = Player.Character:GetPrimaryPartCFrame()
						end
					else
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = {Player.Character,Model}
						raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

						local raycastResult = workspace:Raycast((Player.Character.PrimaryPart.CFrame*cfOffset).Position+Vector3.new(0,3.5,0), Vector3.new(0,-200,0), raycastParams)
						if raycastResult and raycastResult.Material ~= Enum.Material.Water then
							if moving then
								if PetAnims[Model].Walk.IsPlaying == false then
									PetAnims[Model].Idle:Stop(.25)
									PetAnims[Model].Walk:Play(.25,1,Model:GetAttribute("AnimWalkSpeed"))
								end
							else
								if PetAnims[Model].Idle.IsPlaying == false then
									PetAnims[Model].Idle:Play(.25)
									PetAnims[Model].Walk:Stop(.25)
								end
							end
							local rot = Player.Character:GetPrimaryPartCFrame()-Player.Character.PrimaryPart.Position
							Part.CFrame = CFrame.new(raycastResult.Position+Vector3.new(0,Model.PrimaryPart.Size.Y/2,0)) * rot
							--tweenModel(
							--	Model,
							--	CFrame.new(raycastResult.Position+Vector3.new(0,Model.PrimaryPart.Size.Y/2,0)) * rot
							--)

							if i == #PetTable then
								lastPos = Player.Character:GetPrimaryPartCFrame()
							end
						else
							if PetAnims[Model].Idle.IsPlaying == false then
								PetAnims[Model].Idle:Play(.25)
								PetAnims[Model].Walk:Stop(.25)
							end
						end
					end
				end
			end
		end
	end)

	local loaded = false
	local lastRetreival = tick()-5
	local function loadPets(from)
		local lastData = PetData
		PetData = Remotes.PetsRemote:InvokeServer(Player)
		if PetData then
			if lastData then
				for i,v1 in pairs (PetData.Equipped) do
					EquipPet(PetData.PetsOwned[tostring(v1)],v1)
				end
				for i,v1 in pairs (lastData.Equipped) do
					if table.find(PetData.Equipped,v1) == nil then
						for i,v in pairs (PetTable) do
							if v[2].Name == v1.."_Pet" then
								local _1 = v[1]
								local _2 = v[2]
								table.remove(PetTable,i)
								_1:Destroy()
								_2:Destroy()
								break
							end
						end
					end
				end
			else
				for i,v in pairs (PetData.Equipped) do
					EquipPet(PetData.PetsOwned[tostring(v)],v)
				end
			end
		end
	end

	Player:GetAttributeChangedSignal("PetsEquipped"):Connect(function()
		if Player ~= LocalPlayer then
			local dis = getDis(Player.Character,LocalPlayer.Character)
			if dis > 0 and dis < 100 then
				loadPets("changed attribute")
			end
		else
			loadPets("changed attribute")
		end
	end)

	Player.CharacterAdded:Connect(function()
		PetTable = {}
		if Player ~= LocalPlayer then
			local dis = getDis(Player.Character,LocalPlayer.Character)
			if dis > 0 and dis < 100 then
				loadPets("new character")
			end
		else
			loadPets("new character")
		end
	end)
	--workspace.Player1:MoveTo(workspace.Player2.PrimaryPart.Position)
	if Player ~= LocalPlayer then
		while true do
			local dis = getDis(Player.Character,LocalPlayer.Character)
			if dis ~= 0 and dis < 100 and loaded == false then
				loaded = true
				PetTable = {}
				loadPets("character now close")
			elseif Player:DistanceFromCharacter(LocalPlayer.Character.PrimaryPart.Position) > 100 or dis == 0 then
				loaded = false
				for i,v in pairs (PetTable) do
					v[1]:Destroy()
					v[2]:Destroy()
				end
				PetTable = {}
			end
			task.wait(3)
		end
	else
		loadPets("initial load")
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	loadPlayer(plr)
end)

game.Players.PlayerRemoving:Connect(function(plr)
	Loaded[plr.Name] = nil
	Services.RunService:UnbindFromRenderStep("Pets"..plr.Name)
end)

task.spawn(function()
	for i,v in pairs (game.Players:GetPlayers()) do
		loadPlayer(v)
	end
end)

function openSelected(x,y)
	local petDetails = SelectedPetDetails[2]
	PetSelected.Position = UDim2.fromOffset(x,y)
	PetSelected.Frame.PetName.Text = petDetails[3]
	PetSelected.Frame.PetType.Text = petDetails[1]
	PetSelected.Frame.PetKind.Text = petDetails[2]
	PetSelected.Frame.Rarity.Text = petDetails[4]
	PetSelected.Frame.Rarity.TextColor3 = PetDetails.RarityColors[petDetails[4]]
	PetSelected.Frame.Level.Text = "Lvl. ".. petDetails[5]
	PetSelected.Frame.Ability.Text = "x"..petDetails[6][1].." ".. petDetails[6][2].." ".. petDetails[6][3]
	PetSelected.Visible = true
end

PetsFrame.Merge.MouseButton1Down:Connect(function()
	Paths.Modules.Buttons:UIOff(Paths.UI.Center.Pets, true)

	MergeSelected = {}
	UI.Center.Merge.Merge1.Icon.Image = ""
	UI.Center.Merge.Merge2.Icon.Image = ""
	UI.Center.Merge.Merge3.Icon.Image = ""

	UI.Center.Merge.Merge1.Text.Text = "Lvl. 0"
	UI.Center.Merge.Merge2.Text.Text = "Lvl. 0"
	UI.Center.Merge.Merge3.Text.Text = "Lvl. 0"
end)

UI.Center.Merge.Clear.MouseButton1Down:Connect(function()
	MergeSelected = {}
	UI.Center.Merge.Merge1.Icon.Image = ""
	UI.Center.Merge.Merge2.Icon.Image = ""
	UI.Center.Merge.Merge3.Icon.Image = ""

	UI.Center.Merge.Merge1.Text.Text = "Lvl. 0"
	UI.Center.Merge.Merge2.Text.Text = "Lvl. 0"
	UI.Center.Merge.Merge3.Text.Text = "Lvl. 0"
end)

UI.Center.Merge.Exit.MouseButton1Down:Connect(function()
	Paths.Modules.Buttons:UIOn(Paths.UI.Center.Pets,true)
end)

UI.Center.Merge.Merge.MouseButton1Down:Connect(function()
	if clickdb then return end
	clickdb = true
	if MergeSelected[1] and MergeSelected[2] then
		local Merged,Data,ID1,ID2 = Remotes.MergePet:InvokeServer(MergeSelected[1],MergeSelected[2])
		if Merged then
			RealData = Data
			updateUI(Data,"delete",ID2)
			updateUI(Data,"update",ID1)
		else
			UI.Center.Merge.Warn.Text = "Something went wrong."
			task.wait(4)
			if UI.Center.Merge.Warn.Text == "Something went wrong." then
				UI.Center.Merge.Warn.Text = "Merging creates a stronger poofie"
			end
		end
		MergeSelected = {}
		UI.Center.Merge.Merge1.Icon.Image = ""
		UI.Center.Merge.Merge2.Icon.Image = ""
		UI.Center.Merge.Merge3.Icon.Image = ""

		UI.Center.Merge.Merge1.Text.Text = "Lvl. 0"
		UI.Center.Merge.Merge2.Text.Text = "Lvl. 0"
		UI.Center.Merge.Merge3.Text.Text = "Lvl. 0"

		UpdateStorage()
	end
	task.wait(.15)
	clickdb = false
end)

function changeFrameColors(frame,color1,color2)
	frame.BackgroundColor3 = color1
	frame.UIStroke.Color = color2
end

function updateIndex(data,islandId)
	local island = PetDetails.ChanceTables[islandId]

	local frame = IndexPage.List:FindFirstChild(island.Name)
	if frame then
		local Pets = frame.Pets.Pets:GetChildren()

		warn("Client:", data.Unlocked)
		warn(" ")

		for i,v in pairs (Pets) do
			local PetId = tonumber(v.Name)
			if PetId and data.Unlocked[tostring(PetId)] then
				local pet = nil
				for i,v in pairs (island.Pets) do
					print(i,v,PetId)
					if v.Id == PetId then
						pet = v
						break
					end
				end
				print(pet)
				local Rarity = PetDetails.Rarities[pet.Percentage]
				v.Icon.ImageColor3 = Color3.new(1,1,1)
				v.PetName.Text = PetDetails.Pets[PetId][1]--.." x"..data.Unlocked[tostring(PetId)]
				v.BackgroundColor3 = PetDetails.RarityColors[Rarity]
				v.UIStroke.Color = PetDetails.RarityColors[Rarity]
			end

		end

	end
	
end

function Pets.UpdateEggUI()
	local tycoonData = Remotes.GetStat:InvokeServer("Tycoon")
	for i,v in pairs (UI.Center.UnlockedEggs.Eggs.Pets:GetChildren()) do
		if v:IsA("ImageButton") then
			if (tycoonData[v.Name] or v.Name == "1") and not v:GetAttribute("Unlocked") then
				v:SetAttribute("Unlocked",true)
				v.MouseButton1Down:Connect(function()
					if tycoonData[v.Name] or v.Name == "1" then
						Pets.LoadEgg(v:GetAttribute("Egg"),nil)
					end
				end)
			elseif not v:GetAttribute("Unlocked") then
				v.ViewportFrame.ImageColor3 = Color3.new(0,0,0)
			end
		end
	end
end

function addPetToViewport(Model,ViewPort)
	local camera = ViewPort.CurrentCamera or Instance.new("Camera")
	camera.Parent = ViewPort.WorldModel

	--remove any pre-exisitng models in the viewport
	if ViewPort.WorldModel:FindFirstChildOfClass("Model") then
		ViewPort.WorldModel:FindFirstChildOfClass("Model"):Destroy()
	end

	local newModel = Model:Clone()
	newModel.Parent = ViewPort.WorldModel

	--set camera in front and rotate towards model
	camera.CFrame = CFrame.new((newModel:GetPrimaryPartCFrame()*CFrame.new(0,0,-(newModel:GetExtentsSize().Y)*1.1)).Position,newModel:GetPrimaryPartCFrame().Position)

	ViewPort.CurrentCamera = camera
end


function updateUI(data,kind,ID)
	UpdateStorage()
	if kind == "add" then
		local petDetails = data.PetsOwned[tostring(ID)]---LocalPlayer:GetAttribute("MaxPetsOwned")
		if not petDetails then return end

		local PetModel = nil
		local Frame = Example:Clone()
		Frame.PetName.Text = petDetails[3]
		Frame.Name = ID
		Frame.Visible = true

		if petDetails[4] ~= "LEGACY" then
			Frame.PetName.TextColor3 = PetDetails.RarityColors[petDetails[4]]
			PetModel = PetsAssets:FindFirstChild(string.upper(petDetails[1])):FindFirstChild(string.upper(petDetails[2]))
			Frame.Icon.Image = PetModel.Icon.Texture
		else
			Frame.Icon.Image = ""
			PetModel = PetsAssets:FindFirstChild(petDetails[1]):FindFirstChild(petDetails[2])
			Frame.LayoutOrder = 99999
			addPetToViewport(PetModel,Frame.ViewportFrame)
		end

		Frame.Button.MouseButton1Click:Connect(function()
			if State == "NameChange" then
				OpenEdit(ID)
				return
			end
			if State == "Deleting" then
				if table.find(RealData.Equipped,ID)  then
					PetsFrame.Top.Text = "Can't delete an equipped pet"
					task.wait(4)
					if PetsFrame.Top.Text == "Can't edit an equipped pet" then
						PetsFrame.Top.Text = "Select pets to delete"
					end
					return
				end
				for i,v in pairs (Deleting) do
					if v[1] == ID and v[2] == Frame then
						Frame.X.Visible = false
						table.remove(Deleting,i)
						PetsFrame.DeleteReal.Top.Text = "Delete "..#Deleting
						return
					end
				end
				Frame.X.Visible = true
				table.insert(Deleting,{ID,Frame})
				PetsFrame.DeleteReal.Top.Text = "Delete "..#Deleting
				return
			end

			if PetSelected and PetSelected.Visible then
				PetSelected.Visible = false
			end
			ButtonClick:Play()
			if SelectedPetDetails and SelectedPetDetails[1] == ID then SelectedPetDetails = nil return end
			SelectedPetDetails = {ID,RealData.PetsOwned[tostring(ID)]}
			local mPos = Paths.Services.InputService:GetMouseLocation()
			openSelected(mPos.X,mPos.Y)
		end)

		Frame.Equip.MouseButton1Down:Connect(function()
			if clickdb then return end
			clickdb = true
			ButtonClick:Play()
			local data,did = nil,false
			if Frame.Equip.Text.Text == "Unequip" then
				data,did = Remotes.UnequipPet:InvokeServer({ID})
			else
				data,did = Remotes.EquipPet:InvokeServer({ID})
			end
			if data and did then
				RealData = data
				updateUI(data,"update",ID)
			end
			task.wait(.15)
			clickdb = false
		end)

		if table.find(data.Equipped,ID) then
			Frame.LayoutOrder = -1
			changeFrameColors(Frame,Color3.fromRGB(85, 255, 0),Color3.fromRGB(41, 124, 0))
			changeFrameColors(Frame.Equip,Color3.new(0.752941, 0.027450, 0.027450),Color3.new(0.588235, 0.027450, 0.027450))
			Frame.Equip.Text.Text = "Unequip"
		else
			Frame.LayoutOrder = ID
			changeFrameColors(Frame,Color3.fromRGB(211, 211, 211),Color3.fromRGB(255, 255, 255))
			changeFrameColors(Frame.Equip,Color3.fromRGB(85, 255, 0),Color3.fromRGB(41, 124, 0))
			Frame.Equip.Text.Text = "Equip"
		end

		Frame.Parent = PetsFrame.Pets.Pets
		if petDetails[4] ~= "LEGACY" then
			local clone = Frame:Clone()

			clone.Equip:Destroy()
			clone.Parent = UI.Center.Merge.Pets.Pets
			clone.PetName.Text = "Lvl. "..petDetails[5]
			clone.PetName.TextColor3 = Color3.new(1,1,1)
			clone.Button.MouseButton1Down:Connect(function()
				ButtonClick:Play()
				if table.find(RealData.Equipped,ID) then
					UI.Center.Merge.Warn.Text = "Can't merge an equipped pet."
					task.wait(4)
					if UI.Center.Merge.Warn.Text == "Can't merge an equipped pet." then
						UI.Center.Merge.Warn.Text = "Merging creates a stronger poofie"
					end
					return
				end
				if MergeSelected[1] and MergeSelected[1] ~= ID and MergeSelected[2] == nil then
					if RealData.PetsOwned[tostring(ID)][1] == RealData.PetsOwned[tostring(MergeSelected[1])][1] and RealData.PetsOwned[tostring(ID)][2] == RealData.PetsOwned[tostring(MergeSelected[1])][2] and RealData.PetsOwned[tostring(ID)][5] == RealData.PetsOwned[tostring(MergeSelected[1])][5] then
						MergeSelected[2] = ID
						UI.Center.Merge.Merge2.Icon.Image = PetModel.Icon.Texture
						UI.Center.Merge.Merge2.Text.Text = "Lvl.".. RealData.PetsOwned[tostring(ID)][5]

						UI.Center.Merge.Merge3.Icon.Image = PetModel.Icon.Texture
						UI.Center.Merge.Merge3.Text.Text = "Lvl.".. RealData.PetsOwned[tostring(ID)][5]+1
					else
						UI.Center.Merge.Warn.Text = "Can only merge same level and same poofie type."
						task.wait(4)
						if UI.Center.Merge.Warn.Text == "Can only merge same level and same poofie type." then
							UI.Center.Merge.Warn.Text = "Merging creates a stronger poofie"
						end
					end

				elseif MergeSelected[1] == nil then
					MergeSelected[1] = ID
					UI.Center.Merge.Merge1.Icon.Image = PetModel.Icon.Texture
					UI.Center.Merge.Merge1.Text.Text = "Lvl.".. RealData.PetsOwned[tostring(ID)][5]
				end
			end)
		end
	elseif kind == "delete" then
		if PetsFrame.Pets.Pets:FindFirstChild(ID) then
			PetsFrame.Pets.Pets:FindFirstChild(ID):Destroy()
		end
		if UI.Center.Merge.Pets.Pets:FindFirstChild(ID) then
			UI.Center.Merge.Pets.Pets:FindFirstChild(ID):Destroy()
		end
	elseif kind == "update" then
		local petDetails = data.PetsOwned[tostring(ID)]
		if PetsFrame.Pets.Pets:FindFirstChild(ID) then
			local Frame = PetsFrame.Pets.Pets:FindFirstChild(ID)
			Frame.PetName.Text = petDetails[3]
			if table.find(data.Equipped,ID) then
				Frame.LayoutOrder = -1
				changeFrameColors(Frame,Color3.fromRGB(85, 255, 0),Color3.fromRGB(41, 124, 0))
				changeFrameColors(Frame.Equip,Color3.new(0.752941, 0.027450, 0.027450),Color3.new(0.588235, 0.027450, 0.027450))
				Frame.Equip.Text.Text = "Unequip"
				if UI.Center.Merge.Pets.Pets:FindFirstChild(ID) then
					changeFrameColors(UI.Center.Merge.Pets.Pets:FindFirstChild(ID),Color3.fromRGB(85, 255, 0),Color3.fromRGB(41, 124, 0))
				end
			else
				Frame.LayoutOrder = ID
				if UI.Center.Merge.Pets.Pets:FindFirstChild(ID) then
					changeFrameColors(UI.Center.Merge.Pets.Pets:FindFirstChild(ID),Color3.fromRGB(211, 211, 211),Color3.fromRGB(255, 255, 255))
				end
				changeFrameColors(Frame,Color3.fromRGB(211, 211, 211),Color3.fromRGB(255, 255, 255))
				changeFrameColors(Frame.Equip,Color3.fromRGB(85, 255, 0),Color3.fromRGB(41, 124, 0))
				Frame.Equip.Text.Text = "Equip"
			end

			if UI.Center.Merge.Pets.Pets:FindFirstChild(ID) then
				UI.Center.Merge.Pets.Pets:FindFirstChild(ID).PetName.Text = "Lvl. "..petDetails[5]
			end
		else
			updateUI(data,"add",ID)
		end
	end
end

function loadUI(data)
	for i,v in pairs (data.PetsOwned) do
		print("load",i,v)
		updateUI(data,"add",i)
	end
	UpdateStorage()
end

function OpenEdit(ID)
	State = "None"
	PetsFrame.Top.Text = ""
	EditID = ID
	local Frame = PetsFrame.EditName
	local PetData = RealData.PetsOwned[tostring(ID)]
	local PetModel = nil
	if PetData[4] ~= "LEGACY" then
		Frame.ViewportFrame.Visible = false
		PetModel = PetsAssets:FindFirstChild(string.upper(PetData[1])):FindFirstChild(string.upper(PetData[2]))
		Frame.Icon.Image = PetModel.Icon.Texture
	else
		Frame.Icon.Image = ""
		Frame.ViewportFrame.Visible = true
		PetModel = PetsAssets:FindFirstChild(PetData[1]):FindFirstChild(PetData[2])
		Frame.LayoutOrder = 99999
		addPetToViewport(PetModel,Frame.ViewportFrame)
	end
	Frame.NameChange.TextBox.Text = PetData[3]
	Frame.Text.Text = PetData[1]
	Frame.Visible = true
end

function Pets.LoadEgg(Island,Prompt)
	Paths.Modules.Buttons:UIOff(Paths.UI.Center.UnlockedEggs,true)
	if CurrentEggLoaded == Island then
		Paths.Modules.Buttons:UIOff(Paths.UI.Center.Pets,true)
		Paths.Modules.Buttons:UIOn(Paths.UI.Center.BuyEgg,true)
		return
	end
	if Prompt then
		Prompt.Enabled = false
		PromptObj = Prompt
	end
	CurrentEggLoaded = Island
	local IslandDetails = PetDetails.ChanceTables[PetDetails.EggNameToId[Island]]

	BuyEgg.Gems.Text.Text = IslandDetails.PriceGems
	BuyEgg.Robux.Text.Text = IslandDetails.PriceRobux

	BuyEgg.TopText.Text = "Get A Poofie: "..Island
	for i,v in pairs (BuyEgg.Pets.Pets:GetChildren()) do
		if v:IsA("ImageButton") then
			v:Destroy()
		end
	end

	for i,v in pairs (IslandDetails.Pets) do
		local Pet = PetDetails.Pets[v.Id]
		local Template = Dependency.ShopTemplate:Clone()
		local PetModel = PetsAssets:FindFirstChild(string.upper(Pet[1])):FindFirstChild(string.upper(Pet[2]))

		local prev = IslandDetails.Pets[i-1]
		if prev then
			Template.Amount.Text = (v.Percentage*100)-(prev.Percentage*100).."%"
		else
			Template.Amount.Text = (v.Percentage*100).."%"
		end

		Template:FindFirstChild(PetDetails.Rarities[v.Percentage]).Visible = true
		Template.PetName.Text = Pet[1]
		Template.Icon.Image = PetModel.Icon.Texture

		Template.MouseButton1Down:Connect(function()
			ButtonClick:Play()
			BuyEgg.Bonus.Icon.Image = PetModel.Icon.Texture
			BuyEgg.Bonus.Text.Text ="x"..Pet[3].." ".. Pet[4].." ".. Pet[5]
			BuyEgg.Bonus.Visible = true
		end)

		Template.Parent = BuyEgg.Pets.Pets
	end
	BuyEgg.Bonus.Visible = false
	Paths.Modules.Buttons:UIOff(Paths.UI.Center.Pets,true)
	Paths.Modules.Buttons:UIOn(Paths.UI.Center.BuyEgg,true)
end

BuyEgg.Bonus.Exit.MouseButton1Down:Connect(function()
	BuyEgg.Bonus.Visible = false
end)

BuyEgg.Exit.MouseButton1Down:Connect(function()
	BuyEgg.Bonus.Visible = false
	if PromptObj then
		PromptObj.Enabled = true
		PromptObj = nil
	end
end)

BuyEgg:GetPropertyChangedSignal("Visible"):Connect(function()
	if BuyEgg.Visible == false and openingEgg == false then
		BuyEgg.Bonus.Visible = false
		if PromptObj then
			PromptObj.Enabled = true
			PromptObj = nil
		end
	end
end)

function buyEgg(auto)
	local Bought,Data,NewPetInfo,newId = Remotes.BuyEgg:InvokeServer(CurrentEggLoaded,"Gems")
	if Bought then
		RealData = Data
		local PetModel = PetsAssets:FindFirstChild(string.upper(NewPetInfo[1])):FindFirstChild(string.upper(NewPetInfo[2]))
		local info = RealData.PetsOwned[tostring(newId)]
		openEgg(PetModel.Icon.Texture,NewPetInfo[1],info[4],PetDetails.RarityColors[info[4]],auto)
		updateUI(Data,"add",newId)
		updateIndex(Data, Data.PetsOwned[tostring(newId)][8])
	end
	return Bought
end

BuyEgg.Gems.MouseButton1Down:Connect(function()
	BuyEgg.Bonus.Visible = false
	if CurrentEggLoaded then
		if getTotalPets() < LocalPlayer:GetAttribute("MaxPetsOwned") then
			local auto = LocalPlayer:GetAttribute("IsAutoHatch")
			local tbl = PetDetails.ChanceTables[PetDetails.EggNameToId[CurrentEggLoaded]]
			local con = nil
			if auto then
				autoHatching = true
				UI.Full.PetAdoption.Stop.Visible = true
				con = UI.Full.PetAdoption.Stop.MouseButton1Down:Connect(function()
					autoHatching = false
					auto = false
					UI.Full.PetAdoption.Stop.Visible = false
					con:Disconnect()
				end)
				while LocalPlayer:GetAttribute("Gems") >= tbl.PriceGems and auto and getTotalPets() < LocalPlayer:GetAttribute("MaxPetsOwned") do
					local bought = buyEgg(auto)
					if not bought or not auto then break end
					task.wait(1)
				end
				UI.Full.PetAdoption.Stop.Visible = false
				autoHatching = false
				if con then
					con:Disconnect()
				end
			else
				local bought = buyEgg(auto)
			end
		else
			local Gamepasses = Remotes.GetStat:InvokeServer("Gamepasses")
			if not Gamepasses[tostring(HUGE_GAMEPASS)] then
				if not Gamepasses[tostring(SMALL_GAMEPASS)] then
					Services.MPService:PromptGamePassPurchase(Paths.Player, SMALL_GAMEPASS)
				else
					Services.MPService:PromptGamePassPurchase(Paths.Player, HUGE_GAMEPASS)
				end

			end

		end

	end

end)

BuyEgg.Robux.MouseButton1Down:Connect(function()
	BuyEgg.Bonus.Visible = false
	if CurrentEggLoaded then
		if getTotalPets() < LocalPlayer:GetAttribute("MaxPetsOwned") then
			autoHatching = false
			Remotes.BuyEgg:InvokeServer(CurrentEggLoaded,"Robux")
		else
			local Gamepasses = Remotes.GetStat:InvokeServer("Gamepasses")

			if not Gamepasses[tostring(HUGE_GAMEPASS)] then
				if not Gamepasses[tostring(SMALL_GAMEPASS)] then
					Services.MPService:PromptGamePassPurchase(Paths.Player, SMALL_GAMEPASS)
				else
					Services.MPService:PromptGamePassPurchase(Paths.Player, HUGE_GAMEPASS)
				end

			end

		end

	end

end)

PetsFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	SelectedPetDetails = nil
	if PetSelected then
		PetSelected.Visible = false
	end
	EndState()
end)

PetsFrame.Index.MouseButton1Down:Connect(function()
	Paths.Modules.Buttons:UIOff(Paths.UI.Center.Pets,true)
end)

PetsFrame.Edit.MouseButton1Down:Connect(function()
	if SelectedPetDetails and SelectedPetDetails[1] and SelectedPetDetails[2] then
		OpenEdit(SelectedPetDetails[1])
	else
		State = "NameChange"
		PetsFrame.Top.Text = "Click on a click to change it's name"
	end
end)

function EndState()
	if State == "Deleting" or State == "EndDelete" then
		for i,v in pairs (Deleting) do
			v[2].X.Visible = false
		end
		Deleting = {}
		PetsFrame.DeleteReal.Visible = false
		PetsFrame.ConfirmDelete.Visible = false
	elseif State == "NameChange" then
		EditID = nil
		PetsFrame.EditName.Visible = false
		PetsFrame.EditName.NameChange.TextBox.Text = ""
		PetsFrame.EditName.Icon.Image = ""
	end
	PetsFrame.Top.Text = ""
	State = ""
end

PetsFrame.Delete.MouseButton1Down:Connect(function()
	if State == "Deleting" then
		EndState()
	else
		Deleting = {}
		PetsFrame.Top.Text = "Select pets to delete"
		PetsFrame.DeleteReal.Visible = true
		PetsFrame.DeleteReal.Top.Text = "Delete 0"
		State = "Deleting"
	end
end)

PetsFrame.DeleteReal.MouseButton1Down:Connect(function()
	State = "EndDelete"
	PetsFrame.DeleteReal.Visible = false
	PetsFrame.ConfirmDelete.Text.Text = "Are you sure you want to delete "..#Deleting.." poofie(s)?"
	PetsFrame.ConfirmDelete.Visible = true
end)

PetsFrame.ConfirmDelete.Cancel.MouseButton1Down:Connect(function()
	EndState()
end)

PetsFrame.ConfirmDelete.Confirm.MouseButton1Down:Connect(function()
	local newtbl = {}
	for i,v in pairs (Deleting) do
		table.insert(newtbl,v[1])
	end
	local did, data = Remotes.DeletePet:InvokeServer(newtbl)
	UpdateStorage()
	EndState()
	if did and data then
		RealData = data
		for i,v in pairs (newtbl) do
			updateUI(RealData,"delete",v)
		end
	end

end)

PetsFrame.EditName.Confirm.MouseButton1Down:Connect(function()
	local newName = PetsFrame.EditName.NameChange.TextBox.Text
	if #newName > 1 then
		local data,new = Remotes.PetName:InvokeServer(EditID,newName)
		if data and new then
			RealData = data
			PetsFrame.EditName.NameChange.TextBox.Text = new
			updateUI(RealData,"update",EditID)
		end
	end
end)

PetsFrame.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = PetsFrame.Search.TextBox.Text
	if #text > 1 then
		for i,v in pairs (PetsFrame.Pets.Pets:GetChildren()) do
			if tonumber(v.Name) then
				local id = tonumber(v.Name)
				if string.match(string.lower(RealData.PetsOwned[tostring(id)][1]),string.lower(text)) or string.match(string.lower(RealData.PetsOwned[tostring(id)][3]),string.lower(text)) then
					v.Visible = true
				else
					v.Visible = false
				end
			end
		end
	else
		for i,v in pairs (PetsFrame.Pets.Pets:GetChildren()) do
			if tonumber(v.Name) then
				v.Visible = true
			end
		end
	end
end)

PetsFrame.EditName.Exit.MouseButton1Down:Connect(function()
	PetsFrame.EditName.Visible = false
	EndState()
end)

PetsFrame.Best.MouseButton1Down:Connect(function()
	if clickdb then return end
	clickdb = true
	local oldequipped = {}
	for i,v in pairs (RealData.Equipped) do
		table.insert(oldequipped,v)
	end
	local data,did,except = Remotes.UnequipPet:InvokeServer(RealData.Equipped)
	if except then
		for i,v in pairs (except) do
			table.remove(oldequipped,table.find(oldequipped,v))
		end
	end

	if data and did then
		RealData = data
		for i,v in pairs (oldequipped) do
			updateUI(data,"update",v)
		end
	end

	local best = {}
	local new = {}
	local c = 0
	for i,v in pairs (RealData.PetsOwned) do
		c += 1
		new[c] = {i,v}
	end
	table.sort(new,function(a,b)
		if a[2][4] == "LEGACY" then return false end
		if b[2][4] == "LEGACY" then return true end
		return a[2][6][1]>b[2][6][1]
	end)
	for i = 1,LocalPlayer:GetAttribute("MaxEquip") do
		local pet = new[i]
		if pet then
			table.insert(best,new[i][1])
		end
	end

	local data,did,except = Remotes.EquipPet:InvokeServer(best)
	if except then
		for i,v in pairs (except) do
			table.remove(best,table.find(best,v))
		end
	end
	if data and did then
		RealData = data
		for i,v in pairs (best) do
			updateUI(data,"update",v)
		end
	end
	task.wait(.15)
	clickdb = false
end)

-- Capacity
UI.Right.Buttons.Backpack.MouseButton1Down:Connect(function()
	if not PetsFrame.Visible then
		UpdateStorage()
	end
end)

PetsFrame.Capacity.More.MouseButton1Down:Connect(function()
	Modules.Buttons:UIOff(PetsFrame, true)

	local Gamepasses = Remotes.GetStat:InvokeServer("Gamepasses")
	if not Gamepasses[tostring(SMALL_GAMEPASS)] then
		Services.MPService:PromptGamePassPurchase(Paths.Player, SMALL_GAMEPASS)
	elseif not Gamepasses[tostring(HUGE_GAMEPASS)] then
		Services.MPService:PromptGamePassPurchase(Paths.Player, HUGE_GAMEPASS)
	end

end)


function openEgg(Image,Name,Rarity,Color)
	openingEgg = true
	UI.Left.Visible = false
	UI.Top.Visible = false
	UI.Right.Visible = false
	UI.Bottom.Visible = false
	BuyEgg.Visible = false
	PetAdoptionUI.PetName.Visible = false
	PetAdoptionUI.Icon.Visible = false
	PetAdoptionUI.Rarity.Visible = false
	PetAdoptionUI.Rarity.Position = UDim2.fromScale(0.5, 0.132)
	PetAdoptionUI.Rarity.Size = UDim2.fromScale(0.3, 0.042)
	PetAdoptionUI.PetName.Position = UDim2.fromScale(0.5, 0.092)
	PetAdoptionUI.PetName.Size = UDim2.fromScale(0.3, 0.042)
	PetAdoptionUI.Icon.Size = UDim2.fromScale(0.25, 0.3)
	local startDistance = -13
	local EggMesh = Assets.PetEggs:FindFirstChild(CurrentEggLoaded):Clone()
	if PetAdoptionUI.ViewportFrame:FindFirstChildOfClass("MeshPart") then
		PetAdoptionUI.ViewportFrame:FindFirstChildOfClass("MeshPart"):Destroy()
	end
	PetAdoptionUI.ViewportFrame.Visible = true
	local cam = PetAdoptionUI.ViewportFrame.CurrentCamera or Instance.new("Camera")
	PetAdoptionUI.ViewportFrame.CurrentCamera = cam
	EggMesh.Parent = PetAdoptionUI.ViewportFrame
	local default =  cam.CFrame * CFrame.new(0,0,startDistance)

	EggMesh.CFrame = default * CFrame.new(0,0,-10)
	PetAdoptionUI.Visible = true
	local tweenLeft = TweenService:Create(EggMesh,TweenInfo.new(1,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{
		CFrame = default
	})
	tweenLeft:Play()
	task.wait(.5)
	local speed = .3
	Dependency.Sounds.Cracking:Play()
	for i = 1,2 do
		local wa = math.random(10,20)/100/speed
		local tweenLeft = TweenService:Create(EggMesh,TweenInfo.new(wa,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{
			CFrame = default*CFrame.new(0,0,math.random(0,5))*CFrame.Angles(math.rad(math.random(30,60)),0,math.rad(math.random(30,60)))
		})
		tweenLeft:Play()
		task.wait(wa)
		local wa2 = math.random(10,20)/100/speed
		local tweenRight = TweenService:Create(EggMesh,TweenInfo.new(wa2,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{
			CFrame = default*CFrame.new(0,0,math.random(0,5))*CFrame.Angles(math.rad(math.random(30,60)*-1),0,math.rad(math.random(30,60)*-1))
		})
		tweenRight:Play()
		task.wait(wa2)
		speed = speed * 1.5
	end
	local wa = math.random(10,20)/100/speed*2
	local tweenLeft = TweenService:Create(EggMesh,TweenInfo.new(wa,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
		CFrame = default*CFrame.new(0,0,11)
	})
	tweenLeft:Play()
	task.wait(wa*.9)
	PetAdoptionUI.ViewportFrame.Visible = false
	PetAdoptionUI.PetName.Text = Name
	PetAdoptionUI.Rarity.Text = Rarity
	PetAdoptionUI.Rarity.TextColor3 = Color
	PetAdoptionUI.Icon.Image = Image
	PetAdoptionUI.PetName.Visible = true
	PetAdoptionUI.Icon.Visible = true
	PetAdoptionUI.Rarity.Visible = true
	PetAdoptionUI.Rarity:TweenSizeAndPosition(UDim2.new(.25,0,.08,0),UDim2.new(.5,0,.225,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.125,true)
	PetAdoptionUI.PetName:TweenSizeAndPosition(UDim2.new(.3,0,.108,0),UDim2.new(.5,0,.125,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.125,true)
	PetAdoptionUI.Icon:TweenSize(UDim2.new(.35,0,.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.125,true)
	Dependency.Sounds.Ring:Play()
	local wasAuto = autoHatching
	if not autoHatching then
		task.wait(1)
		PetAdoptionUI.Continue.Visible = true
		PetAdoptionUI.Continue.MouseButton1Down:wait()
		PetAdoptionUI.Continue.Visible = false
		PetAdoptionUI.Visible = false
		PetAdoptionUI.ViewportFrame.Visible = true
		UI.Left.Visible = true
		UI.Top.Visible = true
		UI.Right.Visible = true
		UI.Bottom.Visible = true
		BuyEgg.Visible = true
		PetAdoptionUI.Rarity.Visible = false
		PetAdoptionUI.PetName.Visible = false
		PetAdoptionUI.Icon.Visible = false
		openingEgg = false
	elseif autoHatching then
		task.wait(.5)
	end
	task.spawn(function()
		task.wait(2)
		if wasAuto and not autoHatching and PetAdoptionUI.PetName.Visible == true then
			PetAdoptionUI.Continue.Visible = true
			PetAdoptionUI.Continue.MouseButton1Down:wait()
			PetAdoptionUI.Continue.Visible = false
			PetAdoptionUI.Visible = false
			PetAdoptionUI.ViewportFrame.Visible = true
			UI.Left.Visible = true
			UI.Top.Visible = true
			UI.Right.Visible = true
			UI.Bottom.Visible = true
			BuyEgg.Visible = true
			PetAdoptionUI.Rarity.Visible = false
			PetAdoptionUI.PetName.Visible = false
			PetAdoptionUI.Icon.Visible = false
			openingEgg = false
		end
	end)
end

PetsFrame.Pets.Pets.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PetsFrame.Pets.Pets.CanvasSize = UDim2.new(0, 0, 0, PetsFrame.Pets.Pets.UIGridLayout.AbsoluteContentSize.Y+(#PetsFrame.Pets.Pets:GetChildren()*2))
end)

PetsFrame.Pets.Pets:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	SelectedPetDetails = nil
	if PetSelected then
		PetSelected.Visible = false
	end
end)

function Remotes.BuyEgg.OnClientInvoke(Type,Data,PetId,PetInfo)
	if Type == "NewPet" then
		RealData = Data
		local PetModel = PetsAssets:FindFirstChild(string.upper(PetInfo[1])):FindFirstChild(string.upper(PetInfo[2]))
		local info = RealData.PetsOwned[tostring(PetId)]
		openEgg(PetModel.Icon.Texture,info[1],info[4],PetDetails.RarityColors[info[4]])
		updateUI(Data,"add",PetId)
		updateIndex(Data,Data.PetsOwned[tostring(PetId)][8])
	end
end

do -- Free Pet
	local FreePet = Paths.UI.Center.FreePet
	local Selected = {1,FreePet.Pets:WaitForChild("1")}
	
	local function updateSelected(button)
		Selected = {tonumber(button.Name),button}
		FreePet.Selected.Text = "Selected: "..button.PetName.Text
		button.BackgroundColor3 = Color3.fromRGB(109, 211, 0)
	end
	
	FreePet.Confirm.MouseButton1Down:Connect(function()
		local Did,Data,Id,Info = Remotes.ClaimPet:InvokeServer(Selected[1])
		
		if Did and Data and Id then
			RealData = Data
			updateUI(Data,"add",Id)
			updateUI(Data,"update",Id)
		end
		UI.Right.Buttons.Backpack.Notif.Visible = true
		Paths.Modules.Buttons:UIOff(Paths.UI.Center.FreePet,true)
		UI.Left.Visible = true
		UI.Top.Visible = true
		UI.Right.Visible = true
		UI.Bottom.Visible = true
	end)
	
	for i,button in pairs (FreePet.Pets:GetChildren()) do
		if button:IsA("ImageButton") then
			button.MouseButton1Down:Connect(function()
				Selected[2].BackgroundColor3 = Color3.fromRGB(211,211,211)
				updateSelected(button)
			end)
		end
	end
end

task.spawn(function()
	local TycoonData = Remotes.GetStat:InvokeServer("Tycoon")
	local PetData = Remotes.PetsRemote:InvokeServer(LocalPlayer)
	RealData = PetData
	loadUI(PetData)
	PetsFrame.Pets.Pets.CanvasSize = UDim2.new(0, 0, 0, PetsFrame.Pets.Pets.UIGridLayout.AbsoluteContentSize.Y+(#PetsFrame.Pets.Pets:GetChildren()*2))
	
	if Paths.Tycoon then
		if RealData.ClaimedFree == nil and TycoonData["Pets#1"] then
			UI.Left.Visible = false
			UI.Top.Visible = false
			UI.Right.Visible = false
			UI.Bottom.Visible = false
			Paths.Modules.Buttons:UIOn(Paths.UI.Center.FreePet,true)
		end
		Paths.Tycoon.Tycoon.ChildAdded:Connect(function(c)
			if c.Name == "Pets#1" then
				UI.Left.Visible = false
				UI.Top.Visible = false
				UI.Right.Visible = false
				UI.Bottom.Visible = false
				Paths.Modules.Buttons:UIOn(Paths.UI.Center.FreePet,true)
			elseif c.Name == "Beach House#1" then
				Paths.Modules.Buttons:UIOn(Paths.UI.Center.CompleteRocket,true)
			elseif UI.Center.UnlockedEggs.Eggs.Pets:FindFirstChild(c.Name) then
				local v = UI.Center.UnlockedEggs.Eggs.Pets:FindFirstChild(c.Name)
				v.ViewportFrame.ImageColor3 = Color3.new(1, 1, 1)
				v.MouseButton1Down:Connect(function()
					Pets.LoadEgg(v:GetAttribute("Egg"),nil)
				end)
			elseif c.Name == "Fishing Rod#1" then
				Paths.Modules.Setup:Notification("Click on water to start fishing!",Color3.new(0.184313, 0.752941, 0.792156),10)
			end
		end)
	end

	
	for i,IslandDetails in pairs (PetDetails.ChanceTables) do
		local newIsland = IndexPage.List.Island:Clone()
		newIsland.TopText.Text = IslandDetails.Name
		for i,v in pairs (IslandDetails.Pets) do
			local Pet = PetDetails.Pets[v.Id]
			local Rarity = PetDetails.Rarities[v.Percentage]
			local Template = Dependency.ShopTemplate:Clone()
			-- print(Pet[1],Pet[2])
			local PetModel = PetsAssets:FindFirstChild(string.upper(Pet[1])):FindFirstChild(string.upper(Pet[2]))

			Template.Amount.Text = ""
			if PetData.Unlocked[tostring(v.Id)] then
				Template.BackgroundColor3 = PetDetails.RarityColors[Rarity]
				Template.UIStroke.Color = PetDetails.RarityColors[Rarity]
				Template.PetName.Text = Pet[1]--.. " x"..PetData.Unlocked[tostring(v.Id)]
				Template.Icon.ImageColor3 = Color3.new(1,1,1)
			else
				Template.BackgroundColor3 = Color3.new()
				Template.UIStroke.Color = Color3.new()
				Template.Icon.ImageColor3 = Color3.new(0,0,0)
				Template.PetName.Text = ""
			end
			Template.Icon.Image = PetModel.Icon.Texture
			Template.Name = v.Id
			Template.Parent = newIsland.Pets.Pets
		end
		newIsland.Visible = true
		newIsland.Name = IslandDetails.Name
		newIsland.LayoutOrder = i
		newIsland.Parent = IndexPage.List
	end

	local oldPets = {
		"Cat","Dog","Rabbit","Dinosaur","Unicorn","Panda"
	}

	for i,v in pairs (oldPets) do
		local folder = Assets.Pets:FindFirstChild(v)
		if folder then
			local newIsland = IndexPage.List.Island:Clone()
			for i,v in pairs (folder:GetChildren()) do
				local Template = Dependency.ShopTemplate:Clone()
				Template.Amount.Text = ""
				Template.Icon.Visible = false
				Template.ViewportFrame.Visible = true
				local model = v:Clone()
				Template.PetName.Text = v.Name
				addPetToViewport(model,Template.ViewportFrame)
				Template.Parent = newIsland.Pets.Pets
			end

			newIsland.TopText.Text = "Legacy Pets: "..v
			newIsland.LayoutOrder = 1000+i
			newIsland.Visible = true
			newIsland.Name = "Legacy Pets: "..v
			newIsland.Parent = IndexPage.List
		end
	end

	IndexPage.List.CanvasSize = UDim2.new(0, 0, 0, IndexPage.List.UIGridLayout.AbsoluteContentSize.Y+(#IndexPage.List:GetChildren()*25))
	IndexPage.List.UIGridLayout.CellSize = UDim2.new(1.15,-4,0.07,0)


	local tycoonData = Remotes.GetStat:InvokeServer("Tycoon")
	for i,v in pairs (UI.Center.UnlockedEggs.Eggs.Pets:GetChildren()) do
		if v:IsA("ImageButton") then
			print(v,tycoonData[v.Name])
			if tycoonData[v.Name] or v.Name == "1" then
				v:SetAttribute("Unlocked",true)
				v.MouseButton1Down:Connect(function()
					if tycoonData[v.Name] or v.Name == "1" then
						Pets.LoadEgg(v:GetAttribute("Egg"),nil)
					end
				end)
			else
				v.ViewportFrame.ImageColor3 = Color3.new(0,0,0)
			end
		end
	end
end)

return Pets
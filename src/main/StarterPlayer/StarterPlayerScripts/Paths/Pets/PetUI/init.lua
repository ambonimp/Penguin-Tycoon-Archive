local PetUI = {}
local Paths = require(script.Parent.Parent)

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local PetModels = Assets:WaitForChild("Pets")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetStat = Remotes:WaitForChild("GetStat")
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local EggsModule = require(Modules:WaitForChild("Eggs"))
local EquipPetRemote = Remotes:WaitForChild("EquipPet")
local UnequipPetRemote = Remotes:WaitForChild("UnequipPet")

local PetData 

local Connections = {}
local InputConnections = {}

local loadedEgg = nil

local PetButtonTemplate = Dependency.Template

--Adds the pet to viewports
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

--called to clean any connections that wouldn't be cleaned otherwise
function PetUI.CleanConnections()
	for i,v in pairs (Connections) do
		v:Disconnect()
	end
end

function PetUI.CleanInputConnections()
	for i,v in pairs (InputConnections) do
		v:Disconnect()
	end
end

function makeRed(button)
	button.BackgroundColor3 = Color3.fromRGB(255, 66, 66)
	button.UIStroke.Color = Color3.fromRGB(255, 53, 53)	
end

function makeGreen(button)
	button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	button.UIStroke.Color = Color3.fromRGB(85, 255, 127)	
end

--Updates the pet data to the current data
function PetUI.UpdatePetData()
	PetData = GetStat:InvokeServer("Pets")
end

--handle Pet Info inventory where you can summon and unsummon pets
function PetUI.Inventory(Paths)
	PetUI.UpdatePetData() --update player data from server
	local Backpack = Paths.UI.Center.Backpack
	local Buttons = {
		[Backpack.Toys] = Backpack.Items.Toys,
		[Backpack.Foods] = Backpack.Items.Foods,
		[Backpack.Pets] = Backpack.Items.Pets,
	}
	local CurrentlyOpen = Backpack.Items.Pets
	local CurrentButton = Backpack.Pets
	
	--make buttons selected or not
	local function makeSelected(button)
		button.BackgroundColor3 = Color3.fromRGB(117, 117, 117)
		button.UIStroke.Color = Color3.fromRGB(255, 255, 255)	
	end

	local function makeUnselected(button)
		button.BackgroundColor3 = Color3.fromRGB(23, 166, 255)
		button.UIStroke.Color = Color3.fromRGB(117, 230, 255)	
	end
	
	-- open frame of button clicked
	local function openFrame(Button,Frame)
		if CurrentlyOpen == Frame then
			return
		else
			--Out
			CurrentlyOpen:TweenPosition(UDim2.new(0.5, 0, 1.7, 0), "Out", "Quart", 0.2, true)

			-- In
			Frame.Position = UDim2.new(0.5, 0, 1.7, 0)
			Frame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quart", 0.2, true)
			Frame.Visible = true
			makeUnselected(CurrentButton)
			makeSelected(Button)
			CurrentButton = Button
			task.wait(0.15)
			CurrentlyOpen.Visible = false
			CurrentlyOpen = Frame
		end
	end
	
	for Button,Frame in pairs (Buttons) do
		Button.MouseButton1Click:Connect(function()
			openFrame(Button,Frame)
		end)
	end
	--[[
	do --Foods in the backpack
		local FoodDetails = require(Modules.FoodDetails)
		local FoodFrame = Backpack.Items.Foods
		local OwnedFoods = PetData.Food
		
		local function addToFood(Model,Name,ID,Amount,Hunger)
			local Button = PetButtonTemplate:Clone()
			addPetToViewport(Model,Button.ViewportFrame)
			Button.LayoutOrder = ID
			Button.Visible = true
			Button.Amount.Text = Amount > 0 and "x"..Amount or ""
			Button.Amount.Visible = true
			Button.Name = Name
			Button.ItemName.Visible = true
			Button.ItemName.Text = Name..": <font color=\"#00FF00\">+"..Hunger.."</font>"
			
			Button.Parent = FoodFrame

			Button.MouseButton1Click:Connect(function()
				
			end)
		end
		
		for i,Food in pairs (OwnedFoods) do
			local Name = Food.Name
			local Amount = Food.Amount
			local ID = i
			local Model = Assets.Foods:FindFirstChild(Name)
			addToFood(Model,Name,ID,Amount,FoodDetails[Name].Hunger)
		end
		
		local function resize()
			if FoodFrame and FoodFrame:FindFirstChild("UIGridLayout") then
				FoodFrame.CanvasSize = UDim2.new(0,0,0,FoodFrame.UIGridLayout.AbsoluteContentSize.Y+90)
			end
		end
		
		FoodFrame.ChildAdded:Connect(resize)
		FoodFrame.ChildRemoved:Connect(resize)
		
		resize()
	end
	
	do --Toys in the backpack
		local ToyDetails = require(Modules.ToyDetails)
		local ToyFrame = Backpack.Items.Toys
		local OwnedToys = PetData.Toys

		local function addToToys(Model,Name,ID,Entertainment)
			local Button = PetButtonTemplate:Clone()
			addPetToViewport(Model,Button.ViewportFrame)
			Button.LayoutOrder = ID
			Button.Visible = true
			Button.Name = Name
			Button.ItemName.Visible = true
			Button.ItemName.Text = Name..": <font color=\"#00FF00\">+"..Entertainment.."</font>"

			Button.Parent = ToyFrame

			Button.MouseButton1Click:Connect(function()

			end)
		end

		for i,Toy in pairs (OwnedToys) do
			local Name = Toy.Name
			local ID = i
			local Model = Assets.Toys:FindFirstChild(Name)
			addToToys(Model,Name,ID,ToyDetails[Name].Entertainment)
		end

		local function resize()
			if ToyFrame and ToyFrame:FindFirstChild("UIGridLayout") then
				ToyFrame.CanvasSize = UDim2.new(0,0,0,ToyFrame.UIGridLayout.AbsoluteContentSize.Y+90)
			end
		end

		ToyFrame.ChildAdded:Connect(resize)
		ToyFrame.ChildRemoved:Connect(resize)

		resize()
	end--]]
	
	do -- Pets frame in backpack

		local PetInfo = Paths.UI.Center.Pets--Backpack.Items.Pets
		local PetsFrame = PetInfo.Pets
		--the current pet ID of the selected pet, used for summoning 
		local PetSelected = nil
		
		--shows the pet in the viewport and changes the name
		local function showPet(Model,Name,ID,Gender)
			PetInfo.PetName.Text = Name
			PetInfo.Gender.Image = Gender == "Male" and "rbxassetid://9184801717" or "rbxassetid://9184801545"
			PetInfo.Gender.ImageColor3 = Gender == "Male" and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 85, 255)
			addPetToViewport(Model,PetInfo.PetFrame.ViewportFrame)

			if Player:GetAttribute("PetID") == ID then
				PetInfo.Summon.Text.Text = "Unsummon"
				makeRed(PetInfo.Summon)
			else
				PetInfo.Summon.Text.Text = "Summon"
				makeGreen(PetInfo.Summon)
			end

			PetSelected = ID
		end
		
		--add button of pet to scroll frame and handle click
		local function addToInventory(Model,Name,ID,Gender)
			PetInfo.GetPets.Visible = false
			local Button = PetButtonTemplate:Clone()
			addPetToViewport(Model,Button.ViewportFrame)
			Button.LayoutOrder = ID
			Button.Name = ID
			Button.Visible = true
			Button.Parent = PetsFrame.Pets
			
			Button.MouseButton1Click:Connect(function()
				local newname 
				for i,v in pairs (PetData.PetsOwned) do
					if v.ID == ID then
						newname = v.Name
						break
					end
				end
				showPet(Model,newname,ID,Gender)
			end)
		end
		
		local function addNewPet()
			PetInfo.GetPets.Visible = false
			for i,Pet in pairs (PetData.PetsOwned) do
				if PetsFrame.Pets:FindFirstChild(Pet.ID) == nil then
					local ID = Pet.ID
					local Name = Pet.Name
					local RealName = Pet.RealName
					local Gender = Pet.Gender
					local Model = PetModels:FindFirstChild(RealName)
					addToInventory(Model,Name,ID,Gender)

					if i == 1 then
						showPet(Model,Name,ID,Gender)
					end
				end
			end
		end
		
		local function updatePet(ID)
			if PetSelected == ID then
				for i,Pet in pairs (PetData.PetsOwned) do
					if ID == Pet.ID then
						PetInfo.PetName.Text = Pet.Name
						break
					end
				end
			end
		end
		
		local function removePet(ID)
			if PetSelected == ID then
				for i,Pet in pairs (PetData.PetsOwned) do
					local ID = Pet.ID
					local Name = Pet.Name
					local RealName = Pet.RealName
					local Gender = Pet.Gender
					local Model = PetModels:FindFirstChild(RealName)
					
					if i == 1 then
						showPet(Model,Name,ID,Gender)
					end
				end
			end
			if PetsFrame.Pets:FindFirstChild(ID) then
				PetsFrame.Pets:FindFirstChild(ID):Destroy()
			end
		end
		
		Remotes.NewPet.OnClientEvent:Connect(function(Data)
			PetData = Data
			addNewPet()
		end)
		
		Remotes.UpdatePetName.OnClientEvent:Connect(function(Data,ID,NewName)
			PetData = Data
			updatePet(ID)
			if Paths.UI.Center.PetStats:GetAttribute("PetID") == ID then
				Paths.UI.Center.PetStats.PetName.Text = NewName
			end
		end)
		
		
		
		PetInfo.GetPets.MouseButton1Click:Connect(function()
			Paths.Modules.Buttons:UIOff(PetInfo,true)
			if Paths.Tycoon then
				Player.Character:MoveTo(Paths.Tycoon:WaitForChild("BuyEgg"):WaitForChild("Hitbox").Position)
			elseif workspace:FindFirstChild("PetShop") then
				Player.Character:MoveTo(workspace:FindFirstChild("PetShop"):WaitForChild("BuyEgg"):WaitForChild("Hitbox").Position)
			end
		end)
		
		PetInfo.Certificate.MouseButton1Click:Connect(function()
			local petData = {}
			for i,v in pairs (PetData.PetsOwned) do
				if v.ID == PetSelected then
					petData = v
					break
				end
			end
			Paths.UI.Center.Certificate.Last.Value = PetInfo
			Paths.Modules.Buttons:UIOff(PetInfo,false)
			PetUI.OpenPetCertificate(petData,Paths)
		end)
		
		--Fire to server to summon or unsummon a pet.
		PetInfo.Summon.MouseButton1Click:Connect(function()
			if PetInfo.Summon.Text.Text == "Unsummon" then
				UnequipPetRemote:FireServer()
				PetInfo.Summon.Text.Text = "Summon"
				makeGreen(PetInfo.Summon)
			elseif PetInfo.Summon.Text.Text == "Summon" then
				EquipPetRemote:FireServer(PetSelected)
				PetInfo.Summon.Text.Text = "Unsummon"
				makeRed(PetInfo.Summon)
			end
		end)
		--cycle through the owned pets, and show the first pet in the table in the UI
		
		for i,Pet in pairs (PetData.PetsOwned) do
			local ID = Pet.ID
			local Name = Pet.Name
			local RealName = Pet.RealName
			local Gender = Pet.Gender
			local Model = PetModels:FindFirstChild(RealName)
			addToInventory(Model,Name,ID,Gender)

			if i == 1 then
				PetInfo.Certificate.Visible = true
				showPet(Model,Name,ID,Gender)
			end
			--task.wait(.15)
		end
		local function resize()
			if PetsFrame and PetsFrame:FindFirstChild("Pets") and PetsFrame:FindFirstChild("Pets"):FindFirstChild("UIGridLayout") then
				PetsFrame.Pets.CanvasSize = UDim2.new(0,0,0,PetsFrame.Pets.UIGridLayout.AbsoluteContentSize.Y+60)
			end
		end

		PetsFrame.Pets.ChildAdded:Connect(resize)
		PetsFrame.Pets.ChildRemoved:Connect(resize)

		resize()
		
	end
end

--sets the progress bar size
function setBarSize(ui,per)
	local bar = ui.Bar
	if per then
		if per < 5 then
			bar:TweenSize(UDim2.fromScale(.05,1),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.25,true)
		else
			bar:TweenSize(UDim2.fromScale(per/100,1),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.25,true)
		end
	end
end

--load egg into egg buying ui
function PetUI.LoadEgg(Egg,Paths)
	PetUI.CleanInputConnections()
	local EggUI = Paths.UI.Center.BuyEgg
	local RarityTemplate = Dependency.RarityTemplate
	local Template = Dependency.PetTemplate
	local EggDetails = EggsModule.Eggs[Egg]
	EggUI.Gems.Text.Text = EggDetails.PriceGems
	EggUI.Robux.Text.Text = EggDetails.PriceRobux

	local rarityColorSelected = false
	local justClicked = false
	table.insert(InputConnections,EggUI.Gems.MouseButton1Down:Connect(function()
		if justClicked then return end
		justClicked = true
		EggUI.Visible = false
		local Bought,Pets,RealPet,PetID,UserData = Remotes.BuyPet:InvokeServer(Egg)
		if Bought and Pets and RealPet and PetID and UserData then
			spawn(function()
				wait(.5)
				justClicked = false
			end)
			PetUI.DoAdoption(Pets,Paths,RealPet,PetID,UserData)
		elseif Bought == "Not Enough" then
			spawn(function()
				wait(.5)
				justClicked = false
			end)
			EggUI.Gems.Text.Text = "Not Enough"
			EggUI.Visible = true
			wait(1)
			if EggUI.Gems.Text.Text == "Not Enough" then
				EggUI.Gems.Text.Text = EggDetails.PriceGems
			end
		end
	end))
	
	table.insert(InputConnections,EggUI.Robux.MouseButton1Down:Connect(function()
		EggUI.Visible = false
		local id = EggDetails.DevId
		MarketplaceService:PromptProductPurchase(Player,id)
	end))

	if loadedEgg == Egg then return end
	loadedEgg = Egg
	
	for i,v in pairs (EggUI.Pets.Pets:GetChildren()) do
		if v:IsA("ImageButton") then
			v:Destroy()
		end
	end
	--loops through all the pets and their rarities
	for Name,Rarity in pairs (EggDetails.Pets) do
		local newButton = Template:Clone()
		local pets = EggsModule.Pets[Name]
		
		local petNames = {}
		
		for i,v in pairs (pets) do
			table.insert(petNames,i) --gets all the possible colors per pet 
		end
		
		addPetToViewport(Assets.Pets:FindFirstChild(petNames[1]),newButton.ViewportFrame)
		--changes rarity icon based on rarity number
		if Rarity >= 25 then
			newButton.Common.Visible = true
		elseif Rarity >= 15 then
			newButton.Common.Visible = false
			newButton.Uncommon.Visible = true
		elseif Rarity >= 5 then
			newButton.Common.Visible = false
			newButton.Uncommon.Visible = false
			newButton.Rare.Visible = true
		elseif Rarity >= 0 then
			newButton.Rare.Visible = false
			newButton.Common.Visible = false
			newButton.Uncommon.Visible = false
			newButton.Ultra.Visible = true
		end
		newButton.PetName.Text = Name
		newButton.Amount.Text = Rarity.."%"
		newButton.LayoutOrder = 100-Rarity
		newButton.Visible = true
		newButton.Parent = EggUI.Pets.Pets
		EggUI.RaritiesExit.MouseButton1Click:Connect(function()
			for i,v in pairs (EggUI.Rarities:GetChildren())  do
				if v:IsA("ImageButton") then
					v:Destroy()
				end
			end
			EggUI.RaritiesExit.Visible = false
			EggUI.Rarities.Visible = false
		end)
		newButton.MouseButton1Click:Connect(function()
			if rarityColorSelected == Name then
				rarityColorSelected = nil
				EggUI.RaritiesExit.Visible = false
				EggUI.Rarities.Visible = false
				return
			end
			for i,v in pairs (EggUI.Rarities:GetChildren())  do
				if v:IsA("ImageButton") then
					v:Destroy()
				end
			end
			
			for Pet,Rarity in pairs (pets) do
				local newColor = RarityTemplate:Clone()
				addPetToViewport(Assets.Pets:FindFirstChild(Pet),newColor.ViewportFrame)
				newColor.PetName.Text = Pet
				newColor.Amount.Text = Rarity.."%"
				newColor.LayoutOrder = 100-Rarity
				newColor.Visible = true
				newColor.Parent = EggUI.Rarities
			end
			rarityColorSelected = Name
			EggUI.RaritiesExit.Visible = true
			EggUI.Rarities.Visible = true
		end)
	end
end

Remotes:WaitForChild("BuyPetProduct").OnClientEvent:Connect(function(Pets,RealPet,PetID,UserData)
	PetUI.DoAdoption(Pets,Paths,RealPet,PetID,UserData)
end)

function PetUI.OpenPetCertificate(PetData,Paths)
	local Certificate = Paths.UI.Center.Certificate
	
	addPetToViewport(Assets.Pets:FindFirstChild(PetData.RealName),Certificate.PetFrame.ViewportFrame)
	Certificate.Date.Text = "<font color=\"#fd6dfa\">ADOPTED:</font> "..PetData.Adopted
	Certificate.Food.Text = "<font color=\"#fd6dfa\">FAVORITE FOOD:</font> "..PetData.FavFood
	Certificate.Toy.Text = "<font color=\"#fd6dfa\">FAVORITE TOY:</font> "..PetData.FavToy
	Certificate.Personality.Text = "<font color=\"#fd6dfa\">PERSONALITY:</font> "..PetData.Personality
	Certificate.PetName.Text = PetData.Name
	Certificate.Gender.Image = PetData.Gender == "Male" and "rbxassetid://9184801717" or "rbxassetid://9184801545"
	Certificate.Gender.ImageColor3 = PetData.Gender == "Male" and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 85, 255)
	game.Players.LocalPlayer:SetAttribute("BuyingEgg",false)
	Paths.Modules.Buttons:UIOn(Certificate,true)
end

--handles post adoption animation UI
function PetUI.AdoptionUI(Paths,PetID,UserData)
	game:GetService("StarterGui"):SetCore("ResetButtonCallback",true)
	local RandomNames = require(script.RandomNames)
	local Cons = {}
	local pet
	for i,v in pairs (UserData.PetsOwned) do 
		if v.ID == PetID then 
			pet = v
			break
		end
	end
	local AdoptionUI = Paths.UI.Center.Adoption
	AdoptionUI.AdoptFrame.Visible = true
	AdoptionUI.Exit.Visible = false
	AdoptionUI.AdoptFrame.PetName.TextBox.Text = ""
	
	AdoptionUI.Gender.Image = pet.Gender == "Male" and "rbxassetid://9184801717" or "rbxassetid://9184801545"
	AdoptionUI.Gender.ImageColor3 = pet.Gender == "Male" and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 85, 255)	
	
	AdoptionUI.AdoptFrame.RandomName.MouseButton1Click:Connect(function()
		AdoptionUI.AdoptFrame.PetName.TextBox.Text = RandomNames[math.random(1,#RandomNames)]
	end)
	
	AdoptionUI.AdoptFrame.PetName.TextBox.PlaceholderText = RandomNames[math.random(1,#RandomNames)]
	
	local model = Assets.Pets:FindFirstChild(pet.RealName)
	addPetToViewport(model,AdoptionUI.AdoptFrame.PetFrame.ViewportFrame)
	
	
	local function showAdoptSuccess(name)
		Paths.Modules.Buttons:UIOff(AdoptionUI,false)
		local petdata = nil
		for i,v in pairs (UserData.PetsOwned) do
			if v.ID == PetID then
				petdata = v
				petdata.Name = name
				break
			end
		end
		Dependency.Sounds.AdoptFinished:Play()
		Paths.UI.Center.Certificate.Last.Value = nil
		PetUI.OpenPetCertificate(petdata,Paths)
		AdoptionUI.Exit.Visible = true
		Remotes.UpdatePetName:FireServer(PetID,name,true)
		for i,v in pairs (Cons) do
			v:Disconnect()
		end
		Paths.UI.Left.Visible = true
		Paths.UI.Right.Visible = true
		Paths.UI.Bottom.Visible = true
		Paths.UI.Top.Visible = true
	end
	
	table.insert(Cons,AdoptionUI.AdoptFrame.Adopt.MouseButton1Click:Connect(function()
		if #AdoptionUI.AdoptFrame.PetName.TextBox.Text > 1 and #AdoptionUI.AdoptFrame.PetName.TextBox.Text <= 15 then
			local str = Remotes.FilterString:InvokeServer(AdoptionUI.AdoptFrame.PetName.TextBox.Text)
			AdoptionUI.AdoptFrame.PetName.TextBox.Text = str
			if string.find(str,"#") then
				AdoptionUI.AdoptFrame.Adopt.Text.Text = "Censored Name"
				wait(1)
				if AdoptionUI.AdoptFrame.Adopt.Text.Text == "Censored Name" then
					AdoptionUI.AdoptFrame.Adopt.Text.Text = "Confirm adoption!"
				end
				return
			else
				showAdoptSuccess(str)
			end
		elseif #AdoptionUI.AdoptFrame.PetName.TextBox.Text > 15 then
			AdoptionUI.AdoptFrame.Adopt.Text.Text = "Name Too Long"
			wait(1)
			if AdoptionUI.AdoptFrame.Adopt.Text.Text == "Name Too Long" then
				AdoptionUI.AdoptFrame.Adopt.Text.Text = "Confirm adoption!"
			end
		else
			showAdoptSuccess(AdoptionUI.AdoptFrame.PetName.TextBox.PlaceholderText)
		end
	end))
	
	Paths.Modules.Buttons:UIOn(AdoptionUI,true)
end

--pet adoption handling
function PetUI.DoAdoption(Pets,Paths,RealPet,PetID,UserData)
	game:GetService("StarterGui"):SetCore("ResetButtonCallback",false)
	PetUI.CleanInputConnections()
	local CAM_CF = workspace.CurrentCamera.CFrame
	Paths.Modules.Buttons:UIOff(Paths.UI.Center.BuyEgg,true)
	Paths.Modules.Buttons:UIOff(Paths.UI.Center.Pets,true)
	--Paths.UI.Center.BuyEgg.Visible = false
	Paths.UI.Bottom.Visible = false
	Paths.UI.Left.Visible = false
	Paths.UI.Right.Visible = false
	Paths.UI.Top.Visible = false
	local SelectedPet = nil
	local DidSelection = false
	local EggMesh = Assets.Egg1:Clone()
	local PetAdoptionUI = Paths.UI.Full.PetAdoption
	PetAdoptionUI.Gender.Image = ""
	PetAdoptionUI.Visible = true
	local PetAdoptionIsland = Assets.PetAdoption:Clone()
	local PetNet = Assets.PetNet:Clone()
	local Camera = workspace.CurrentCamera
	local InfoTween = TweenInfo.new(.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
	--CFrame of the camera view for the PetAdoption island ||  ReplicatedStorage.Assets.PetAdoption
	local AdoptionCamCFrame = CFrame.new(-1836.48792, 25.122879, 26916.9941, 0.738559663, -0.496195316, 0.456420749, 1.4901163e-08, 0.676993191, 0.735989332, -0.674188197, -0.543572009, 0.499999821)
	
	PetNet.Parent = PetAdoptionUI.ViewportFrame
	local VPCamera = PetAdoptionUI.ViewportFrame.CurrentCamera or Instance.new("Camera")
	VPCamera.CFrame = AdoptionCamCFrame
	VPCamera.Parent = PetAdoptionUI.ViewportFrame
	PetAdoptionUI.ViewportFrame.CurrentCamera = VPCamera
	--Clone the island to workspace
	PetAdoptionIsland.Parent = workspace
	
	--Move camera to cframe
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = AdoptionCamCFrame
	spawn(function()
		PetAdoptionUI.Text.Visible = true
		PetAdoptionUI.Text:TweenSizeAndPosition(UDim2.new(.6,0,.15,0),UDim2.new(.5,0,.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,.35,true)
		wait(1)
		PetAdoptionUI.Text:TweenSizeAndPosition(UDim2.new(.4,0,.1,0),UDim2.new(.5,0,.1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,1,true)
		wait(1)
	end)
	
	--make sure adoption is all cleaned up
	local function clean()
		if PetAdoptionIsland then
			PetAdoptionIsland:Destroy()
		end
		if PetNet then
			PetNet:Destroy()
		end
		Camera.CameraType = Enum.CameraType.Custom
	end
	
	--Handle moving Net in viewport frame
	local function LocalPos(Pos,Viewport)
		return Pos - Viewport.AbsolutePosition --- Return Position - vpf.AbsPos
	end

	local function ScreenToWorldSpace(Pos, viewport, camera, Depth, Gui_Inset)
		Pos =  LocalPos(Vector2.new(Pos.X, Pos.Y ), viewport) -- Make mouse position "local"
		local Cam_Size = Vector2.new(viewport.AbsoluteSize.X , viewport.AbsoluteSize.Y - (Gui_Inset or 0))
		local Height = Cam_Size.Y
		local Width = Cam_Size.X	
		local AspectRatio = (Cam_Size.X/Cam_Size.Y)
		local Cam_Pos = camera.CFrame.Position 
		local Scale = (Depth or 1) 
		local fov  =math.rad(camera.FieldOfView)
		local Tangent = math.tan((fov/2));
		local fx = ((2 * Scale) * (Pos.x /(Width-1)) -(Scale*1))
		local fy = ((2 * Scale) * (Pos.y/(Height-1)) -(Scale*1))
		local NX = ((AspectRatio * Tangent * fx ))
		local NY = (-Tangent * fy)
		local NZ = -Scale 
		local Translatedcf = (camera.CFrame) * CFrame.new(Vector3.new(NX, NY, NZ))  -- rotate rel to camera
		return CFrame.new( Translatedcf.Position, camera.CFrame.Position  ) -- rotate to face camera
	end 
	
	--Egg open animation
	local function openEgg()
		local startDistance = -13
		EggMesh.Parent = PetAdoptionUI.ViewportFrame
		EggMesh:SetPrimaryPartCFrame(PetNet.PET.CFrame)
		local default = AdoptionCamCFrame*CFrame.new(0,0,startDistance)
		local fakeCFrameEgg = Instance.new("CFrameValue")
		fakeCFrameEgg.Value = EggMesh:GetPrimaryPartCFrame()
		fakeCFrameEgg:GetPropertyChangedSignal("Value"):Connect(function()
			if EggMesh and EggMesh.PrimaryPart then
				EggMesh:SetPrimaryPartCFrame(fakeCFrameEgg.Value)
			end
		end)
		wait(.25)
		local tweenLeft = TweenService:Create(fakeCFrameEgg,TweenInfo.new(1,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{
			Value = AdoptionCamCFrame*CFrame.new(0,0,startDistance)
		})
		tweenLeft:Play()
		wait(1)
		local speed = .3
		Dependency.Sounds.Cracking:Play()
		for i = 1,2 do
			local wa = math.random(10,20)/100/speed
			local tweenLeft = TweenService:Create(fakeCFrameEgg,TweenInfo.new(wa,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{
				Value = default*CFrame.new(0,0,math.random(0,5))*CFrame.Angles(math.rad(math.random(30,60)),0,math.rad(math.random(30,60)))
			})
			tweenLeft:Play()
			task.wait(wa)
			local wa2 = math.random(10,20)/100/speed
			local tweenRight = TweenService:Create(fakeCFrameEgg,TweenInfo.new(wa2,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{
				Value = default*CFrame.new(0,0,math.random(0,5))*CFrame.Angles(math.rad(math.random(30,60)*-1),0,math.rad(math.random(30,60)*-1))
			})
			tweenRight:Play()
			task.wait(wa2)
			speed = speed * 1.5
		end
		local wa = math.random(10,20)/100/speed*2
		local tweenLeft = TweenService:Create(fakeCFrameEgg,TweenInfo.new(wa,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
			Value = default*CFrame.new(0,0,11)
		})
		tweenLeft:Play()
		task.wait(wa*.9)
	end
	
	local fakeCFrame = Instance.new("CFrameValue")
	
	fakeCFrame:GetPropertyChangedSignal("Value"):Connect(function()
		PetNet:SetPrimaryPartCFrame(fakeCFrame.Value)
	end)
	
	local function moveNet()
		local FRONT = Vector3.new(0, 0, -1)
		local cf, rot =  ScreenToWorldSpace(Vector2.new(Mouse.X, Mouse.Y) ,PetAdoptionUI.ViewportFrame, game.Workspace.Camera)
		local FowardDir = cf:VectorToWorldSpace(-FRONT)
		local mouseRay  = Ray.new(cf.Position, FowardDir * 10)
		local target, hit = workspace:FindPartOnRay(mouseRay)
		if hit and DidSelection == false then
			local cf 
			if Mouse.X > Paths.UI.Main.AbsoluteSize.X/2 then
				cf = (CFrame.new(hit)*CFrame.Angles(math.rad(-30),math.rad(140),math.rad(120)))
			else
				cf = (CFrame.new(hit)*CFrame.Angles(math.rad(30),math.rad(140),math.rad(90)))
			end
			local tween = TweenService:Create(fakeCFrame,InfoTween,{
				Value = cf
			})
			tween:Play()
		end
	end
	
	--Spawn the pets around the cage
	local PartSpawns = PetAdoptionIsland.Spawns:GetChildren()
	local Spawns = {}
	local Animations = {}
	
	local function getRandomSpawn()
		local n = math.random(1,#PartSpawns)
		while table.find(Spawns,PartSpawns[n]) do
			n = n + 1
			if n > #PartSpawns then
				n = 1
			end
		end
		table.insert(Spawns,PartSpawns[n])
		return PartSpawns[n]
	end
	
	for i,Pet in pairs (Pets) do
		local spawn_ = getRandomSpawn()
		local Model = PetModels:FindFirstChild(Pet):Clone()
		Model:SetPrimaryPartCFrame(spawn_.CFrame)
		Model.PrimaryPart.CanCollide = true
		--Model.PrimaryPart.PetName:Destroy()
		Model.Name = i
		Model.Parent = spawn_
		Animations[Model] = {Jump = Model.AnimationController:LoadAnimation(Model.Animations.Jump), Idle = Model.AnimationController:LoadAnimation(Model.Animations.Idle)}
		Animations[Model].Idle:Play()
	end
	
	moveNet()
	
	local function adopt()
		PetAdoptionUI.Text.Visible = false
		PetAdoptionUI.Text:TweenSizeAndPosition(UDim2.new(.3,0,.15,0),UDim2.new(.5,0,.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.1,true)
		RunService:UnbindFromRenderStep("NetMove")
		DidSelection = true
		PetUI.CleanInputConnections()
		local tween = TweenService:Create(fakeCFrame,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
			Value = AdoptionCamCFrame*CFrame.new(0,-2,-17) * CFrame.Angles(math.rad(-90),math.rad(-90),math.rad(90))
		})
		tween:Play()
		wait(.8)
		
		openEgg()
		
		local pet = Assets.Pets:FindFirstChild(RealPet):Clone()
		pet.Parent = PetAdoptionUI.ViewportFrame.WorldModel
		local Animations = {Jump = pet.AnimationController:LoadAnimation(pet.Animations.Jump), Idle = pet.AnimationController:LoadAnimation(pet.Animations.Idle)}
		
		pet:SetPrimaryPartCFrame(AdoptionCamCFrame*CFrame.new(0,0,-13)*CFrame.Angles(0,math.rad(180),0))
		
		local fakePetCFrame = Instance.new("CFrameValue")

		fakePetCFrame:GetPropertyChangedSignal("Value"):Connect(function()
			if pet and pet.PrimaryPart then
				pet:SetPrimaryPartCFrame(fakePetCFrame.Value)
			end
		end)
		fakePetCFrame.Value = pet:GetPrimaryPartCFrame()
		local showing = true
		
		PetNet:Destroy()
		EggMesh:Destroy()
		wait(.1)
		Dependency.Sounds.Cracking:Stop()
		Dependency.Sounds.Ring:Play()
		Animations.Idle:Play()
		Animations.Jump:Play()
		local tween = TweenService:Create(fakePetCFrame,TweenInfo.new(1,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{
			Value = AdoptionCamCFrame*CFrame.new(0,0,-6)*CFrame.Angles(0,math.rad(180),0)
		})
		tween:Play()
		local rotation = 0
		local petdata = {}
		for i,v in pairs (UserData.PetsOwned) do
			if v.ID == PetID then
				petdata = v
				break
			end
		end
		PetAdoptionUI.Gender.Image = petdata.Gender == "Male" and "rbxassetid://9184801717" or "rbxassetid://9184801545"
		PetAdoptionUI.Gender.ImageColor3 = petdata.Gender == "Male" and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 85, 255)

		PetAdoptionUI.PetName.Text = RealPet
		PetAdoptionUI.PetName.Size = UDim2.fromScale(.3,0.042)
		PetAdoptionUI.Continue.Size = UDim2.fromScale(.134,.054)
		PetAdoptionUI.Continue:TweenSizeAndPosition(UDim2.new(.204,0,.082,0),UDim2.new(0.5, 0,0.757, 0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.125,true)
		PetAdoptionUI.PetName:TweenSizeAndPosition(UDim2.new(.3,0,.108,0),UDim2.new(.5,0,.125,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.125,true)
		PetAdoptionUI.PetName.Visible = true
		PetAdoptionUI.Continue.Visible = true
		wait(.6)
		Animations.Jump:Stop()
		spawn(function()
			PetAdoptionUI.Continue.MouseButton1Click:wait()
			showing = false
		end)
		wait(.6)
		while showing do
			rotation = rotation + 1
			local tween = TweenService:Create(fakePetCFrame,TweenInfo.new(.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				Value = AdoptionCamCFrame*CFrame.new(0,0,-6)*CFrame.Angles(0,math.rad(180+rotation),0)
			})
			tween:Play()
			RunService.RenderStepped:Wait()
		end
		pet:Destroy()
		PetAdoptionUI.PetName.Visible = false
		PetAdoptionUI.Continue.Visible = false
		PetAdoptionUI.Visible = false
		workspace.CurrentCamera.CFrame = CAM_CF
		clean()
		PetUI.AdoptionUI(Paths,PetID,UserData)
	end
	--Moves the net to the mouse
	local alreadyHovering = false
	RunService:BindToRenderStep("NetMove",Enum.RenderPriority.First.Value,function()
		if DidSelection then return end
		if alreadyHovering == false and Mouse.Target and Mouse.Target.Parent:FindFirstChildOfClass("AnimationController") then
			local Model = Mouse.Target.Parent
			alreadyHovering = true
			SelectedPet = tonumber(Model.Name)
			while Mouse.Target and Mouse.Target.Parent == Model and not DidSelection do
				Animations[Model].Jump:Play()
				wait(1)
				Animations[Model].Jump:Stop()
				if Mouse.Target and Mouse.Target.Parent == Model and not DidSelection then
					wait(1)
				end
			end
			Animations[Model].Jump:Stop()
			if DidSelection == false then
				alreadyHovering = false
				SelectedPet = nil
			end
		end 
		moveNet()
	end)
	
	wait(1)
	table.insert(InputConnections,UserInputService.InputEnded:Connect(function(Input,GPE)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch or Input.KeyCode == Enum.KeyCode.ButtonA then
			Dependency.Sounds.Swoosh:Play()
			adopt()
		end
	end))
end

--Pet Interaction UI handling
function PetUI.StartInteractPetUI(Pet,Paths,ScriptModules,ThrowFunction,FeedFunction,sitPet,playerInBoat)
	Mouse.TargetFilter = Pet[3] -- filter in the mouse the part used to control the pet's movement
	local Character = Pet[2]
	local PetModel = Pet[1]
	local PetStats = Paths.UI.Center.PetStats
	local interacting = false
	local justclosed = false
	local petData = {}
	if PetData == nil then
		PetUI.UpdatePetData()
	end
	for i,v in pairs (PetData.PetsOwned) do
		if v.ID == Player:GetAttribute("PetID") then
			petData = v
			break
		end
	end
	
	PetStats.Certificate.MouseButton1Click:Connect(function()
		local petData = {}
		if PetData == nil then
			PetUI.UpdatePetData()
		end
		for i,v in pairs (PetData.PetsOwned) do
			if v.ID == Player:GetAttribute("PetID") then
				petData = v
				break
			end
		end
		Paths.UI.Center.Certificate.Last.Value = PetStats
		Paths.Modules.Buttons:UIOff(PetStats,false)
		PetUI.OpenPetCertificate(petData,Paths)
	end)
	
	PetStats.Gender.Image = petData.Gender == "Male" and "rbxassetid://9184801717" or "rbxassetid://9184801545"
	PetStats.Gender.ImageColor3 = petData.Gender == "Male" and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 85, 255)
	PetStats.PetName.Text = Player:GetAttribute("PetName")
	
	addPetToViewport(PetModel,PetStats.PetFrame.ViewportFrame)
	
	local function changeHappinessIcon()
		local icons = {
			[6] = {"rbxassetid://9184554398",90},
			[5] = {"rbxassetid://9184554810",70},
			[4] = {"rbxassetid://9184554646",50},
			[3] = {"rbxassetid://9184555092",30},
			[2] = {"rbxassetid://9184554961",15},
			[1] ={ "rbxassetid://9184555197",0},
		}
		for i = 1,6 do
			local v = icons[i]
			if (Player:GetAttribute("PetHappiness") or 0) >= v[2] then
				PetStats.HappyIcon.Image = v[1]
			end
		end
	end
	
	--detect changes in hunger and entertainment
	table.insert(Connections,Player:GetAttributeChangedSignal("PetHunger"):Connect(function()
		setBarSize(PetStats.BarHunger,Player:GetAttribute("PetHunger") or 0)
		setBarSize(PetStats.BarHappiness,Player:GetAttribute("PetHappiness") or 0)
		changeHappinessIcon()
	end))
	
	table.insert(Connections,Player:GetAttributeChangedSignal("PetEntertainment"):Connect(function()
		setBarSize(PetStats.BarEnter,Player:GetAttribute("PetEntertainment"))
		setBarSize(PetStats.BarHappiness,Player:GetAttribute("PetHappiness") or 0)
		changeHappinessIcon()
	end))
	
	setBarSize(PetStats.BarHappiness,Player:GetAttribute("PetHappiness") or 0)
	setBarSize(PetStats.BarHunger,Player:GetAttribute("PetHunger") or 0)
	setBarSize(PetStats.BarEnter,Player:GetAttribute("PetEntertainment") or 0)
	changeHappinessIcon()
	
	--Handle the clicks for the interaction and the following events
	local PetUI = Dependency.PetUI:Clone()
	local PetClick = Dependency.PetClick:Clone()
	PetClick.Parent = Paths.UI.Main.Parent
	PetUI.Parent = Paths.UI.Main.Parent
	PetUI.Adornee = PetModel.PrimaryPart
	PetClick.Adornee = PetModel.PrimaryPart
	local lastOpened = tick()-10
	
	local function openInteract()
		if justclosed then return end
		if tick()-lastOpened < 4.8 then return end
		lastOpened = tick()
		ScriptModules.Buttons:UIOn(PetUI.Interact,false,.1)
		PetClick.Enabled = false
		wait(5)
		if PetUI and PetUI:FindFirstChild("Interact") and PetUI.Interact.Visible and tick()-lastOpened >= 4.8 then
			ScriptModules.Buttons:UIOff(PetUI.Interact,false,.1)
		end
	end
	
	local ButtonClick = ScriptModules.Audio:GetSound(ScriptModules.Audio.BUTTON_CLICKED, Paths.Player.PlayerScripts:WaitForChild("Audio"), 0.2)
	
	for i, v in pairs(PetClick:GetDescendants()) do
		if string.match(v.ClassName, "Button") then
			v.MouseButton1Down:Connect(function()
				ButtonClick:Play()
			end)
		end
	end
	for i, v in pairs(PetUI:GetDescendants()) do
		if string.match(v.ClassName, "Button") then
			v.MouseButton1Down:Connect(function()
				ButtonClick:Play()
			end)
		end
	end

	
	PetClick.Interact.MouseButton1Click:Connect(function()
		if PetStats.Visible then return end
		openInteract()
	end)
	
	--ScriptModules.Buttons.addButton(PetClick.Interact,PetUI.Interact,false,.1)

	PetUI.Interact.Stats.MouseButton1Click:Connect(function()
		ScriptModules.Buttons:UIOn(PetStats,true)
		ScriptModules.Buttons:UIOff(PetUI.Interact,false,.1)
	end)
	
	PetUI.Interact.Close.MouseButton1Click:Connect(function()
		justclosed = true
		ScriptModules.Buttons:UIOff(PetUI.Interact,false,.1)
		task.wait(.1)
		lastOpened = tick()-5
		task.wait(.2)
		justclosed = false
	end)
	
	PetStats.Exit.MouseButton1Down:Connect(function()
		justclosed = true
		lastOpened = tick()-5
		task.wait(.2)
		justclosed = false
	end)

	PetUI.Interact.Trick.MouseButton1Click:Connect(function()
		if (Character:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Swimming) and Pet[11].IsPlaying == false and playerInBoat() == false then
			local s,m = pcall(function()
				task.spawn(function()
					if Pet[12].IsPlaying then
						Pet[12]:Stop()
					end
					Pet[16].Trick:Play()
					Pet[13] = Pet[14].TrickCFrame
					Pet[5]:Stop(.15)
					Pet[11]:Play()
					task.wait(Pet[11].Length*.95)
					Pet[11]:Stop(.25)
					Pet[5]:Play()
					Pet[13] = CFrame.Angles(0,0,0)
					if Pet[2]:FindFirstChild("Humanoid") and Pet[2].Humanoid:GetState() == Enum.HumanoidStateType.Seated then
						sitPet()
					end
				end)
				interacting = true
				ScriptModules.Buttons:UIOff(PetUI.Interact,false,.1)
				Remotes.PetTrick:FireServer()
			end)
			if s == false then
				warn(m)
			end
			if Pet and Pet[11] then
				task.wait(Pet[11].Length)
			end
			interacting = false
		end
	end)
	
	local fed = false
	PetUI.Interact.Feed.MouseButton1Click:Connect(function()
		if fed then return end
		if playerInBoat() then return end
		fed = true
		interacting = true
		ScriptModules.Buttons:UIOff(PetUI.Interact,false,.1)
		task.spawn(function()
			task.wait(6.5)
			ReplicatedStorage.Remotes.ResetPetAnimation:FireServer()
		end)
		local food,amount = Remotes.FeedPet:InvokeServer()
		local s,m = pcall(function()
			FeedFunction(food,amount)
		end)
		if s == false then
			warn(m)
		end
		repeat task.wait(.1) until game.Players.LocalPlayer.Character == nil or game.Players.LocalPlayer.Character:GetAttribute("PetAnimation") == "none"
		interacting = false
		fed = false
	end)
	
	local threw = false
	PetUI.Interact.Catch.MouseButton1Click:Connect(function()
		if threw then return end
		if (Character:FindFirstChild("Humanoid"):GetState() ~= Enum.HumanoidStateType.Swimming) and playerInBoat() == false then
			threw = true
			interacting = true
			ScriptModules.Buttons:UIOff(PetUI.Interact,false,.1)
			local s,m = pcall(function()
				local toy,amount = Remotes.PlayPet:InvokeServer()
				ThrowFunction(toy,amount)
			end)
			if s == false then
				warn(m)
			end
			repeat task.wait(.1) until game.Players.LocalPlayer.Character == nil or game.Players.LocalPlayer.Character:GetAttribute("PetAnimation") == "none"
			interacting = false
			threw = false
		end
	end)
	
	--Handle mouse hover over pet to turn on pet click UI
	local lastTurnedOn = tick()
	table.insert(Connections,UserInputService.InputBegan:Connect(function(Input,GPE)
		if GPE then return end
		if justclosed then return end
		if Mouse.Target and interacting == false then
			if Input.UserInputType == Enum.UserInputType.Touch then
				if Mouse.Target:IsDescendantOf(PetModel) and PetUI.Interact.Visible == false then
					openInteract()
				end
			end
		end
	end))
	local lastInput = tick()
	table.insert(Connections,UserInputService.InputChanged:Connect(function()
		lastInput = tick()
	end))
	RunService:BindToRenderStep("PetInteractUI",Enum.RenderPriority.Last.Value,function()
		local Input = justclosed or UserInputService:GetLastInputType()
		if tick()-lastInput>.15 then return end
		if Mouse.Target and interacting == false and PetStats.Visible == false then
			if Input ~= Enum.UserInputType.Touch then
				if Mouse.Target:IsDescendantOf(PetModel) and PetUI.Interact.Visible == false then
					interacting = false
					PetClick.Enabled = true
					lastTurnedOn = tick()
				else
					if tick()-lastTurnedOn < 1 then
						task.wait(.35)
					end
					if Mouse.Target and Mouse.Target:IsDescendantOf(PetModel) == false and PetUI and PetUI:FindFirstChild("Interact") and PetUI.Interact.Visible == false then
						PetClick.Enabled = false
					end
				end
			end
		end
		if PetStats.Visible or interacting then
			PetClick.Enabled = false
		end
	end)
	
	return PetUI, PetClick
end


return PetUI

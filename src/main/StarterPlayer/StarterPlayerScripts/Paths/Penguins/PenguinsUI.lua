local PenguinsUI = {}



--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

--- Variables ---
local PenguinList = UI.Center.Penguins.List
local CustomizationUI = UI.Left.Customization

local PenguinsData = Remotes.GetStat:InvokeServer("Penguins")



--- Setup Penguins ---
function PenguinsUI:SetupPenguin(Penguin)
	if PenguinList:FindFirstChild(Penguin.Name) then return end
	local Template = Dependency.PenguinTemplate:Clone()
	Template.Penguin.Value = Penguin
	Template.Name = Penguin.Name
	Template.LayoutOrder = Penguin:GetAttribute("Income")
	Template.Parent = PenguinList

	PenguinsUI:PenguinInfoUpdated(Penguin)
	PenguinsUI:CreateViewport(Penguin)

	Template.Customize.MouseButton1Down:Connect(function()
		Modules.Buttons:UIOff(UI.Center.Penguins, true)
		Modules.Customization:EnterUI(Penguin, PenguinList.Parent)
	end)

	if Penguin == Paths.Player.Character then
		Template.Super.Visible = false
		Template.Instant.AnchorPoint = Vector2.new(0,0)
		-- Template.Instant.Position = UDim2.fromScale(.03,.6)
		Template.Upgrade.Position = UDim2.fromScale(.37,.6)
	else
		Template.Super.MouseButton1Down:Connect(function()
			Remotes.Store:FireServer("Penguin", Penguin, true)
		end)
	end

	Template.Upgrade.MouseButton1Down:Connect(function()
		if Penguin:GetAttribute("Income") then
			local UpgradeSuccess, Info, NewData = Remotes.Customization:InvokeServer("Upgrade", Penguin)
			if NewData then
				PenguinsData = NewData
			end
			if UpgradeSuccess then
				PenguinsUI:PenguinInfoUpdated(Penguin)
			else
				local Reason = Info

			end
		end
	end)

	Template.Instant.MouseButton1Down:Connect(function()
		CustomizationUI.PenguinSelected.Value = Penguin
		Remotes.Store:FireServer("Penguin", Penguin)
	end)
end

-- Update penguins when they are upgraded
Remotes.Store.OnClientEvent:Connect(function(PurchaseType, PurchaseInfo, IsPurchased,NewPenguinsData)
	if NewPenguinsData then
		PenguinsData = NewPenguinsData
	end
	if PurchaseType == "Penguin Upgraded" then
		if IsPurchased then -- If purchase was true/successful then
			PenguinsUI:PenguinInfoUpdated(PurchaseInfo)
		end
	end
end)


function PenguinsUI:UpdateViewport(Penguin)
	if Penguin and Penguin:FindFirstChild("Humanoid") and Penguin:FindFirstChild("Main") then
		local Template = PenguinList:FindFirstChild(Penguin.Name)

		if Template then
			local Viewport = Template.Viewport

			-- Destroy old penguin if its there
			if Viewport:FindFirstChildOfClass("Model") then
				Viewport:FindFirstChildOfClass("Model"):Destroy()
			end

			-- Make new clone
			Penguin.Archivable = true
			local Clone = Penguin:Clone()
			if not Penguin:GetAttribute("Penguin") then
				Clone.Parent = workspace
				task.wait()
			end
			Clone.Parent = Viewport

			local Camera = Viewport.Camera
			Camera.CoordinateFrame = Clone.Main.CFrame * CFrame.Angles(math.rad(0), math.rad(165), math.rad(0)) * CFrame.new(0, 1.1, 4.5) -- viewport angle
			Viewport.LightDirection = ((Clone.Main.CFrame * CFrame.new(0, 1.7, 4.5)).p - Clone.Main.CFrame.p).Unit
		end
	end
end


function PenguinsUI:CreateViewport(Penguin)
	local Template = PenguinList:FindFirstChild(Penguin.Name)

	if Template then
		local Viewport = Template.Viewport

		local Camera = Instance.new("Camera", Viewport)
		Camera.CameraType = Enum.CameraType.Scriptable
		Viewport.CurrentCamera = Camera

		PenguinsUI:UpdateViewport(Penguin)
	end
end


function PenguinsUI:PenguinInfoUpdated(Penguin)
	local Template = PenguinList:FindFirstChild(Penguin.Name)

	if Template then
		if Penguin == Paths.Player.Character then -- Is player character
			local PenguinLevel = Paths.Player:GetAttribute("Level")

			local Income = Modules.GameFunctions:GetPlayerPenguinIncome(PenguinLevel)
			local UpgradePrice = Modules.GameFunctions:GetPlayerPenguinPrice(PenguinLevel + 1)

			-- Update Level (Income) and Price
			--Template.PenguinLevel.Text = "Level "..PenguinLevel..' <font color="rgb(38,255,14)">(+ $'..Modules.Format:FormatComma(Income)..")</font>"
			Template.PenguinLevel.Text = "Level: "..PenguinLevel
			Template.PenguinIncome.Text = "Income: "..'<font color="rgb(38,255,14)"> $'..Modules.Format:FormatComma(Income).."</font>"

			Template.PenguinPrice.Text = '$ '..Modules.Format:FormatComma(UpgradePrice)


			if Penguin:FindFirstChild("HumanoidRootPart") then
				local CustomName = Penguin:GetAttribute("CustomName")

				if CustomName then
					Template.PenguinName.Text = CustomName
				end
			end


		-- Is an npc penguin
		else
			local PenguinName = Penguin.Info.PenguinInfo.PenguinName.Text
			if Penguin.Info.PenguinInfo.PenguinLevel.Text == "Level X" then
				Penguin.Info.PenguinInfo.PenguinLevel.Text = "Level 1"
			end
			local PenguinLevel = tonumber(string.split(string.split(Penguin.Info.PenguinInfo.PenguinLevel.Text, "/"..tostring(Modules.GameInfo.MAX_PENGUIN_LEVEL))[1], " ")[2])

			local Income = Modules.GameFunctions:GetPenguinIncome(Penguin:GetAttribute("Income"), PenguinLevel)

			-- Update Level (Income) and Price
			Template.PenguinName.Text = PenguinName
			--Template.PenguinLevel.Text = Penguin.Info.PenguinInfo.PenguinLevel.Text

			Template.PenguinLevel.Text = "Level: "..PenguinLevel.."/"..tostring(Modules.GameInfo.MAX_PENGUIN_LEVEL)
			Template.PenguinIncome.Text = "Income: "..'<font color="rgb(38,255,14)"> $'..Modules.Format:FormatComma(Income).."</font>"

			if PenguinLevel < Modules.GameInfo.MAX_PENGUIN_LEVEL then -- If penguin isn't max level then
				-- Price text
				local UpgradePrice = Modules.GameFunctions:GetPenguinPrice(Penguin:GetAttribute("Price"), PenguinLevel + 1)
				Template.PenguinPrice.Text = '$ '..Modules.Format:FormatComma(UpgradePrice)

			else -- the penguin IS max level then
				Template.PenguinPrice.Visible = false
				Template.Upgrade.TheText.Text = "MAX"
				Template.Upgrade.BackgroundTransparency = 0.8

				Template.Instant.Visible = false
				Template.Super.AnchorPoint = Vector2.new(0,0)
				Template.Super.Position = UDim2.fromScale(.03, 0.6)
				Template.Super.Size = UDim2.fromScale(.63, .17)
			end

			if PenguinLevel == 30 then
				Template.Instant.Visible = false
				Template.Super.Visible = false
				Template.Upgrade.AnchorPoint = Vector2.new(0.5,0)
				Template.Upgrade.Position = UDim2.fromScale(.5,.6)
				Template.Upgrade.Size = UDim2.fromScale(.935,.17)
				Template.Upgrade.TheText.Text = "SUPER PENGUIN"

				local Rainbow = Dependency.Rainbow:Clone()
				Rainbow:WaitForChild("Rotation").Disabled = false
				Rainbow.Parent = Template.PenguinName

			end

		end

	end

end



--- Setting up player penguin functions ---
-- Customize Button
UI.Center.Penguins.List.Player.Customize.MouseButton1Down:Connect(function()
	local Character = Paths.Player.Character

	if Character and Character:FindFirstChild("Humanoid") and Character:GetAttribute("Penguin") then
		Modules.Buttons:UIOff(UI.Center.Penguins, true)
		Modules.Customization:EnterUI(Character, PenguinList.Parent)
	end
end)


-- Upgrade button
PenguinList.Player.Upgrade.MouseButton1Down:Connect(function()
	if Paths.Player.Character then
		local UpgradeSuccess, Info = Remotes.Customization:InvokeServer("Upgrade", Paths.Player.Character)

		if UpgradeSuccess then
			PenguinsUI:PenguinInfoUpdated(Paths.Player.Character)
		else
			local Reason = Info

		end
	end
end)

PenguinList.Player.Instant.MouseButton1Down:Connect(function()
	if Paths.Player.Character then
		Remotes.Store:FireServer("Penguin", Paths.Player.Character)
	end
end)


local Char = Paths.Player.Character
PenguinList.Player.Name = Paths.Player.Name


if Char and Char:FindFirstChild("HumanoidRootPart") then
	PenguinsUI:CreateViewport(Paths.Player.Character)
	PenguinsUI:PenguinInfoUpdated(Paths.Player.Character)
end

-- Rebirthing
task.spawn(function()
	repeat task.wait() until Modules.Rebirths
	Modules.Rebirths.Rebirthed:Connect(function()
		PenguinsUI:PenguinInfoUpdated(Paths.Player.Character)
		for _, Penguin in ipairs(PenguinList:GetChildren()) do
			if Penguin:IsA("Frame") and Penguin.Name ~= Paths.Player.Name then
				Penguin:Destroy()
			end
		end

	end)

end)

return PenguinsUI
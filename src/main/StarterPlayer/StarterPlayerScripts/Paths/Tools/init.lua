local TweenService = game:GetService("TweenService")
local Tools = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

local isStillPlaying = 0
local IS_QA = (game.GameId == 3425594443)

local KEYBINDS = {
	[Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6, [Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8, [Enum.KeyCode.Nine] = 9, [Enum.KeyCode.Zero] = 0,
}



local NewItemUI = Paths.UI.Full.NewItem

local Pinned = {}
local CurrentlyEquipped = false

Tools.Handlers = {}
for i, v in pairs(script:GetChildren()) do Tools.Handlers[v.Name] = require(v) end


-- Animating unlocking a new tool (full-screen UI)
local function OpenNewItem(Tool)
	-- Reset positions and sizes
	NewItemUI.Position = UDim2.new(0, 0, 1, 0)
	NewItemUI.Visible = true

	-- Setup accessory info
	NewItemUI.ItemName.Text = Tool
	NewItemUI.ItemIcon.Image = Modules.AllTools[Tool].Icon or "rbxgameasset://Images/"..Tool.."_Tool"

	-- Play animation
	NewItemUI:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Quart", 0.4, true)
end

local function StopNewToolAnimation(Tool)
	local Button = Paths.UI.Tools[Tool]

	Button:SetAttribute("Animating",false)
	local tween = TweenService:Create(Button.BG,TweenInfo.new(.2),{BackgroundColor3 = Color3.fromRGB(48, 176, 255)})
	tween:Play()
	if Tool == "Fishing Rod" then
		Paths.UI.Bottom.ToolText.Visible = true
		Paths.UI.Bottom.ToolText.Text = "Click on nearby water to start fishing!"
	elseif Tool == "Axe" then
		Paths.UI.Bottom.ToolText.Visible = true
		Paths.UI.Bottom.ToolText.Text = "Walk infront of a tree to start chopping!"
	end

end

local function ActivateTool(Tool)
	local Button = Paths.UI.Tools:FindFirstChild(Tool)
	if Button then
		if Modules.Fishing and not Modules.Fishing.LastUpdate.FishingAnimationActive then
			if Button:GetAttribute("Animating") then
				StopNewToolAnimation(Tool)
			end

			Remotes.Tools:FireServer("Equip Tool", Tool)

			task.wait(3)
			Paths.UI.Bottom.ToolText.Visible = false
		end

	end

end

local function LoadTools(Whitelist)
	local PlayerTools = Remotes.GetStat:InvokeServer("Tools")
	local Adding = {}

	Whitelist = Whitelist or PlayerTools
	for Tool in pairs(PlayerTools) do
		if Whitelist[Tool] then
			table.insert(Adding, Tool)
		end
	end

	for Tool, Info in pairs(Modules.AllTools) do
		local Replacee = Info.Replacee
		if Replacee then
			if table.find(Adding, Tool) and table.find(Adding, Replacee) then
				table.remove(Adding, table.find(Adding, Replacee))
			end
		end

	end

	for _, Tool in ipairs(Adding) do
		Tools.AddTool(Tool)
	end

end


--- Tool Functions ---
function Tools.AddTool(Tool, isNew)
	local Info = Modules.AllTools[Tool]

	if Paths.UI.Tools:FindFirstChild(Tool) then return end
	-- if IS_QA and string.find(Tool, "Gold") then return end

	local Replacee = Modules.AllTools[Tool].Replacee
	if Replacee then
		Tools.RemoveTool(Replacee)
	end

	local Template = Dependency.ToolTemplate:Clone()
	Template.Name = Tool
	Template.ToolIcon.Image = Info.Icon or "rbxgameasset://Images/"..Tool.."_Tool"

	local ToolCount = #Paths.UI.Tools:GetChildren() - 1
	local Keybind = ToolCount + 1

	if not Info.Pinned then
		Keybind -= #Pinned
		for _, Button in pairs(Pinned) do
			local ShiftedKeybind = Button.LayoutOrder + 1
			Button.Keybind.Text = ShiftedKeybind
			Button.LayoutOrder = ShiftedKeybind
		end
	else
		table.insert(Pinned, Template)
	end

	Template.Keybind.Text = Keybind
	Template.LayoutOrder = Keybind

	local isAnimating = isNew or false
	Template:SetAttribute("Animating", isAnimating)

	Template.MouseButton1Down:Connect(function()
		ActivateTool(Tool)
	end)

	Template.Parent = Paths.UI.Tools

	-- Blinking for new tools
	if isAnimating then
		task.defer(function()
			while Template:GetAttribute("Animating") and Template.Parent and Template:FindFirstChild("BG") do
				local tween = TweenService:Create(Template:WaitForChild("BG"),TweenInfo.new(.3),{BackgroundColor3 = Color3.fromRGB(240, 202, 34)})
				tween:Play()
				task.wait(.4)
				local tween = TweenService:Create(Template:WaitForChild("BG"),TweenInfo.new(.3),{BackgroundColor3 = Color3.fromRGB(48, 176, 255)})
				tween:Play()
				task.wait(.3)
			end
		end)
	end

	if Tool == "Fishing Rod" and isNew then
		Remotes.Tools:FireServer("Equip Tool", Tool)
	end

end

function Tools.RemoveTool(Tool)
	if CurrentlyEquipped == Tool then
		Remotes.Tools:FireServer("Equip Tool", Tool)
		if Paths.Player:GetAttribute("Tool") == Tool then
			Paths.Player:GetAttributeChangedSignal("Tool"):Wait()
		end
	end

	local Button =  Paths.UI.Tools:FindFirstChild(Tool)

	if Button then
		local Keybind = Button.LayoutOrder
		Button:Destroy()

		if Modules.AllTools[Tool].Pinned then
			table.remove(Pinned, table.find(Pinned, Button))
		end

		-- Shift all other tools  back
		for _, OtherButton in ipairs(Paths.UI.Tools:GetChildren()) do
			if OtherButton:IsA("ImageButton") then
				local OtherKeybind = OtherButton.LayoutOrder
				if OtherKeybind > Keybind then
					OtherButton.LayoutOrder -= 1
					OtherButton.Keybind.Text = OtherKeybind - 1
				end

			end

		end

	end

end

function Tools.HideTools(Blacklist)
	Blacklist = Blacklist or {}

	for _, Button in ipairs(Paths.UI.Tools:GetChildren()) do
		local Tool = Button.Name
		if Button:IsA("ImageButton") and not table.find(Blacklist, Tool) then
			Tools.RemoveTool(Tool)
		end
	end

end

Tools.UnhideTools = LoadTools


--- Animating tool equipping/unequipping
local function UnequipTool(Tool)
	local Handler = Tools.Handlers[Tool]
	if Handler then
		Handler = Handler.Unequipped
		if Handler then
			Handler()
		end
	end

	local Template = Paths.UI.Tools:FindFirstChild(Tool)
	if Template then
		Template:TweenSize(UDim2.new(0.088, -1, 1, 0), "Out", "Quint", 0.15, true)
		Template.BG.Transparency = 0.7
		Template.BG.BackgroundColor3 = Color3.fromRGB(48, 176, 255)
		Template.BG.UIStroke.Thickness = 2
		Template.BG.UIStroke.Color = Color3.fromRGB(48, 176, 255)
		Template.Keybind.UIStroke.Color = Color3.fromRGB(48, 176, 255)
	end

	Modules.Character:StopToolAnimation(Tool)
end

local function EquipTool(Tool)
	local Handler = Tools.Handlers[Tool]
	if Handler then
		Handler = Handler.Equipped
		if Handler then
			Handler()
		end
	end

	local Template = Paths.UI.Tools:FindFirstChild(Tool)
	if Template then
		Template:TweenSize(UDim2.new(0.1, -1, 1.14, 0), "Out", "Quint", 0.15, true)
		Template.BG.Transparency = 0.6
		Template.BG.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
		Template.BG.UIStroke.Thickness = 2.5
		Template.BG.UIStroke.Color = Color3.fromRGB(0, 132, 255)
		Template.Keybind.UIStroke.Color = Color3.fromRGB(0, 132, 255)
	end

	Modules.Character:PlayToolAnimation(Tool)
end

function ItemRetrievedAnimation(Icon,Amount,Name)
	isStillPlaying += 1

	coroutine.wrap(function()
		local currentAnim = isStillPlaying
		local fishCaught = Paths.UI.Bottom.WoodCaught:Clone()
		fishCaught.Parent = Paths.UI.Bottom
		-- Reset positions and sizes
		fishCaught.Position = UDim2.new(0.5, 0, 1, 0)

		-- Setup info
		fishCaught.FishName.Text = Name
		fishCaught.FishReward.Text = Amount
		fishCaught.Icon.Image = Icon
		if string.match(Name,"Gem") then
			fishCaught.FishReward.TextColor3 = Color3.new(0, 0.6, 1)
		end
		-- Play animation
		fishCaught.Visible = true

		fishCaught:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Back", 0.5, true)

		task.wait(2)

		fishCaught:TweenPosition(UDim2.new(0.5, 0, 1, 0), "In", "Back", 0.5, true)

		task.wait(0.6)

		fishCaught:Destroy()
	end)()
end

local NameToImage = {
	["Acorn"] = "rbxassetid://10156079883",
	["Pouch"] = "rbxassetid://10156079663",
	["Log"] = "rbxassetid://10156079663",
	["Gems"] = "rbxassetid://8679117564",
	["Money"] = "rbxassetid://8679056485",
}

function Tools.ToolReward(amount,isbig)
	local treeReward = Paths.UI.Center.TreeReward:Clone()
	if type(amount) == "table" then
		if amount[1] == "Outfit" then return end
		if amount[3] then --rbxassetid://10156079663 -- money ||| rbxassetid://10156079883 -- acorn	
			if amount[3] == "Acorn" then
				ItemRetrievedAnimation(NameToImage[amount[3]],"+ "..Paths.Modules.Format:FormatComma(amount[2]),"Gems Acorn")
			elseif amount[3] == "Pouch" then
				ItemRetrievedAnimation(NameToImage[amount[3]],"+ "..Paths.Modules.Format:FormatComma(amount[2]),"Money Pouch")
			elseif amount[3] == "Log" then
				ItemRetrievedAnimation(NameToImage[amount[3]],"+ "..Paths.Modules.Format:FormatComma(amount[2]),"Money Log")
			end
		elseif amount[1] == "Gems" then
			ItemRetrievedAnimation(NameToImage[amount[1]],"+ "..Paths.Modules.Format:FormatComma(amount[2]),"Gems")
		elseif amount[1] == "Money" then
			ItemRetrievedAnimation(NameToImage[amount[1]],"+ "..Paths.Modules.Format:FormatComma(amount[2]),"Big Money")
		end
		return
	else
		treeReward.Text = "+ $ "..Paths.Modules.Format:FormatComma(amount)
	end
	treeReward.Parent = Paths.UI.Center
	local big = treeReward.Size 
	treeReward.Size = UDim2.fromScale(0,0)
	local w,w2 = .1,1
	if isbig then
		big = UDim2.fromScale(big.X.Scale*2,big.Y.Scale*2)
		w = .2
		w2 = 5.5
		if type(amount) ~= "table" then
			treeReward.TextColor3 = Color3.new(1,1,1)
			treeReward.UIGradient.Enabled = true
		else
			treeReward.ZIndex = -5
		end
	end
	treeReward.Position = UDim2.fromScale(math.random(25,75)/100,math.random(25,75)/100)
	local tween = Paths.Services.TweenService:Create(treeReward,TweenInfo.new(w),{Size = big})
	treeReward.Visible = true
	tween:Play()
	task.wait(w2)
	local tween = Paths.Services.TweenService:Create(treeReward,TweenInfo.new(w),{Size = UDim2.fromScale(0,0)})
	tween:Play()
	task.wait(w)
	treeReward:Destroy()
end

Remotes.Axe.OnClientEvent:Connect(function(amount,isbig)
	Modules.Tools.ToolReward(amount,isbig)
end)

-- Updatin tool UI
Paths.Player:GetAttributeChangedSignal("Tool"):Connect(function()
	local NewEquipped = Paths.Player:GetAttribute("Tool")

	-- Unequip previous tool
	if CurrentlyEquipped then
		UnequipTool(CurrentlyEquipped)
	end

	if NewEquipped == "None" then
		CurrentlyEquipped = false
	else
		CurrentlyEquipped = NewEquipped
		EquipTool(NewEquipped)
	end

end)

-- Using keybinds to equip tools
Services.InputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	local KeyPressed = input.KeyCode

	if KeyPressed and KEYBINDS[KeyPressed] then
		for _, v in pairs(Paths.UI.Tools:GetChildren()) do
			if v:IsA("ImageButton") and v.LayoutOrder == KEYBINDS[KeyPressed] then
				ActivateTool(v.Name)
			end

		end

	end

end)

--- Loading & Adding tools
Remotes.Tools.OnClientEvent:Connect(function(Action, Tool, Temporary)
	if Action == "Add Tool" then
		if not Temporary then OpenNewItem(Tool) end -- Animate it, since this will only fire when a new tool is purchased
		Tools.AddTool(Tool, not (Temporary or false))
	elseif Action == "Remove Tool" then
		Tools.RemoveTool(Tool)
	end
end)

LoadTools()

return Tools
local TweenService = game:GetService("TweenService")
local Tools = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local NewItemUI = Paths.UI.Full.NewItem
local LastAdded = false

local Dependency = Paths.Dependency:FindFirstChild(script.Name)

--- Tool Variables ---
local ToolFunctions = {}
for i, v in pairs(script:GetChildren()) do ToolFunctions[v.Name] = require(v) end

local Keybinds = {
	[Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5, 
	[Enum.KeyCode.Six] = 6, [Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8, [Enum.KeyCode.Nine] = 9, [Enum.KeyCode.Zero] = 0, 
}

function stopAnimation(Template,Tool)
	Template:SetAttribute("Animating",false)
	local tween = TweenService:Create(Template.BG,TweenInfo.new(.2),{BackgroundColor3 = Color3.fromRGB(48, 176, 255)})
	tween:Play()
	if Tool == "Fishing Rod" then
		Paths.UI.Bottom.ToolText.Visible = true
		Paths.UI.Bottom.ToolText.Text = "Click on nearby water to start fishing!"
	elseif Tool == "Axe" then
		Paths.UI.Bottom.ToolText.Visible = true
		Paths.UI.Bottom.ToolText.Text = "Walk infront of a tree to start chopping!"
	end
end

--- Tool Functions ---
function Tools.AddTool(Tool,isNew)
	if Paths.UI.Tools:FindFirstChild(Tool) then return end
	LastAdded = os.time()
	if Tool == "Axe" or Tool == "Gold Axe" then
		workspace.Preload:FindFirstChild("Swamp Indicator").GUI.IslandIcon.Frame.Visible = true
	end
	local Template = Dependency.ToolTemplate:Clone()
	Template.Name = Tool
	Template.ToolIcon.Image = "rbxgameasset://Images/"..Tool.."_Tool"
	Template.Keybind.Text = #Paths.UI.Tools:GetChildren()
	Template.LayoutOrder = #Paths.UI.Tools:GetChildren()
	
	local isAnimating = isNew or false

	Template:SetAttribute("Animating",isAnimating)

	Template.MouseButton1Down:Connect(function()
		if Modules.Fishing and not Modules.Fishing.LastUpdate.FishingAnimationActive then
			if isAnimating then
				stopAnimation(Template,Tool)
				isAnimating = false
			end
			Remotes.Tools:FireServer("Equip Tool", Tool)
			task.wait(3)
			Paths.UI.Bottom.ToolText.Visible = false
		end
	end)
	
	Template.Parent = Paths.UI.Tools

	if isAnimating then
		task.defer(function()
			while Template:GetAttribute("Animating") do
				local tween = TweenService:Create(Template.BG,TweenInfo.new(.3),{BackgroundColor3 = Color3.fromRGB(240, 202, 34)})
				tween:Play()
				task.wait(.4)
				local tween = TweenService:Create(Template.BG,TweenInfo.new(.3),{BackgroundColor3 = Color3.fromRGB(48, 176, 255)})
				tween:Play()
				task.wait(.3)
			end
		end)
	end
end


-- Animating unlocking a new tool (full-screen UI)
function Tools.AnimateNewTool(Tool)
	-- Reset positions and sizes
	NewItemUI.Position = UDim2.new(0, 0, 1, 0)
	NewItemUI.Visible = true

	-- Setup accessory info
	NewItemUI.ItemName.Text = Tool
	NewItemUI.ItemIcon.Image = "rbxgameasset://Images/"..Tool.."_Tool"

	-- Play animation
	NewItemUI:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Quart", 0.4, true)
end



--- Animating tool equipping/unequipping
local CurrentlyEquipped = false

local function UnequipTool(Tool)
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
	end
	
	-- Equip New tool
	if CurrentlyEquipped then
		EquipTool(CurrentlyEquipped)
	end
end)

-- Using keybinds to equip tools
Services.InputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	else
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local KeyPressed = input.KeyCode
			
			if Keybinds[KeyPressed] then
				for i, v in pairs(Paths.UI.Tools:GetChildren()) do
					if v:IsA("ImageButton") and tonumber(v.Keybind.Text) == Keybinds[KeyPressed] then
						if Modules.Fishing and not Modules.Fishing.LastUpdate.FishingAnimationActive then
							Remotes.Tools:FireServer("Equip Tool", v.Name)	
							if v:GetAttribute("Animating") then
								stopAnimation(v,v.Name)
								task.wait(3)
								Paths.UI.Bottom.ToolText.Visible = false
							end
						end
					end
				end
			end
		end
	end
end)


--- Loading & Adding tools
Remotes.Tools.OnClientEvent:Connect(function(Action, Tool)
	if Action == "Add Tool" then
		Tools.AnimateNewTool(Tool) -- Animate it, since this will only fire when a new tool is purchased
		Tools.AddTool(Tool,true)
	end
end)

local PlayerTools = Remotes.GetStat:InvokeServer("Tools")
local ToolExeptions = {
	["Gold Axe"] = "Axe",
	["Gold Fishing Rod"] = "Fishing Rod",
	["Powered Glider"] = "Glider"
}
local tbl = {}
for Tool, isOwned in pairs(PlayerTools) do
	table.insert(tbl, Tool)
end

for name,exception in pairs (ToolExeptions) do
	if table.find(tbl,name) and table.find(tbl,exception) then
		table.remove(tbl,table.find(tbl,exception))
	end
end

for i, Tool in ipairs(tbl) do
	Tools.AddTool(Tool)
end


return Tools
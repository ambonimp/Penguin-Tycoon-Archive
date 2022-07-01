local Buttons = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- UI Variables ---
local MainButtons = {}
for i, v in pairs(UI.Main:GetDescendants()) do
	if v:GetAttribute("UI") then
		table.insert(MainButtons, v)
	end
end

local MainUIs = {}
local OriginalSizes = {}
for i, v in pairs(UI.Center:GetChildren()) do
	if v:IsA("ImageLabel") or v:IsA("Frame") then
		MainUIs[v.Name] = v
		OriginalSizes[v] = v.Size
	end
end

local ExitButtons = {}
for i, v in pairs(UI.Main:GetDescendants()) do
	if string.match(v.Name, "Exit") then
		table.insert(ExitButtons, v)
	end
end


--- Other Variables ---
local PreviousOpen = nil
local Debounce = false

local isUsingGamepad = false
function UpdateInputType(LastInputType)
	isUsingGamepad = LastInputType == Enum.UserInputType.Gamepad1
end
Services.InputService.LastInputTypeChanged:Connect(UpdateInputType)
UpdateInputType(Services.InputService:GetLastInputType())


--[[ -- Events --
Buttons.FrameClosed = Modules.Signal.new()
Buttons.FrameOpened = Modules.Signal.new()
 *]]

--- Button Functions ---
function Buttons:UIOff(UI, ToggleBlur,DoWait)
	-- Buttons.FrameClosed:Fire(UI)

	-- UI
	if UI.Size == OriginalSizes[UI] then
		UI:TweenSize(UDim2.new(0.05, 0, 0.05, 0), "In", "Back", 0.15, true)

		-- Blur
		if ToggleBlur then
			for i = 17, 2, -5 do
				game.Lighting.Blur.Size = i
				task.wait()
			end
		end

		if DoWait and type(DoWait) == "number" then
			task.wait(DoWait)
		end

		UI.Visible = false
		PreviousOpen = nil
		
		if UI:FindFirstChild("Last") and UI:FindFirstChild("Last").Value then
			Buttons:UIOn(UI:FindFirstChild("Last").Value,true)
		end
	end
end

function Buttons:UIOn(UI, ToggleBlur,DoWait)
	-- Buttons.FrameOpened:Fire(UI)

	if not UI or UI == PreviousOpen then return end
	if OriginalSizes[UI] == nil then
		OriginalSizes[UI] = UI.Size
	end
	-- UI
	UI.Visible = true
	UI.Size = UDim2.new(0.05, 0, 0.05, 0)
	UI:TweenSize(OriginalSizes[UI], "Out", "Back", 0.15, true)

	-- Blur
	if ToggleBlur then
		for i = 7, 22, 5 do
			game.Lighting.Blur.Size = i
			task.wait()
		end
	end
	
	PreviousOpen = UI
end

function Buttons.addButton(Button,Frame,Blur,DoWait,tbl)
	Button.MouseButton1Click:Connect(function()
		if Frame.Visible == false then
			Buttons:UIOn(Frame,Blur)
		else
			Buttons:UIOff(Frame,Blur)
		end
	end)
	if tbl then
		if tbl.ExitFunction then
			Frame.Exit.MouseButton1Down:Connect(function()
				tbl.ExitFunction()
			end)
		end
	end
end


function ButtonClicked(button)
	if Debounce then return end
	
	-- Specific for store (buy money button) to not close it if money tab isn't open
	--if PreviousOpen and button.Name == "BuyMoney" then
	--	if PreviousOpen.Name == "Store" then return end
	--end
	
	if button.Name == "BuyAccessories" then wait(0.1) end
	
	Debounce = true
	
	-- If button clicked is the same as previous open, just turn it off
	if PreviousOpen == MainUIs[button:GetAttribute("UI")] then
		Buttons:UIOff(PreviousOpen, true)
			
	elseif PreviousOpen then
		Buttons:UIOff(PreviousOpen, false)
		Buttons:UIOn(MainUIs[button:GetAttribute("UI")], false)
		
	else
		Buttons:UIOn(MainUIs[button:GetAttribute("UI")], true)
	end
	
	Debounce = false
end


--- Hiding/Showing buttons ---
local ShowButtonsDB = false
local OriginalPositions = {}
local OriginalPositionsRight = {}

for i, v in pairs(UI.Left.Buttons:GetChildren()) do
	if v.Name ~= "Expand" and v.Name ~= "Hide" then
		OriginalPositions[v] = v.Position
	end
end


for i, v in pairs(UI.Right.Buttons:GetChildren()) do
	if v.Name ~= "Expand" and v.Name ~= "Hide" then
		OriginalPositionsRight[v] = v.Position
	end
end

UI.Left.Buttons.Expand.MouseButton1Down:Connect(function()
	if ShowButtonsDB then return end
	ShowButtonsDB = true

	UI.Left.Buttons.Expand.Visible = false
	UI.Left.Buttons.Hide.Visible = true

	for Button, Position in pairs(OriginalPositions) do
		Button.Visible = true
		Button:TweenSizeAndPosition(UDim2.new(0.25, 0, 0.25, 0), Position, "Out", "Quart", 0.15, true)
	end
	
	task.wait(0.12)

	ShowButtonsDB = false
end)

UI.Left.Buttons.Hide.MouseButton1Down:Connect(function()
	if ShowButtonsDB then return end
	ShowButtonsDB = true

	UI.Left.Buttons.Expand.Visible = true
	UI.Left.Buttons.Hide.Visible = false

	for Button, Position in pairs(OriginalPositions) do
		Button:TweenSizeAndPosition(UDim2.new(0.01, 0, 0.01, 0), UDim2.new(0.12, 0, 0.495, 0), "Out", "Quart", 0.15, true)
	end
	
	task.wait(0.1)
	for Button, Position in pairs(OriginalPositions) do
		Button.Visible = false
	end

	ShowButtonsDB = false
end)


UI.Right.Buttons.Expand.MouseButton1Down:Connect(function()
	if ShowButtonsDB then return end
	ShowButtonsDB = true

	UI.Right.Buttons.Expand.Visible = false
	UI.Right.Buttons.Hide.Visible = true

	for Button, Position in pairs(OriginalPositionsRight) do
		Button.Visible = true
		Button:TweenSizeAndPosition(UDim2.new(0.25, 0, 0.25, 0), Position, "Out", "Quart", 0.15, true)
	end
	
	task.wait(0.12)

	ShowButtonsDB = false
end)

UI.Right.Buttons.Hide.MouseButton1Down:Connect(function()
	if ShowButtonsDB then return end
	ShowButtonsDB = true

	UI.Right.Buttons.Expand.Visible = true
	UI.Right.Buttons.Hide.Visible = false

	for Button, Position in pairs(OriginalPositionsRight) do
		Button:TweenSizeAndPosition(UDim2.new(0.01, 0, 0.01, 0), UDim2.new(.9, 0, 0.5, 0), "Out", "Quart", 0.15, true)
	end
	
	task.wait(0.1)
	for Button, Position in pairs(OriginalPositionsRight) do
		Button.Visible = false
	end

	ShowButtonsDB = false
end)


--- Button Animations ---
local ButtonAnimationDB = false

local function SetupButtonAnimation(Button)
	Button.MouseButton1Down:Connect(function()
		if not ButtonAnimationDB and not isUsingGamepad then
			ButtonAnimationDB = true

			local OriginalSize = Button.Size
			local OriginalPos = Button.Position
			
			
			local NewSize = UDim2.new(OriginalSize.X.Scale/1.1, OriginalSize.X.Offset, OriginalSize.Y.Scale/1.1, OriginalSize.Y.Offset)
			
			local NewXPos = OriginalPos.X.Scale+((OriginalSize.X.Scale-OriginalSize.X.Scale/1.1)/2)
			local NewYPos = OriginalPos.Y.Scale+((OriginalSize.Y.Scale-OriginalSize.Y.Scale/1.1)/2)
			
			if Button.AnchorPoint.X == 0.5 then
				NewXPos = OriginalPos.X.Scale
			elseif Button.AnchorPoint.X == 1 then
				NewXPos = OriginalPos.X.Scale-((OriginalSize.X.Scale-OriginalSize.X.Scale/1.1)/2)
			end
			
			if Button.AnchorPoint.Y == 0.5 then
				NewYPos = OriginalPos.Y.Scale
			elseif Button.AnchorPoint.Y == 1 then
				NewYPos = OriginalPos.Y.Scale-((OriginalSize.Y.Scale-OriginalSize.Y.Scale/1.1)/2)
			end
			
			
			local NewPos = UDim2.new(NewXPos, OriginalPos.X.Offset, NewYPos, OriginalPos.Y.Offset)
			
			
			Button:TweenSizeAndPosition(NewSize, NewPos, "Out", "Quart", 0.04, true)
			task.wait(0.04)
			Button:TweenSizeAndPosition(OriginalSize, OriginalPos, "Out", "Quart", 0.04, true)

			task.wait(0.05)
			ButtonAnimationDB = false
		end
	end)
end

for i, v in pairs(Paths.Player.PlayerGui:GetDescendants()) do
	if string.match(v.ClassName, "Button") then
		SetupButtonAnimation(v)
	end
end

Paths.Player.PlayerGui.DescendantAdded:Connect(function(Descendant)
	if string.match(Descendant.ClassName, "Button") then
		SetupButtonAnimation(Descendant)
	end
end)



--- Initializing ---
for i, v in pairs(MainButtons) do
	v.MouseButton1Down:Connect(function()
		if v:FindFirstChild("Notif") then
			v.Notif.Visible = false
		end
		ButtonClicked(v)
	end)
end


for i, v in pairs(UI.Main:GetDescendants()) do
	if v.Name == "Exit" then
		v.MouseButton1Down:Connect(function()
			Buttons:UIOff(v.Parent, true)
		end)
	end
end

return Buttons
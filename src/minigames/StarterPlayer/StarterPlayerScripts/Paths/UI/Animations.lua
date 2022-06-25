local Animations = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- UI Variables ---
local Day = os.date("%A")
local Mult = 1

if Day == "Saturday" or Day == "Sunday" or Day == "Friday" then
	Mult = 4
else
	Mult = 1
end



local Dependency = Paths.Dependency:FindFirstChild(script.Name)
--- Other Variables
local TrickleTI = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local PreviousTotalTween = false


--- Updating Functions ---
function Animations:IncomeChanged(Change, NewIncome)
	local Template = Dependency.IncomeChanged:Clone()
	
	Template.Size = UDim2.new(1, 0, 0.02, 0)
	Template.Text = '+ <font color="rgb(57,225,91)">$ '..Modules.Format:FormatComma(Change).."</font> Income ($ "..Modules.Format:FormatComma(NewIncome)..")"
	Template.Parent = UI.Top
	
	Template:TweenSize(UDim2.new(1, 0, 0.2, 0), "Out", "Quart", 0.25, true)
	
	wait(1)
	
	Template:TweenPosition(UDim2.new(0.5, 0, 0.35, 0), "Out", "Quart", 1.5, true)

	wait(0.6)

	for i = 0, 1, 0.1 do
		Template.TextTransparency = i
		Template.TextStrokeTransparency = 0.5 + i
		wait()
	end

	Template:Destroy()
end


function Animations:MoneyChanged(Change, NewMoney)
	local Day = os.date("%A")
	local add = ""
	if (Day == "Saturday" or Day == "Sunday" or Day == "Friday") and Change > 0 then
		add = " (X2 DAY)"
	end
	local Template = Dependency.MoneyChanged:Clone()
	Template.Position = UDim2.new(0.37, 0, 0.9, 0)
	Template.AnchorPoint = Vector2.new(0, 0.5)
	Template.TextXAlignment = Enum.TextXAlignment.Left
	local Prefix = "+ $ "
	local YPos = 0.9
	local XPos = 0.15
	local YSize = 0.14

	-- Spending money; make it red and reverse the animation
	if Change < 0 then
		Template.TextColor3 = Color3.fromRGB(231, 68, 68)
		Template.Position = UDim2.new(0.07, 0, 0.8, 0)
		Template.ZIndex += 1
		Prefix = "- $ "
		YPos = 0.7
		XPos = 0.07
		YSize = 0.12
	end

	Template.Size = UDim2.new(0.5, 0, 0.02, 0)

	Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Change))..add
	Template.Parent = UI.BLCorner

	Template:TweenSize(UDim2.new(0.5, 0, YSize, 0), "Out", "Quart", 0.25, true)

	wait(0.6)

	-- Change in money tween (+ XX money text)
	local Goal = {Value = 0}
	local TrickleChangeTween = Services.TweenService:Create(Template.Change, TrickleTI, Goal)

	Template.Change.Value = Change

	Template.Change.Changed:Connect(function(Value)
		Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Value))..add
	end)

	TrickleChangeTween:Play()

	if PreviousTotalTween then PreviousTotalTween:Cancel() end


	-- Total money tween
	local Goal = {Value = NewMoney}
	PreviousTotalTween = Services.TweenService:Create(UI.BLCorner.MoneyDisplay.Amount.Change, TrickleTI, Goal)

	UI.BLCorner.MoneyDisplay.Amount.Change.Value = NewMoney - Change

	UI.BLCorner.MoneyDisplay.Amount.Change.Changed:Connect(function(Value)
		UI.BLCorner.MoneyDisplay.Amount.Text = Modules.Format:FormatComma(Value)
	end)

	PreviousTotalTween:Play()

	Template:TweenSizeAndPosition(UDim2.new(0.4, 0, 0.05, 0), UDim2.new(XPos, 0, YPos, 0), "Out", "Quint", 1.4, true)
	wait(0.5)

	for i = 0, 1, 0.1 do
		Template.TextTransparency = i
		Template.TextStrokeTransparency = 0.5 + i
		wait()
	end

	Template:Destroy()
end


function Animations:GemsChanged(Change, NewGems)
	local Day = os.date("%A")
	local add = ""
	if (Day == "Saturday" or Day == "Sunday" or Day == "Friday") and Change > 0 then
		add = " (X2 DAY)"
	end
	local Template = Dependency.GemsChanged:Clone()
	Template.Position = UDim2.new(0.37, 0, 0.7, -10)
	Template.AnchorPoint = Vector2.new(0, 0.5)
	Template.TextXAlignment = Enum.TextXAlignment.Left
	local Prefix = "+ "
	local YPos = 0.7
	local XPos = 0.15
	local YSize = 0.14

	-- Spending money; make it red and reverse the animation
	if Change < 0 then
		Template.TextColor3 = Color3.fromRGB(231, 68, 68)
		Template.Position = UDim2.new(0.07, 0, 0.55, 0)
		Template.ZIndex += 1
		Prefix = "- "
		YPos = 0.5
		XPos = 0.07
		YSize = 0.12
	end

	Template.Size = UDim2.new(0.5, 0, 0.02, 0)

	Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Change))..add
	Template.Parent = UI.BLCorner

	Template:TweenSize(UDim2.new(0.5, 0, YSize, -10), "Out", "Quart", 0.25, true)

	wait(0.6)

	-- Change in money tween (+ XX money text)
	local Goal = {Value = 0}
	local TrickleChangeTween = Services.TweenService:Create(Template.Change, TrickleTI, Goal)

	Template.Change.Value = Change

	Template.Change.Changed:Connect(function(Value)
		Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Value))..add
	end)

	TrickleChangeTween:Play()

	if PreviousTotalTween then PreviousTotalTween:Cancel() end


	-- Total money tween
	local Goal = {Value = NewGems}
	PreviousTotalTween = Services.TweenService:Create(UI.BLCorner.GemDisplay.Amount.Change, TrickleTI, Goal)

	UI.BLCorner.GemDisplay.Amount.Change.Value = NewGems - Change

	UI.BLCorner.GemDisplay.Amount.Change.Changed:Connect(function(Value)
		UI.BLCorner.GemDisplay.Amount.Text = Modules.Format:FormatComma(Value)
	end)

	PreviousTotalTween:Play()

	Template:TweenSizeAndPosition(UDim2.new(0.4, 0, 0.05, 0), UDim2.new(XPos, 0, YPos, -10), "Out", "Quint", 1.4, true)
	wait(0.5)

	for i = 0, 1, 0.1 do
		Template.TextTransparency = i
		Template.TextStrokeTransparency = 0.5 + i
		wait()
	end

	Template:Destroy()
end

return Animations

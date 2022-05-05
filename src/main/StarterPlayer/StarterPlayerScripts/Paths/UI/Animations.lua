local Animations = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)
--- UI Variables ---
local Day = os.date("%A")
local Mult = 1

if Day == "Saturday" or Day == "Sunday" then
	Mult = 2
else
	Mult = 1
end


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
	if (Day == "Saturday" or Day == "Sunday") and Change > 0 then
		add = " (X2 DAY)"
	end
	local Template = Dependency.MoneyChanged:Clone()
	Template.Position = UDim2.new(0.14, 0, 1.05, 0)
	Template.Size = UDim2.new(1, 0, 0, 0)
	Template.AnchorPoint = Vector2.new(0, 0)
	Template.TextXAlignment = Enum.TextXAlignment.Left
	local Prefix = "+ $ "
	local YPos = 0.9
	local XPos = 0.14
	local YSize = 0.55

	-- Spending money; make it red and reverse the animation
	if Change < 0 then
		Template.TextColor3 = Color3.fromRGB(231, 68, 68)
		Template.Position = UDim2.new(0.14, 0, -0.03, 0)
		Template.ZIndex += 1
		Prefix = "- $ "
		YPos = -0.1
		XPos = 0.14
		YSize = 0.35
	end

	Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Change)) ..add
	Template.Parent = UI.Top.MoneyDisplay

	Template:TweenSize(UDim2.new(1, 0, YSize, 0), "Out", "Quart", 0.25, true)

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
	PreviousTotalTween = Services.TweenService:Create(UI.Top.MoneyDisplay.Amount.Change, TrickleTI, Goal)

	UI.Top.MoneyDisplay.Amount.Change.Value = NewMoney - Change

	UI.Top.MoneyDisplay.Amount.Change.Changed:Connect(function(Value)
		UI.Top.MoneyDisplay.Amount.Text = Modules.Format:FormatComma(Value)
	end)

	PreviousTotalTween:Play()

	Template:TweenSizeAndPosition(UDim2.new(1, 0, 0.05, 0), UDim2.new(XPos, 0, YPos, 0), "Out", "Quint", 1.4, true)
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
	if (Day == "Saturday" or Day == "Sunday") and Change > 0 then
		add = " (X2 DAY)"
	end
	local Template = Dependency.GemsChanged:Clone()
	Template.Position = UDim2.new(0.14, 0, 1.05, 0)
	Template.Size = UDim2.new(1, 0, 0, 0)
	Template.AnchorPoint = Vector2.new(0, 0)
	Template.TextXAlignment = Enum.TextXAlignment.Left
	local Prefix = "+ $ "
	local YPos = 0.9
	local XPos = 0.14
	local YSize = 0.55

	-- Spending money; make it red and reverse the animation
	if Change < 0 then
		Template.TextColor3 = Color3.fromRGB(231, 68, 68)
		Template.Position = UDim2.new(0.14, 0, -0.03, 0)
		Template.ZIndex += 1
		Prefix = "- $ "
		YPos = -0.1
		XPos = 0.14
		YSize = 0.35
	end

	Template.Size = UDim2.new(0.5, 0, 0.02, 0)

	Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Change))..add
	Template.Parent = UI.Top.GemDisplay

	Template:TweenSize(UDim2.new(1, 0, YSize, 0), "Out", "Quart", 0.25, true)

	wait(0.6)

	-- Change in money tween (+ XX money text)
	local Goal = {Value = 0}
	local TrickleChangeTween = Services.TweenService:Create(Template.Change, TrickleTI, Goal)

	Template.Change.Value = Change

	Template.Change.Changed:Connect(function(Value)
		Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Value))
	end)

	TrickleChangeTween:Play()

	if PreviousTotalTween then PreviousTotalTween:Cancel() end


	-- Total money tween
	local Goal = {Value = NewGems}
	PreviousTotalTween = Services.TweenService:Create(UI.Top.GemDisplay.Amount.Change, TrickleTI, Goal)

	UI.Top.GemDisplay.Amount.Change.Value = NewGems - Change

	UI.Top.GemDisplay.Amount.Change.Changed:Connect(function(Value)
		UI.Top.GemDisplay.Amount.Text = Modules.Format:FormatComma(Value)
	end)

	PreviousTotalTween:Play()

	Template:TweenSizeAndPosition(UDim2.new(1, 0, 0.05, 0), UDim2.new(XPos, 0, YPos, 0), "Out", "Quint", 1.4, true)
	wait(0.5)

	for i = 0, 1, 0.1 do
		Template.TextTransparency = i
		Template.TextStrokeTransparency = 0.5 + i
		wait()
	end

	Template:Destroy()
end

return Animations

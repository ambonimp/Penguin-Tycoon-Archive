local Animations = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local Dependency = Paths.Dependency:FindFirstChild(script.Name)


-- Other Variables
--[[ local CONFETII_COLORS = {
	Color3.fromRGB(168,100,253),
	Color3.fromRGB(41,205,255),
	Color3.fromRGB(120,255,68),
	Color3.fromRGB(255,113,141),
	Color3.fromRGB(253,255,106)
} *]]

local CONFETII_COLORS = {
	Color3.fromRGB(157, 92, 13),
	Color3.fromRGB(234, 189, 23),
	Color3.fromRGB(234, 203, 76),
	Color3.fromRGB(234, 209, 117),
}


local IS_QA = (game.GameId == 3425594443)

--- Other Variables
local TrickleTI = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local PreviousTotalTween = false

local Rand = Random.new()

--- Updating Functions ---
function Animations:IncomeChanged(Change, NewIncome)
	local Template = Dependency.IncomeChanged:Clone()

	Template.Size = UDim2.new(1, 0, 0.02, 0)
	Template.Text = '+ <font color="rgb(57,225,91)">$ '..Modules.Format:FormatComma(Change).."</font> Income ($ "..Modules.Format:FormatComma(NewIncome)..")"
	Template.Parent = UI.Top.Bottom

	Template:TweenSize(UDim2.new(1, 0, 0.2, 0), "Out", "Quart", 0.25, true)

	task.wait(1)

	Template:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Quart", 1.5, true)

	task.wait(0.6)

	for i = 0, 1, 0.1 do
		Template.TextTransparency = i
		Template.TextStrokeTransparency = 0.5 + i
		task.wait()
	end

	Template:Destroy()
end


function Animations:MoneyChanged(Change, NewMoney)
	local Day = os.date("%A")
	local add = ""
	--[[
	if (Day == "Saturday" or Day == "Sunday" or Day == "Friday" ) and Change > 0 and not IS_QA then
		add = " (X2 DAY)"
	end]]
	if game.Players.LocalPlayer:GetAttribute("x3MoneyBoost") then
		add = add.." (x3)"
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

		add = ""
	end

	Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Change)) ..add
	Template.Parent = UI.Top.Currencies.MoneyDisplay

	Template:TweenSize(UDim2.new(1, 0, YSize, 0), "Out", "Quart", 0.25, true)

	task.wait(0.6)

	-- Change in money tween (+ XX money text)
	local Goal = {Value = 0}
	local TrickleChangeTween = Services.TweenService:Create(Template.Change, TrickleTI, Goal)

	Template.Change.Value = Change
	Template.Change.Changed:Connect(function(Value)
		Template.Text = Prefix..Modules.Format:FormatComma(math.abs(Value)).. (Value > 0 and add or "")
	end)

	TrickleChangeTween:Play()

	if PreviousTotalTween then PreviousTotalTween:Cancel() end


	-- Total money tween
	local Goal = {Value = NewMoney}
	PreviousTotalTween = Services.TweenService:Create(UI.Top.Currencies.MoneyDisplay.Amount.Change, TrickleTI, Goal)

	UI.Top.Currencies.MoneyDisplay.Amount.Change.Value = NewMoney - Change

	UI.Top.Currencies.MoneyDisplay.Amount.Change.Changed:Connect(function(Value)
		UI.Top.Currencies.MoneyDisplay.Amount.Text = Modules.Format:FormatComma(Value)
	end)

	PreviousTotalTween:Play()

	Template:TweenSizeAndPosition(UDim2.new(1, 0, 0.05, 0), UDim2.new(XPos, 0, YPos, 0), "Out", "Quint", 1.4, true)
	task.wait(0.5)

	for i = 0, 1, 0.1 do
		Template.TextTransparency = i
		Template.TextStrokeTransparency = 0.5 + i
		task.wait()
	end

	Template:Destroy()
end


function Animations:GemsChanged(Change, NewGems)
	local Day = os.date("%A")
	local add = ""
	--[[
	if (Day == "Saturday" or Day == "Sunday" or Day == "Friday") and Change > 0 then
		add = " (X2 DAY)"
	end]]
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
	Template.Parent = UI.Top.Currencies.GemDisplay

	Template:TweenSize(UDim2.new(1, 0, YSize, 0), "Out", "Quart", 0.25, true)

	task.wait(0.6)

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
	PreviousTotalTween = Services.TweenService:Create(UI.Top.Currencies.GemDisplay.Amount.Change, TrickleTI, Goal)

	UI.Top.Currencies.GemDisplay.Amount.Change.Value = NewGems - Change

	UI.Top.Currencies.GemDisplay.Amount.Change.Changed:Connect(function(Value)
		UI.Top.Currencies.GemDisplay.Amount.Text = Modules.Format:FormatComma(Value)
	end)

	PreviousTotalTween:Play()

	Template:TweenSizeAndPosition(UDim2.new(1, 0, 0.05, 0), UDim2.new(XPos, 0, YPos, 0), "Out", "Quint", 1.4, true)
	task.wait(0.5)

	for i = 0, 1, 0.1 do
		Template.TextTransparency = i
		Template.TextStrokeTransparency = 0.5 + i
		task.wait()
	end

	Template:Destroy()
end

function Animations.BlinkTransition(OnHalfPoint, AlignCamera)
    local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local In = Services.TweenService:Create(Paths.UI.SpecialEffects.Bloom, Info, {BackgroundTransparency = 0})
    In:Play()
    In.Completed:Wait()

    OnHalfPoint()
    if AlignCamera then
        local Camera = workspace.Camera
        Camera.CFrame = CFrame.new(Camera.CFrame.Position) * Paths.Player.Character.HumanoidRootPart.CFrame.Rotation
    end

    local Out = Services.TweenService:Create(Paths.UI.SpecialEffects.Bloom, Info, {BackgroundTransparency = 1})
    Out:Play()
    Out.Completed:Wait()

end

function Animations.Confetti(Count, Size)
	Count = Count or Rand:NextInteger(35, 45)
	Size = Size or Vector2.new(1, 1.4)

	local Container = Paths.UI.SpecialEffects.Confetti

	local ViewportCam = Container:FindFirstChild("Camera")
	if not ViewportCam then
		ViewportCam = Instance.new("Camera")
		ViewportCam.Parent = Container
		Container.CurrentCamera = ViewportCam
	end

	local ParticleTemp = Instance.new("Part")
	ParticleTemp.Anchored = true
	ParticleTemp.Size = Vector3.new(Size.X, Size.Y, 0.005)


	local BASE = ViewportCam.CFrame

	local ViewportSize = workspace.CurrentCamera.ViewportSize
	local AspectRatio = ViewportSize.X / ViewportSize.Y

	local Deph = (Size.X * Count / 2) / math.tan(math.rad(ViewportCam.FieldOfView / 2)) / AspectRatio
	local Height = Deph * math.tan(math.rad(ViewportCam.FieldOfView / 2))


	for j = 1, 3 do
		local XOffset = Size.X * Rand:NextInteger(2, 4)
		local YOffset = Size.Y / 2

		for i = 1, Count do
			if Rand:NextInteger(1, 5) <= 4 then
				local Start = BASE * CFrame.new(-(Size.X/2) + (i-(Count/2)) * (Size.X) + XOffset, Height + YOffset, -Deph)
				local GoalP = Start * CFrame.new(0, -2*(Height + YOffset), 0).Position
				local GoalO = Vector3.new(1, 0, 1) * (Rand:NextInteger(0, 1) == 0 and 1 or -1) * 360

				local Particle = ParticleTemp:Clone()
				Particle.Name = i
				Particle.Color = CONFETII_COLORS[i % #CONFETII_COLORS + 1]
				Particle.Transparency = 0
				Particle.CFrame = Start
				Particle.Anchored = true
				Particle.Parent = Container

				local Delay = (j - 1) + Rand:NextNumber(0, 2)

				local Length = Rand:NextNumber(1, 2)
				local Fall = Paths.Services.TweenService:Create(Particle, TweenInfo.new(Length, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, Delay), {Position = GoalP})
				local Flip = Paths.Services.TweenService:Create(Particle, TweenInfo.new(Length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, math.huge, true, Delay), {Orientation = ParticleTemp.Orientation + GoalO})

				Fall.Completed:Connect(function()
					Flip:Cancel() -- Just in case
					Particle:Destroy()
				end)

				Fall:Play()
				Flip:Play()

			end
		end

	end

end

--[[ -- Testing
Paths.Services.InputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E then
		Animations.Confetti()
	end
end) *]]


return Animations

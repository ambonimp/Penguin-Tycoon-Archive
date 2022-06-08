local TweenService = game:GetService("TweenService")
local SpinTheWheel = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI.Center.Spin

local soundNums = {25,70,115,160,205,250,290,340}
local spinning = false

local winText = {
	[1] = "You won x1 Super Fish Luck Boost!",
	[2] = "You won x1 Triple Money Boost!",
	[3] = "You won 10 gems!!",
	[4] = "You won 30 gems!",
	[6] = "You won x1 Ultra Fish Luck Boost!",
	
}
local positions = {
	[8] = {-25,-65},
	[7] = {-70,-110},
	[6] = {-115,-155},
	[5] = {-160,-200},
	[4] = {-205,-245},
	[3] = {-250,-290},
	[2] = {-295,-335},
	[1] = {-20,20},
}

function spinWheel()
	spinning = true
	
	UI.Wheel.Rotation = 0
	local result = Remotes.SpinTheWheel:InvokeServer("GetResult")
	local low = math.min(positions[result][1],positions[result][2])
	local high = math.max(positions[result][1],positions[result][2])
	local chosen = 360-(math.random(low,high))
	UI.Center.Button.TheText.Text = "Spinning.."
	local spinSpeed = .0001
	local timePassed = 0
	while spinning do
		if UI.Wheel.Rotation == 360 then
			UI.Wheel.Rotation = 0
		end
		local tweenInfo = TweenInfo.new(spinSpeed)
		local tween = TweenService:Create(UI.Wheel,tweenInfo,{Rotation = UI.Wheel.Rotation + 5})
		tween:Play()
		tween.Completed:Wait()
		timePassed += spinSpeed
		spinSpeed *= 1.015
		if spinSpeed >= .05 then
			spinning = false
		end
		if table.find(soundNums,UI.Wheel.Rotation) then
			Paths.Audio.Tick:Play()
		end
	end
	while UI.Wheel.Rotation ~= chosen do
		UI.Wheel.Rotation = UI.Wheel.Rotation + 1
		if UI.Wheel.Rotation > 360 then
			if table.find(soundNums,UI.Wheel.Rotation-360) then
				Paths.Audio.Tick:Play()
			end
		else
			if table.find(soundNums,UI.Wheel.Rotation) then
				Paths.Audio.Tick:Play()
			end
		end
		
		task.wait()
	end
	Remotes.SpinTheWheel:InvokeServer("ClaimReward")
	spinning = false
	UI.Exit.Visible = true
	UI.Center.Button.TheText.Text = "Spin 99R$"
	if result == 7 then
		local text = "You won $ "..Modules.Format:FormatComma(Paths.Player:GetAttribute("Income")*20).."!"
		Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
	elseif winText[result] then
		Paths.Modules.Setup:Notification(winText[result],Color3.new(0.945098, 0.525490, 0.282352),7)
	end
end

UI.Wheel["7"].Icon.Text.Text = Modules.Format:FormatComma(Paths.Player:GetAttribute("Income")*20)

UI.Center.Button.MouseButton1Down:Connect(function()
	if spinning then return end
	local Spins = Remotes.GetStat:InvokeServer("Spin")
	UI.Exit.Visible = false
	if Spins[1] then
		spinWheel()
	else
		Services.MPService:PromptProductPurchase(Paths.Player, 1271390016)
	end
end)

function Remotes.SpinTheWheel.OnClientInvoke()
	spinWheel()
end

local Spins = Remotes.GetStat:InvokeServer("Spin")
if Spins[1] then
	UI.Center.Button.TheText.Text = "Spin For Free"
else
	UI.Center.Button.TheText.Text = "Spin 99R$"
end

Modules.Buttons:UIOn(UI,true)

return SpinTheWheel
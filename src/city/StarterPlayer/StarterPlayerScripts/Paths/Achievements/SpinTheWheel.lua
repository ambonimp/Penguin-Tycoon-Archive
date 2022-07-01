local DataStoreService = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")
local SpinTheWheel = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI.Center.Achievements.Sections.Spin

local SpinTime = (12*60*60)
local soundNums = {25,70,115,160,205,250,290,340}
local spinning = false
local rotations = {0,45,90,135,180,225,270,315}

if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
	SpinTime = 1*60
end

local winText = {
	[1] = "You received x1 Super Fish Luck Boost!",
	[2] = "You received x1 Triple Money Boost!",
	[3] = "You received 10 gems!!",
	[4] = "You received 30 gems!",
	[6] = "You received x1 Ultra Fish Luck Boost!",

	[1] = "You received 7 gems!!",
	[2] = "You received x1 Super Fish Luck Boost!",
	[3] = "You received 5 gems!!",
	[4] = "You received 10 gems!",

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

UI.Wheel.Rotation = rotations[math.random(1,#rotations)]

function spinWheel()
	spinning = true

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
		spinSpeed *= 1.04
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
	local check,am = Remotes.SpinTheWheel:InvokeServer("ClaimReward")
	spinning = false

	if check == "Owned" then
		local text = "Already owned! You received "..am.." gems instead!"
		Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
	else
		if result == 7 then
			local text = "You received $ "..Modules.Format:FormatComma(Paths.Player:GetAttribute("Income")*20).."!"
			Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
		elseif winText[result] then
			Paths.Modules.Setup:Notification(winText[result],Color3.new(0.945098, 0.525490, 0.282352),7)
		end
	end

	local Spins = Remotes.GetStat:InvokeServer("Spin")
	if Spins[1] then
		Paths.UI.Center.Achievements.Buttons.Spin.Notif.Visible = true
		Paths.UI.Right.Buttons.Achievements.Notif.Visible = true
		UI.Center.Button.TheText.Text = "Spin For Free"
	else
		UI.Center.Button.TheText.Text = "Spin 99R$"
	end

	task.wait(4)
	if spinning == false then
		UI.Wheel.Rotation = rotations[math.random(1,#rotations)]
	end
end

UI.Center.Button.MouseButton1Down:Connect(function()
	if spinning then return end
	local Spins = Remotes.GetStat:InvokeServer("Spin")
	if Spins[1] then
		Paths.UI.Center.Achievements.Buttons.Spin.Notif.Visible = false
		Paths.UI.Right.Buttons.Achievements.Notif.Visible = false
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
	Paths.UI.Center.Achievements.Buttons.Spin.Notif.Visible = true
	Paths.UI.Right.Buttons.Achievements.Notif.Visible = true
	UI.Center.Button.TheText.Text = "Spin For Free"
else
	UI.Center.Button.TheText.Text = "Spin 99R$"
end

task.spawn(function()
	 local nextReward = Spins[3]
	 if os.time() > nextReward then
		nextReward = os.time()+SpinTime
	 end

	 local function toHMS(s)
		return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
	end

	 local function start()
		while os.time() < nextReward do
			local tLeft = nextReward - os.time()
			UI.FreeSpin.Text = "Next Free Spin: "..toHMS(tLeft)
			task.wait(1)
		end
		task.wait(3)
		if spinning then
			repeat task.wait()
			until not spinning
		end
		Paths.UI.Center.Achievements.Buttons.Spin.Notif.Visible = true
		Paths.UI.Right.Buttons.Achievements.Notif.Visible = true
		UI.Center.Button.TheText.Text = "Spin For Free"
		nextReward = Remotes.SpinTheWheel:InvokeServer("CheckGift")
		start()
	 end

	 start()
end)

return SpinTheWheel
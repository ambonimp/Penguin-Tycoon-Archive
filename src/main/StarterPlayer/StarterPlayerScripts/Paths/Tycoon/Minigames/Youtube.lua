local minigame = {}


--- Main Variables ---
local paths = require(script.Parent.Parent.Parent)

local services = paths.Services
local modules = paths.Modules
local remotes = paths.Remotes
local ui = paths.UI

local dependency = paths.Dependency:WaitForChild("YoutubeMinigame")


local MAX_SCORE = 40
local GAME_LENGTH = 30

local COLLECT_COOLDOWN = 1
local UPLOAD_COOLDOWN = 30

local DISPLACEMENT_X = 0.5 -- Max is 0.5
local JUMP_LENGTH = 3

local WAVE_SIZE = 0.3

local FISH_IMAGES = {
	"rbxassetid://9793496395",
	"rbxassetid://9793496255",
	"rbxassetid://9793496133",
	"rbxassetid://9793496015",
	"rbxassetid://9793495882",
	"rbxassetid://9793495773",
	"rbxassetid://9793495634",
	"rbxassetid://9793495498",
	"rbxassetid://9793495370",
	"rbxassetid://9793495242",
	"rbxassetid://9793495117",
	"rbxassetid://9793494979",
	"rbxassetid://9793494883",
	"rbxassetid://9793494783",
	"rbxassetid://9793494709",
	"rbxassetid://9793494562",
	"rbxassetid://9793494375",
	"rbxassetid://9793494251",
	"rbxassetid://9793494145",
	"rbxassetid://9793494070",
	"rbxassetid://9793493992",
	"rbxassetid://9793493900",
}

local OBSTACLES = {
	"rbxassetid://9844218717",
	"rbxassetid://9844218910",
	"rbxassetid://9844219003",
	"rbxassetid://9844219118",
	"rbxassetid://9844219273",
}

local KEYBINDS = {
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
}




local rand = Random.new()

local player = game:GetService("Players").LocalPlayer

local character
local partsMadeInvisible = {}

local camera = workspace.CurrentCamera


local frame = ui.Full:WaitForChild("YoutubeMinigame") -- We pretend it's on the screen
local gameScreen = frame.Play
local startScreen = frame.Start
local editingscreen = frame.Edit
local resultsScreen = frame.Results


-- Fish currently in play
local lives
local score
local highscore

local identifier = 0
local fishesSpawned = 0

local collectables = {}
local jumps = {}

local currentComputer
local computers = {}

local playing


local function toSuffix(n)
    n = tonumber(n)
    local suffixes = {"K", "M", "B", "T", "Q", "Qu", "S", "Se", "O", "N", "D"}

    for i = #suffixes, 1, -1 do
        local v = math.pow(10, i * 3)
        if n >= v then
            local returning = ("%.3f"):format(n / v)
            return returning:sub(1, #returning - 1):gsub("%.", ".") .. suffixes[i]
        end
    end

    return tostring(n)
end

local function loop(x, min, max)
	if x > max then
		return min
	elseif x < min then
		return max
	else
		return x
	end
end

local function tweenNumber(textLbl, goal, format)
	textLbl.Text = 0

	local counter = Instance.new("IntValue")
	counter.Value = 0
	counter.Changed:Connect(function(value)
		textLbl.Text = format(value)
	end)

	local countUp = services.TweenService:Create(counter, TweenInfo.new(3, Enum.EasingStyle.Linear), {Value = goal})
	countUp.Completed:Connect(function()
		counter:Destroy()
	end)

	countUp:Play()

	return countUp
end

local function toggleOtherUI(toggle)
	ui.Center.Visible = toggle
	ui.Left.Visible = toggle
	ui.Right.Visible = toggle
	ui.Top.Visible = toggle
	ui.Bottom.Visible = toggle
end

local function toggleProximityPrompts(toggle)
	for _, computer in ipairs(computers) do
		local prompt = computer.Seat.ProximityPrompt
		prompt.Enabled = toggle
	end
end

function transitionFrames(old, new, dir, scale)
	dir = dir or 1

	old.ZIndex = 0

	old:TweenSize(if scale then UDim2.fromScale(0.8, 0.8) else UDim2.fromScale(1, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.5, false, function()
		old:TweenPosition(UDim2.fromScale(1.5 * dir, 0.5), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 1, false, function()
			old.Visible = false
			old.Position = UDim2.fromScale(0.5, 0.5)
			old.Size = UDim2.fromScale(1, 1)
		end)

		new.ZIndex = 1
		new.Position = UDim2.fromScale(-dir * 1.5, 0.5)
		new.Size = scale and UDim2.fromScale(0.6, 0.6) or UDim2.fromScale(1, 1)
		new.Visible = true
		new:TweenSizeAndPosition(UDim2.fromScale(1, 1), UDim2.fromScale(0.5, 0.5), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 1, true)

	end)

	if scale then
		task.wait(0.8)
	end

end



function destroyCollectable(id)
	jumps[id]:Disconnect()
	jumps[id] = nil

	collectables[id]:Destroy()
	collectables[id] = nil

	if playing then
		if lives == 0 or fishesSpawned == MAX_SCORE then
			results() -- End round
		else
			local typ = if rand:NextInteger(1, 4) == 1 then "Obstacle" else "Fish"
			task.delay(COLLECT_COOLDOWN, spawnCollectable, typ)
		end
	end

end

function collectCollectable(id)
	-- Special effects
	local collectable = collectables[id]
	local position = collectable.Position

	local isFish = collectable.Name == "Fish"
	if isFish then
		score += 1
		gameScreen.Score.TextLabel.Text = "Score: " .. score
	else
		gameScreen.Lives[lives].Visible = false
		lives -= 1
	end

	-- Special Effects
	local bubble = dependency.Bubble:Clone()
	bubble.Size = UDim2.fromScale(0, 0)
	bubble.Visible = true
	bubble.Position = position
	bubble.Parent = gameScreen

	local bubbleSize = rand:NextNumber(0.15, 0.2)
	local bubbleTween = services.TweenService:Create(bubble, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = 0.5, Size = UDim2.fromScale(bubbleSize, bubbleSize)})
	bubbleTween.Completed:Connect(function()
		bubble:Destroy()
	end)
	bubbleTween:Play()


	local scoreParticle = dependency.ScoreParticle:Clone()
	if isFish then
		scoreParticle.TextColor3 = Color3.fromRGB(0, 255, 0)
		scoreParticle.Text = "+1"
	else
		scoreParticle.TextColor3 = Color3.fromRGB(255, 0, 0)
		scoreParticle.Text = "-1"
	end

	scoreParticle.Visible = true
	scoreParticle.Position = position
	scoreParticle.Parent = gameScreen

	local scoreTween = services.TweenService:Create(scoreParticle, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		TextTransparency = 0.8,
		Size = UDim2.fromScale(bubbleSize, bubbleSize),
		Position = position - UDim2.fromScale(0, 0.1)
	})

	scoreTween.Completed:Connect(function()
		scoreParticle:Destroy()
	end)
	scoreTween:Play()


	destroyCollectable(id)
end

function spawnCollectable(typ)
	identifier += 1
	local id = identifier

	local collectable = dependency.Collectable:Clone()
	collectable.Name = typ
	collectable.Image = if typ == "Fish" then FISH_IMAGES[rand:NextInteger(1, #FISH_IMAGES)] else OBSTACLES[rand:NextInteger(1, #OBSTACLES)]
	collectables[id] = collectable

	-- Collecting
	collectable.MouseButton1Down:Connect(function()
		collectCollectable(id)
	end)

	local inputLbl = collectable.Input
	inputLbl.Visible = true
	if services.InputService.GamepadEnabled then
		local keyCode = KEYBINDS[id % 4 + 1]
		inputLbl.KeyCode.Text = string.gsub(keyCode.Name, "Button", "")
		collectable:SetAttribute("KeyCode", keyCode.Name)

		inputLbl.Touch.Visible = false
		inputLbl.KeyCode.Visible = true
	else
		inputLbl.Touch.Visible = true
		inputLbl.KeyCode.Visible = false
	end

	-- Jump
	local jumpDir = rand:NextInteger(0, 1) == 0 and -1 or 1
	local size = collectable.Size.Y.Scale

	local origin = {X = rand:NextNumber(0, DISPLACEMENT_X - 0.05), Y = 1 -WAVE_SIZE + size/2}
	origin.X = jumpDir == 1 and origin.X or 1 - origin.X

	-- Get random height within range of config and clamps to ensure it doesn't go offscreen
	local jumpHeight = 1 * (1 -WAVE_SIZE - size) +  size

	-- Play jump
	collectable.Visible = true
	collectable.Position = UDim2.fromScale(origin.X, origin.Y)
	collectable.Parent = gameScreen

	local x = 0
	jumps[id] = services.RunService.RenderStepped:Connect(function(dt)
		if x < DISPLACEMENT_X then
			-- Parabolic motion
			x += dt / (JUMP_LENGTH / DISPLACEMENT_X)
			local y = (-math.pow(x-DISPLACEMENT_X/2, 2) + math.pow(DISPLACEMENT_X/2, 2)) / (DISPLACEMENT_X / 4) * (jumpHeight / DISPLACEMENT_X)

			collectable.Position = UDim2.fromScale(origin.X + jumpDir * x, origin.Y - y)
			collectable.Rotation = x * 60 * jumpDir

		else
			destroyCollectable(id)
		end

	end)

	-- Only four can be visible at the same time
	task.wait(JUMP_LENGTH / 4 + 0.5)

end

function play()
	playing = true
	score = 0
	lives = 3
	identifier = 0
	fishesSpawned = 0

	gameScreen.Score.TextLabel.Text = "Score: " .. score
	for _, heart in ipairs(gameScreen.Lives:GetChildren()) do
		if heart:IsA("ImageLabel") then
			heart.Visible = true
		end
	end

	-- Countdown
	local timer = gameScreen.Countdown
	timer.Size = UDim2.fromScale(1, 0)

	startScreen.Visible = false
	gameScreen.Visible = true

	-- Countdown
	for i = 3, 1, -1 do
		timer.Text = i

		local open = services.TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(1, 0.153)})
		open:Play()
		open.Completed:Wait()

		local close = services.TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(1, i == 1 and 0.07 or 0)})
		close:Play()
		close.Completed:Wait()

	end

	-- Timer
	task.spawn(function()
		timeRemainingInGame = GAME_LENGTH

		while playing and timeRemainingInGame >= 0 do
			timer.Text = string.format("Collect the fish (%s)", timeRemainingInGame)
			timeRemainingInGame -= 1

			if timeRemainingInGame ~= 0 then
				task.wait(1)
			end
		end

		if playing then results() end

	end)

	-- Collecting
	for i, keycode in ipairs(KEYBINDS) do
		services.ContextActionService:BindActionAtPriority("MinigameInput" .. i, function(_, state)
			if state == Enum.UserInputState.Begin then
				for j = identifier, identifier - 4, -1 do
					-- TODO: Could be done better with some math
					local collectable = collectables[j]
					if collectable then
						if collectable:GetAttribute("KeyCode") == keycode.Name then
							collectCollectable(j)
						end
					end
				end
			end
		end, false, Enum.ContextActionPriority.High.Value, keycode)
	end

	-- Fish spawning
	for i = 1, 4 do
		local typ = if rand:NextInteger(1, 4) == 1 then "Obstacle" else "Fish"
		spawnCollectable(typ)
	end

end

function results()
	playing = false

	-- Stop taking input
	for id in ipairs(KEYBINDS) do
		services.ContextActionService:UnbindAction("MinigameInput" .. id)
	end

	-- Let all the fish die down
	for id in pairs(collectables) do
		destroyCollectable(id)
	end


	transitionFrames(gameScreen, resultsScreen, -1, true)
	editingscreen.EditedTracks.Ignore:ClearAllChildren()

	-- Numbers
	local scoreLbl = resultsScreen.Score
	scoreLbl.TextLabel.Text = "Score: " .. score

	local rewardLbl = resultsScreen.Reward
	local gemsEarned = if score == MAX_SCORE then 3 else (if score >= 25 then 2 else (if score >= 10 then 1 else 0))
	rewardLbl.TextLabel.Text = "Gems Won: " .. gemsEarned *  remotes.GetStat:InvokeServer("Gem Multiplier")

	local subs = rand:NextInteger(6000, 10000)
	local count1 = tweenNumber(scoreLbl.Bonus.TextLabel, subs, function(x)
		return string.format("+%s Subs", x)
	end)

	local likes =  math.floor(subs * rand:NextInteger(2, 2.5))
	local count2 = tweenNumber(rewardLbl.Bonus.TextLabel, likes, function(x)
		return string.format("+%s Likes", x)
	end)

	-- Highscore
	local highscoreLbl = scoreLbl.NewHighscore
	if score > highscore then
		highscoreLbl.Visible = true
	else
		highscoreLbl.Visible = false
	end

	local active = true

	local previews = resultsScreen.Preview
	task.spawn(function()
		while active do
			for i = 0, 2 do
				previews[loop(1 + i, 1, 3)].ZIndex = 30
				previews[loop(2 + i, 1, 3)].ZIndex = 20
				previews[loop(3 + i, 1, 3)].ZIndex = 10
				task.wait(0.5)
			end
		end
	end)

	-- Close everything
	local uploadConn
	uploadConn = resultsScreen.Upload.MouseButton1Down:Connect(function()
		uploadConn:Disconnect()
		active = false

		count1:Cancel()
		count2:Cancel()

		remotes.YoutubeMinigameFinished:FireServer(currentComputer, score, subs, likes)

		for _, computer in ipairs(computers) do
			local screen = computer.Screen

			local uploadFrame = screen:WaitForChild("Upload")
			local startFrame = screen:WaitForChild("Start")

			uploadFrame.Enabled = true
			startFrame.Enabled = false


			local progressBar = uploadFrame.Progress.Bar
			progressBar.Size = UDim2.fromScale(0, 1)
			progressBar:TweenSize(UDim2.fromScale(1, 1), Enum.EasingDirection.In, Enum.EasingStyle.Linear, UPLOAD_COOLDOWN, false, function()
				toggleProximityPrompts(true)
				uploadFrame.Enabled = false
				startFrame.Enabled = true
			end)

		end

		close()

	end)

end

function open()
	for _, computer in ipairs(computers) do
		local screen = computer.Screen
		screen:WaitForChild("Start").Enabled = false
		screen:WaitForChild("Upload").Enabled = false
	end

	-- Load highscore
	highscore = remotes.GetStat:InvokeServer("Youtube Minigame Score")
	local highscoreLbl = startScreen.Information.Highscore
	highscoreLbl.Text = "Your highscore: " .. highscore

	local stats = remotes.GetStat:InvokeServer("YoutubeStats")
    local statsLbl = startScreen.Information.Stats
    statsLbl.Likes.Value.Text = toSuffix(stats.Likes)
    statsLbl.Subscribers.Value.Text = toSuffix(stats.Subscribers)

	toggleOtherUI(false)
	frame.Visible = true
	startScreen.Visible = true
	gameScreen.Visible = false

end

function close()
	currentComputer = nil

	-- Reset character
	character = player.Character
	local humanoid = character.Humanoid
	character.PrimaryPart.Anchored = false
	humanoid.Sit = false

	for _, basePart in ipairs(partsMadeInvisible) do
		basePart.Transparency = 0
	end

	-- Reset camera
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid

	-- Reset ui
	toggleOtherUI(true)
	frame.Visible = false
	gameScreen.Visible = false
	startScreen.Visible = false
	editingscreen.Visible = false
	resultsScreen.Visible = false

end

local function loadComputer(computer)
	table.insert(computers, computer)

	local screen = computer:WaitForChild("Screen")
	local seat = computer:WaitForChild("Seat") -- Created on the client so no one else can use it

	local prompt = Instance.new("ProximityPrompt")
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 7
	prompt.RequiresLineOfSight = false
	prompt.ActionText = "Upload video"
	prompt.Parent = seat
	prompt.Enabled = if #computers == 0 then true else computers[1].Seat.ProximityPrompt.Enabled

	prompt.Triggered:Connect(function()
		toggleProximityPrompts(false)

		character = player.Character
		if character then
			local humanoid = character.Humanoid

			seat:Sit(humanoid)
			character.PrimaryPart.Anchored = true

			-- Let player see their character sit down
			task.wait(0.2)

			-- Hide character so it doesn't get in the way
			for _, basePart in ipairs(character:GetDescendants()) do
				if basePart:IsA("BasePart") and basePart.Transparency == 0 then
					table.insert(partsMadeInvisible, basePart)
					basePart.Transparency = 1
				end
			end

			-- Position camera so can display ui on screen
			camera.CameraType = Enum.CameraType.Scriptable

			local scale = 1 + (1 - frame.Size.Y.Scale)
			local screenSize = screen.Size * scale
			local deph = (screenSize.Y / 2) / math.tan(math.rad(camera.FieldOfView / 2)) + (screenSize.Z / 2)

			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local transition = services.TweenService:Create(camera, tweenInfo, {CFrame = screen.CFrame * CFrame.fromEulerAnglesYXZ(0, math.pi, 0) * CFrame.new(0, 0, deph)})
			transition.Completed:Connect(function()
				currentComputer = computer.Name
				open()
			end)

			transition:Play()
		end

	end)

end


startScreen.Buttons.Play.MouseButton1Down:Connect(function()
	play()
end)

startScreen.Buttons.Exit.MouseButton1Down:Connect(function()
	toggleProximityPrompts(true)

	for _, computer in ipairs(computers) do
		local screen = computer.Screen
		screen:WaitForChild("Start").Enabled = true
		screen:WaitForChild("Upload").Enabled = false
	end

	close()

end)

-- open
local function init()
	computers = {}

	for i = 1, 2 do
		local name = "Gaming Desk#" .. i

		if remotes.GetStat:InvokeServer("Tycoon")[name]then
			loadComputer(paths.Tycoon.Tycoon:WaitForChild(name))
		else
			local conn
			conn = paths.Tycoon.Tycoon.ChildAdded:Connect(function(child)
				if child.Name == name then
					conn:Disconnect()
					loadComputer(child)
				end
			end)

		end

	end

end

init()
task.spawn(function()
    repeat task.wait() until modules.Rebirths
    modules.Rebirths.Rebirthed:Connect(init)
end)

return minigame

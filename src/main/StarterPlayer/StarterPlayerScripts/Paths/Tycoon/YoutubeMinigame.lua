local minigame = {}


--- Main Variables ---
local paths = require(script.Parent.Parent)

local services = paths.Services
local modules = paths.Modules
local remotes = paths.Remotes
local ui = paths.UI

local dependency = paths.Dependency:WaitForChild(script.Name)



local GAME_LENGTH = 20
local COLLECT_COOLDOWN = 1
local UPLOAD_COOLDOWN = 60

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

local KEYBINDS = {
    {Enum.KeyCode.R,Enum.KeyCode.ButtonX},
    {Enum.KeyCode.T,Enum.KeyCode.ButtonY},
    {Enum.KeyCode.Y,Enum.KeyCode.ButtonA},
    {Enum.KeyCode.U,Enum.KeyCode.ButtonB},
}




local rand = Random.new()

local player = game:GetService("Players").LocalPlayer

local character
local partsMadeInvisible = {}


local camera = workspace.CurrentCamera




local psuedoFrame = ui.Full:WaitForChild(script.Name) -- We pretend it's on the screen
local gameScreen = psuedoFrame.Play
local startScreen = psuedoFrame.Start
local editingscreen = psuedoFrame.Edit
local resultsScreen = psuedoFrame.Results

local proximityPrompts = {}

local fishInstances = gameScreen.Fish:GetChildren()

-- Fish currently in play
local fishCollected
local highscore

local jumpingFish = {}
local jumps = {}

local currentComputer
local screens = {}

local playing
local timeRemainingInGame


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
    for _, prompt in ipairs(proximityPrompts) do
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

function destroyFish(inputId)
    jumps[inputId]:Disconnect()
    jumps[inputId] = nil

    jumpingFish[inputId].Visible = false
    jumpingFish[inputId] = nil

    task.delay(COLLECT_COOLDOWN, spawnFish, inputId)
end

 function collectFish(inputId)
    fishCollected += 1
    gameScreen.Score.TextLabel.Text = "Score: " .. fishCollected

    -- Special effects
    local fish = jumpingFish[inputId]
    local position = fish.Position

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


    destroyFish(inputId)
end

 function spawnFish(inputId)
    if not playing then
        return
    end


    local fish = fishInstances[inputId] -- pooling
    fish.Image = FISH_IMAGES[rand:NextInteger(1, #FISH_IMAGES)]

    -- Collecting
    local inputLbl = fish.Input
    inputLbl.Visible = true
    if services.InputService.TouchEnabled and not services.InputService.MouseEnabled then -- Mobile
        inputLbl.Touch.Visible = true
        inputLbl.KeyCode.Visible = false
    else
        local keyCode = services.InputService.GamepadEnabled and KEYBINDS[inputId][2] or KEYBINDS[inputId][1]
        inputLbl.KeyCode.Text = string.gsub(keyCode.Name, "Button", "")

        inputLbl.Touch.Visible = false
        inputLbl.KeyCode.Visible = true
    end

    jumpingFish[inputId] = fish


    local jumpDir = rand:NextInteger(0, 1) == 0 and -1 or 1
    local fishSize = fish.Size.Y.Scale

    local origin = {X = rand:NextNumber(0, DISPLACEMENT_X - 0.05), Y = 1 -WAVE_SIZE + fishSize/2}
    origin.X = jumpDir == 1 and origin.X or 1 - origin.X

    -- Get random height within range of config and clamps to ensure it doesn't go offscreen
    local jumpHeight = 1 * (1 -WAVE_SIZE - fishSize) +  fishSize

    -- Play jump
    fish.Visible = true
    fish.Position = UDim2.fromScale(origin.X, origin.Y)
    fish.Parent = gameScreen

    local x = 0
    jumps[inputId] = services.RunService.RenderStepped:Connect(function(dt)
        if x < DISPLACEMENT_X then
            -- Parabolic motion
            x += dt / (JUMP_LENGTH / DISPLACEMENT_X)
            local y = (-math.pow(x-DISPLACEMENT_X/2, 2) + math.pow(DISPLACEMENT_X/2, 2)) / (DISPLACEMENT_X / 4) * (jumpHeight / DISPLACEMENT_X)

            fish.Position = UDim2.fromScale(origin.X + jumpDir * x, origin.Y - y)
            fish.Rotation = x * 60 * jumpDir

        else
            destroyFish(inputId)
        end

    end)

    -- Only four can be visible at the same time
    task.wait(JUMP_LENGTH / 4 + 0.5)

end


function play()
    playing = true
    fishCollected = 0

    gameScreen.Score.TextLabel.Text = "Score: " .. fishCollected

    -- Countdown
    local timer = gameScreen.Countdown
    timer.Size = UDim2.fromScale(1, 0)

    startScreen.Visible = false
    gameScreen.Visible = true


    -- Starting countdown
    for i = 3, 1, -1 do
        timer.Text = i

        local open = services.TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(1, 0.153)})
        open:Play()
        open.Completed:Wait()

        local close = services.TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(1, i == 1 and 0.07 or 0)})
        close:Play()
        close.Completed:Wait()

    end


    -- Non click input
    for inputId, keycodes in ipairs(KEYBINDS) do
        services.ContextActionService:BindAction("MinigameInput" .. inputId, function(_, state)
            if state == Enum.UserInputState.Begin then
                if jumpingFish[inputId] then
                    collectFish(inputId)
                end
            end
        end, false, table.unpack(keycodes))
    end


    -- Game timer
    task.spawn(function()
        timeRemainingInGame = GAME_LENGTH

        while timeRemainingInGame >= 0 do
            timer.Text = string.format("Collect the fish (%s)", timeRemainingInGame)
            timeRemainingInGame -= 1

            if timeRemainingInGame ~= 0 then
                task.wait(1)
            end

        end

        playing = false

        -- Stop taking input
        for inputId in ipairs(KEYBINDS) do
            services.ContextActionService:UnbindAction("MinigameInput" .. inputId)
        end

        -- Let all the fish die down
        for inputId in pairs(jumpingFish) do
            destroyFish(inputId)
        end

        edit()

    end)

    -- Fish spawning
    for i = 1, #KEYBINDS do
        spawnFish(i)
    end

end

function edit()
    transitionFrames(gameScreen, editingscreen, -1, true)
    task.wait(0.8)

    local editingAccuracyTotal = 0
    for i = 1, 3 do
        local tween

        -- Previews
        local previews = editingscreen.Preview
        if i == 1 then
            local preview = previews[i]

            preview.Position = UDim2.fromScale(0.5, 0.5)
            preview.Visible = true
        else
            transitionFrames(previews[i - 1], previews[i])
        end


        local meterBar = editingscreen.CutMeter.Bar
        meterBar.Position = UDim2.fromScale(0 + meterBar.Size.X.Scale, 0.5)

        tween = services.TweenService:Create(editingscreen.CutMeter.Bar, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true), {Position = UDim2.fromScale(1 - meterBar.Size.X.Scale, 0.5)})
        tween:Play()

        editingscreen.Cut.MouseButton1Down:Wait()
        tween:Cancel()

        -- local score =
        local editingAccuracy = (1 - math.abs(meterBar.Position.X.Scale - 0.5)) * 100
        editingAccuracyTotal += editingAccuracy

        local scoreLbl = editingscreen.Score
        scoreLbl.Text = string.format("%.1f%%", editingAccuracy)

        scoreLbl.Size = UDim2.fromScale(0, 0)

        tween = services.TweenService:Create(scoreLbl, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true), {Size = UDim2.fromScale(0.8, 0.8)})
        tween:Play()
        scoreLbl.Visible = true

        tween.Completed:Wait()
        scoreLbl.Visible = false

        -- Cut track
        local track = editingscreen.Clips[i]

        local editedTracks = editingscreen.EditedTracks
        local editecTrack = editedTracks[i]


        local initSize = track.AbsoluteSize / editedTracks.AbsoluteSize
        local initPosition = (track.AbsolutePosition - editedTracks.AbsolutePosition) / editedTracks.AbsoluteSize

        track = track:Clone()
        track.Size = UDim2.fromScale(initSize.X, initSize.Y)
        track.Position = UDim2.fromScale(initPosition.X, initPosition.Y)
        track.Visible = true
        track.Parent = editedTracks.Ignore

        tween = services.TweenService:Create(track, TweenInfo.new(0.5), {Size = editecTrack.Size, Position = editecTrack.Position})
        tween.Completed:Connect(function()
            track.Shot.ImageColor3 = Color3.fromRGB(84, 255, 11)
        end)

        tween:Play()

    end

    task.wait(0.5)

    results(editingAccuracyTotal / 3)

end

function results(editingAccuracy)
    transitionFrames(editingscreen, resultsScreen, -1, true)
    editingscreen.EditedTracks.Ignore:ClearAllChildren()

    -- Numbers
    local scoreLbl = resultsScreen.Score
    scoreLbl.TextLabel.Text = "Score: " .. fishCollected

    local rewardLbl = resultsScreen.Reward
    local gemsEarned = if fishCollected >= 40 then 3 else (if fishCollected >= 25 then 2 else (if fishCollected >= 10 then 1 else 0))
    rewardLbl.TextLabel.Text = "Gems Won: " .. gemsEarned


    local subs = editingAccuracy * 100
    local count1 = tweenNumber(scoreLbl.Bonus.TextLabel, subs, function(x)
        return string.format("+%s Subs", x)
    end)

    local count2 = tweenNumber(rewardLbl.Bonus.TextLabel, math.floor(subs * rand:NextInteger(2, 2.5)), function(x)
        return string.format("+%s Likes", x)
    end)

    -- Highscore
    local highscoreLbl = scoreLbl.NewHighscore
    if fishCollected > highscore then
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
    resultsScreen.Upload.MouseButton1Down:Connect(function()
        active = false

        count1:Cancel()
        count2:Cancel()

        remotes.YoutubeMinigameFinished:FireServer(currentComputer, fishCollected)

        for _, screen in ipairs(screens) do
            local frame = screen:WaitForChild("Upload")

            frame.Enabled = true

            local progressBar = frame.Progress.Bar
            progressBar.Size = UDim2.fromScale(0, 1)
            progressBar:TweenSize(UDim2.fromScale(1, 1), Enum.EasingDirection.In, Enum.EasingStyle.Linear, UPLOAD_COOLDOWN, false, function()
                toggleProximityPrompts(true)
                frame.Enabled = false
            end)

        end

        close()

    end)

end

function open()
    -- Load highscore
    highscore = remotes.GetStat:InvokeServer("Youtube Minigame Score")
    local highscoreLbl = startScreen.Information.Highscore
    highscoreLbl.Text = "Your highscore: " .. highscore

    toggleOtherUI(false)
    psuedoFrame.Visible = true
    startScreen.Visible = true
    gameScreen.Visible = false

end

function close()
    currentComputer = nil

    -- Reset character
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
    psuedoFrame.Visible = false
    gameScreen.Visible = false
    startScreen.Visible = false
    editingscreen.Visible = false
    resultsScreen.Visible = false

end

local function loadComputer(computer)
    currentComputer = computer.Name

    local screen = computer:WaitForChild("Screen")
    table.insert(screens, screen)

    -- Created on the client so no one else can use it
    local seat = computer:WaitForChild("Seat")

    local prompt = Instance.new("ProximityPrompt")
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 7
    prompt.RequiresLineOfSight = false
    prompt.ActionText = "Upload video"
    prompt.Parent = seat
    prompt.Enabled = if #proximityPrompts == 0 then true else proximityPrompts[1].Enabled
    table.insert(proximityPrompts, prompt)

    prompt.Triggered:Connect(function()
        toggleProximityPrompts(false)

        character = player.character
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

            local scale = 1 + (1 - psuedoFrame.Size.Y.Scale)
            local screenSize = screen.Size * scale
            local deph = (screenSize.Y / 2) / math.tan(math.rad(camera.FieldOfView / 2)) + (screenSize.Z / 2)

            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            local transition = services.TweenService:Create(camera, tweenInfo, {CFrame = screen.CFrame * CFrame.fromEulerAnglesYXZ(0, math.pi, 0) * CFrame.new(0, 0, deph)})
            transition.Completed:Connect(function()
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
    close()
end)

for i, fish in ipairs(fishInstances) do
    fish.MouseButton1Down:Connect(function()
        if playing then
            collectFish(i)
        end
    end)

end

-- open()
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


return minigame

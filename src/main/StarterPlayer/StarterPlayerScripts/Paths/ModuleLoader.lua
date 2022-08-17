local Players = game:GetService("Players")
local Loader = {}



local LOADING_SCREEN_LENGTH = 8
local FULL = 1.1 -- Gradient has 0.1 ease thing


--- Main Variables ---
local Paths = require(script.Parent)
local Services = Paths.Services

local Animations = require(script.Parent.UI.Animations)


local Tween
local LoadingScreen = game.Players.LocalPlayer.PlayerGui.LoadingScreen
local LogoGradient = LoadingScreen.Logo.Colored.UIGradient

local SkipBtn = LoadingScreen.Skip


local Playing = true
local ToLoad = {}

local function Close()
    repeat task.wait() until SkipBtn.Visible -- Character has loaded flag

    Playing = false
    Animations.BlinkTransition(function()
        Paths.Player.Character.PrimaryPart.Anchored = false
        LoadingScreen:Destroy()
    end)
end

-- Main Functions --
function Loader.Register(Name, Module)
    table.insert(ToLoad, {Name, Module})
 end


function Loader.Load()
    local Count = #ToLoad
    local Loaded = 0

    -- Skipping
    task.spawn(function()
        if not Paths.Player.Character then
            Paths.Player.CharacterAdded:Wait()
        end
        task.wait(3)
        SkipBtn.Visible = true

        SkipConn = SkipBtn.MouseButton1Down:Connect(function()
            SkipConn:Disconnect()
            SkipConn = nil

            if Playing then
                Close()
            end

        end)

    end)

    for i, Loading in ipairs(ToLoad) do
        Paths.Modules[Loading[1]] = require(Loading[2])
        Loaded += 1

        if LoadingScreen.Enabled then
            if Tween then Tween:Cancel() end

            local Progress = (Loaded/Count) * FULL - 0.1
            local Speed = ((Progress - LogoGradient.Offset.X) / FULL) * ((LOADING_SCREEN_LENGTH/Count)/(1/Count)) -- Contant speed
            Tween = Services.TweenService:Create(LogoGradient, TweenInfo.new(Speed, Enum.EasingStyle.Linear), {Offset = Vector2.new(Progress, 0)})

            Tween.Completed:Connect(function()
                if i == Count and Playing then
                    Playing = false
                    task.wait(0.5)
                    Close()
                end
                Tween = nil
            end)

            Tween:Play()
        end


    end

    -- Loader is taking too long
    task.delay(10, function()
        if Loaded < Count then
            if Tween then Tween:Cancel() end
            Close()
        end

    end)

end


return Loader
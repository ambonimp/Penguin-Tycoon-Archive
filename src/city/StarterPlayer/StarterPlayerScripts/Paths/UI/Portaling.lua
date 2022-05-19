local Portals = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local PlaceIds =  require(Services.RStorage.Modules.PlaceIds)


-- Variables --
local Frame = UI.SpecialEffects.PortalBloom

local Player = game:GetService("Players").LocalPlayer
local PlayerControlls = require(Player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()

local Camera = workspace.CurrentCamera



local function bloom(Length, Onhalf, OnEnd)
    local Info = TweenInfo.new(Length / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local In = Services.TweenService:Create(Frame, Info, {BackgroundTransparency = 0})
    In.Completed:Connect(function()
        local proceed = true
        if Onhalf then
            proceed = Onhalf()
        end

        if proceed then
            local Out = Services.TweenService:Create(Frame, Info, {BackgroundTransparency = 0})
            Out:Play()
        end

    end)

    In:Play()
end

local function WalkToPortal(Goal, Mid)
    local Character = Player.Character
	local Hum = Character.Humanoid
	local Hrp = Character.HumanoidRootPart

    local Length = (Hrp.Position - Goal).Magnitude / Hum.WalkSpeed * 2 -- Fraction of length it'll take to reach portal

    PlayerControlls:Disable()
    Hum:MoveTo(Goal)


    task.wait(0.25)
    Camera.CameraType = Enum.CameraType.Scriptable

    Services.TweenService:Create(Camera, TweenInfo.new(Length), {CFrame = CFrame.new(Goal) * Hrp.CFrame.Rotation}):Play()
    bloom(Length, function()
        Hum:MoveTo(Hrp.Position) -- End dthe walk to

        PlayerControlls:Disable()
        Modules.Camera:ResetToCharacter()

        return Mid()
    end
    )


end

function Portals:ToPlace(Portal, PlaceId)
    WalkToPortal(Portal.PrimaryPart.Position, function()
        local s, m

        repeat
            s, m = Remotes.Teleport:InvokeServer(PlaceId)
            if not s then
                warn(m)
            end
            task.wait(2)
        until s

    end)

end

for _, Portal in ipairs(workspace.MinigamePortals:GetChildren()) do
    local Sensor = Portal.Sensor

    local Con
    Con = Sensor.Touched:Connect(function(hit)
        if hit.Parent == Player.Character then
            Con:Disconnect()
            Portals:ToPlace(Portal, PlaceIds[Portal.Name])
        end
    end)

end

return Portals


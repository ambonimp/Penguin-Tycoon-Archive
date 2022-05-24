local Map = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local UI = Paths.UI

-- Variables --
local TRANSITION_LENGTH = 1
local HOVER_SCALE = 1.25


local TeleportLocations = workspace.MapTeleportPoints

local Frame = UI.Center.Map
local Locations = Frame.Locations
local Tooltip = Frame.Tooltip

local Bloom = UI.SpecialEffects.Bloom

local Camera = workspace.CurrentCamera

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Hovering -- Location that's being looked at; Debounce thingy




local function OpenMap()
	Paths.UI.Left.Visible = false
	Paths.UI.Bottom.Visible = false
	Paths.UI.BLCorner.Visible = false

end

local function CloseMap()
	Paths.UI.Left.Visible = true
	Paths.UI.Bottom.Visible = true
	Paths.UI.BLCorner.Visible = true
end

local function Transition(OnHalfPoint)
    local Info = TweenInfo.new(TRANSITION_LENGTH / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    local In = Services.TweenService:Create(Bloom, Info, {BackgroundTransparency = 0})
    In.Completed:Connect(function()
        OnHalfPoint()

        local Out = Services.TweenService:Create(Bloom, Info, {BackgroundTransparency = 1})
        Out:Play()

    end)

    In:Play()

end

function OnLocationHover(Location)
    local LastHovered = Hovering
    Hovering = Location

    -- Sometimes you enter something without ever leaving it
    if LastHovered then
        OnLocationHoverEnded(LastHovered)
    end

    Location.ZIndex = 2 -- Brings icon forward if it overlaps with another once scaled
    Location.UIScale.Scale = HOVER_SCALE

    Tooltip.Text = Location.Name
    Tooltip.Visible = true
    Tooltip.Position = Location.Position + UDim2.fromScale(0, Location.Size.Y.Scale / 2 * HOVER_SCALE + 0.005)


end

function OnLocationHoverEnded(Location)
    if Hovering == Location then
        Hovering = nil
        Tooltip.Visible = false

        -- Sometimes hover don't register when you're hovering on two things
        -- Gets around that by checking if something was ignored
        for _, PossibleLocation in ipairs(Player.PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)) do
            if PossibleLocation.Parent == Locations then
                OnLocationHover(PossibleLocation)
            end
        end

    end

    Location.ZIndex = 1
    Location.UIScale.Scale = 1
end





-- Toggle other parts of the Interface
UI.Left.Buttons.Map.MouseButton1Down:Connect(OpenMap)
Frame.Exit.MouseButton1Down:Connect(CloseMap)

for _, Location in ipairs(Locations:GetChildren()) do
    if not TeleportLocations:FindFirstChild(Location.Name) then
        warn("O SHOO", Location.Name)
    end

    local Scale = Instance.new("UIScale")
    Scale.Parent = Location

    Location.MouseButton1Down:Connect(function()
        Transition(function()
            local Character = Player.Character
            if Character then
                local NewCFrame = TeleportLocations[Location.Name].CFrame + Vector3.new(0, 5, 0)
                Character:SetPrimaryPartCFrame(NewCFrame)
                -- Make camera look at destination
                Camera.CFrame = CFrame.new(Camera.CFrame.Position) * NewCFrame.Rotation -- CFrame.fromEulerAnglesYXZ(math.rad(12), 0, 0)

            end

            Modules.Buttons:UIOff(Frame, true)
            CloseMap()
        end)

    end)

    Location.MouseEnter:Connect(function()
        OnLocationHover(Location)
    end)

    Location.MouseLeave:Connect(function()
        OnLocationHoverEnded(Location)
    end)

end

return Map


local Map = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local UI = Paths.UI

-- Variables --
local HOVER_SCALE = 1.25


local TeleportLocations = workspace.MapTeleportPoints

local MainButton =UI.Left.Buttons.Map

local Frame = UI.Center.Map
local Locations = Frame.Locations
local Tooltip = Frame.Tooltip

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Hovering -- Location that's being looked at; Debounce thingy




local function OpenMap()
	Paths.UI.Left.Visible = false
	Paths.UI.Right.Visible = false
	Paths.UI.Bottom.Visible = false
	Paths.UI.BLCorner.Visible = false
    Paths.UI.Top.Visible = false
end

local function CloseMap()
	Paths.UI.Left.Visible = true
	Paths.UI.Right.Visible = true
	Paths.UI.Bottom.Visible = true
	Paths.UI.BLCorner.Visible = true
    Paths.UI.Top.Visible = true
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


function ownsGamepass()
    return true--Modules.Gamepasses.Owned[47438595]
end

-- Toggle other parts of the Interface
MainButton.MouseButton1Down:Connect(OpenMap)
Frame.Exit.MouseButton1Down:Connect(CloseMap)

for _, Location in ipairs(Locations:GetChildren()) do
    if not TeleportLocations:FindFirstChild(Location.Name) then
        warn("O SHOO", Location.Name)
    end

    local Scale = Instance.new("UIScale")
    Scale.Parent = Location

    Location.MouseButton1Down:Connect(function()
        if ownsGamepass() then
            Modules.UIAnimations.BlinkTransition(function()
                local Character = Player.Character
                if Character then
                    Character:SetPrimaryPartCFrame(TeleportLocations[Location.Name].CFrame + Vector3.new(0, 5, 0))
                end

                Modules.Buttons:UIOff(Frame, true)
                CloseMap()
            end, true)
        else
            Services.MPService:PromptGamePassPurchase(Paths.Player, 47438595)
        end
    end)

    Location.MouseEnter:Connect(function()
        OnLocationHover(Location)
    end)

    Location.MouseLeave:Connect(function()
        OnLocationHoverEnded(Location)
    end)


    local MapBoard = workspace.World:FindFirstChild("Map Board")
    if MapBoard then
		local ProximityPrompt = Instance.new("ProximityPrompt")
		ProximityPrompt.HoldDuration = 0.25
		ProximityPrompt.MaxActivationDistance = 17
		ProximityPrompt.RequiresLineOfSight = false
		ProximityPrompt.ActionText = "Open Map"
		ProximityPrompt.Parent = MapBoard.PrimaryPart

		ProximityPrompt.Triggered:Connect(function(player)
            if Frame.Visible then
                Modules.Buttons:UIOff(Frame, true)
                CloseMap()
                return
            end
		    -- Closes any previously opened frames and opens map frame
		    Modules.Buttons:OnMainButtonClicked(MainButton)
            OpenMap()

		end)

    end

end

return Map


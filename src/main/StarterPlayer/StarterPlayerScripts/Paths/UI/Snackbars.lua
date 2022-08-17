local Snackbars = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local UI = Paths.UI

local Dependency = Services.RStorage.ClientDependency.Snackbars


local HEIGHT = Dependency:GetChildren()[1].Size.Y.Scale
local BUMP_LENGTH = 0.5
local LIFETIME = 5
local PADDING = 0.025



local Frame = UI.Main.Snackbars



local function Move(Item, Position)
    Item:TweenPosition(Position, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, BUMP_LENGTH, true)
end

local function write(Template, Message)
    -- Bump Others
    for _, Other in ipairs(Frame:GetChildren()) do
        local order = Other.LayoutOrder + 1

        Move(Other, UDim2.fromScale(0.5, 1 - order * (HEIGHT + PADDING)))
        Other.LayoutOrder = order
    end

    -- Add new
    local Snackbar = Template:Clone()
    Snackbar.Text = Message

    Snackbar.Size = UDim2.fromScale(0, Snackbar.Size.Y.Scale)
    Snackbar.Position = UDim2.fromScale(0.5, 1)
    Snackbar.LayoutOrder = 0
    Snackbar.Visible = true
    Snackbar.Parent = Frame

    Snackbar:TweenSize(UDim2.fromScale(1, HEIGHT), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.2)

    local TweenOut = Services.TweenService:Create(Snackbar, TweenInfo.new(LIFETIME * 0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, LIFETIME * 0.75), {TextTransparency = 1, TextStrokeTransparency = 1})
    TweenOut.Completed:Connect(function()
        Snackbar:Destroy()
    end)
    TweenOut:Play()

end


function Snackbars.Error(Message)
    write(Dependency.Error, Message)
end

function Snackbars.Info(Message)
    write(Dependency.Info, Message)
end

function Snackbars.Reward(Message)
    write(Dependency.Reward, Message)
end

-- Testing
--[[ game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T then
        Snackbars.Error("Whoa")
    end
end)
 *]]

return Snackbars
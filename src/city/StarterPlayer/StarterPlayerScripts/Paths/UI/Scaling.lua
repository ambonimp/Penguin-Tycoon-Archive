local Players = game:GetService("Players")
local Scaling = {}

local Paths = require(script.Parent.Parent)
local UI = Paths.UI.Main

local BASE_RESOLTION = Vector2.new(1366, 768)

local Camera = workspace.CurrentCamera

local Sizes = {}
local Scale

local function ScaleElement(Element)
    if Element:IsA("UIStroke") then
        local Thickness = Sizes[Element]
        if not Thickness then
            Thickness = Element.Thickness
            Sizes[Element] = Thickness
        end

        Element.Thickness = Thickness * Scale
    end

end

local function OnScale()
    Scale = (Camera.ViewportSize / BASE_RESOLTION)
    Scale = if math.abs(1 - Scale.X) > math.abs(1 - Scale.Y) then Scale.X else Scale.Y

    for _, element in ipairs(UI:GetDescendants()) do
        ScaleElement(element)
    end

end

OnScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(OnScale)

for _, Element in ipairs(UI:GetDescendants()) do
    ScaleElement(Element)
end

UI.DescendantAdded:Connect(ScaleElement)
UI.DescendantRemoving:Connect(function(Element)
    if Element:IsA("UIStroke") then
        Sizes[Element] = nil
    end
end)

return Scaling
local TycoonTeleport = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


local Frame = UI.Center.TycoonTeleport
local List = Frame.List

local UsedLbls = {}
local UnusedLbls = {}

local function Open()
    Modules.Buttons:UIOn()
end

local function LoadTycoon(Player)
    local Lbl = UnusedLbls[1]
    table.remove(UnusedLbls, 1)

    local Index = #UsedLbls + 1
    UsedLbls[Index] = Lbl

    local Mine = Player == Paths.Player

    local Name = Player.Name
    Lbl.Name = Name
    Lbl.TycoonName.Text = Mine and "Mine" or Name
    Lbl.LayoutOrder = Mine and 0 or Index
    Lbl.Visible = true

end

for i = 1, 6 do
    local Lbl = Services.RStorage.ClientDependency.Teleporting.TycoonTemplate:Clone()
    Lbl.Visible = false
    Lbl.Parent = List
    table.insert(UnusedLbls, Lbl)

    Lbl.Visit.MouseButton1Down:Connect(function()
        Modules.Buttons:UIOff(Frame, true)
        Modules.UIAnimations.BlinkTransition(function()
            Remotes.TeleportInternal:InvokeServer(Lbl.Name)
        end, true)
    end)

end

for _, Player in ipairs(game.Players:GetPlayers()) do
    LoadTycoon(Player)
end

game.Players.PlayerAdded:Connect(LoadTycoon)
game.Players.PlayerRemoving:Connect(function(Player)
    local Lbl = List:FindFirstChild(Player.Name)
    Lbl.Visible = false

    table.remove(UsedLbls, table.find(UnusedLbls, Lbl))
    table.insert(UnusedLbls, Lbl)
end)


local Prompt = Instance.new("ProximityPrompt")
Prompt.HoldDuration = 0.25
Prompt.MaxActivationDistance = 10
Prompt.RequiresLineOfSight = false
Prompt.ActionText = "Visit others tycoons"
Prompt.Parent = Paths.Tycoon:WaitForChild("Teleport")

Prompt.Triggered:Connect(function()
    if not Frame.Visible then
        Modules.Buttons:UIOn(Frame, true)
    end
end)

Frame.Exit.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOff(Frame, true)
end)

return TycoonTeleport

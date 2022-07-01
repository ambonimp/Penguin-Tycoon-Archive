local Workspace = game:GetService("Workspace")
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
    if Player ~= Paths.Player then
        local Lbl = UnusedLbls[1]
        table.remove(UnusedLbls, 1)

        local Index = #UsedLbls + 1
        UsedLbls[Index] = Lbl

        local Name = Player.Name
        Lbl.Name = Name
        Lbl.TycoonName.Text = Name
        Lbl.LayoutOrder = Index
        Lbl.Visible = true

    end
end

for i = 1, 5 do
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


local VisitPrompt = Instance.new("ProximityPrompt")
VisitPrompt.HoldDuration = 0.25
VisitPrompt.MaxActivationDistance = 10
VisitPrompt.RequiresLineOfSight = false
VisitPrompt.ActionText = "Visit others"
VisitPrompt.Parent = Paths.Tycoon:WaitForChild("Teleport"):WaitForChild("Prompt")

VisitPrompt.Triggered:Connect(function()
    if not Frame.Visible then
        Modules.Buttons:UIOn(Frame, true)
    end
end)

Frame.Exit.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOff(Frame, true)
end)

for _, Tycoon in ipairs(Workspace.Tycoons:GetChildren()) do
    if Tycoon ~= Paths.Tycoon then
        task.spawn(function()
            local ReturnPrompt = Instance.new("ProximityPrompt")
            ReturnPrompt.HoldDuration = 0.25
            ReturnPrompt.MaxActivationDistance = 10
            ReturnPrompt.RequiresLineOfSight = false
            ReturnPrompt.ActionText = "Return home"
            ReturnPrompt.Parent = Tycoon.Teleport:WaitForChild("Prompt", math.huge)

            ReturnPrompt.Triggered:Connect(function()
                Modules.UIAnimations.BlinkTransition(function()
                    Remotes.TeleportInternal:InvokeServer(Paths.Player.Name)
                end, true)
            end)

        end)

    end

end

return TycoonTeleport

local Setup = {}
local Paths = require(script.Parent)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
local PromptService = game:GetService("ProximityPromptService")
local NotifExample = Paths.UI.Main.Notifications2.Example

function Setup:Notification(text,color,time)
    if Paths.Audio.Notif.IsPlaying == false then
        Paths.Audio.Notif:Play()
    end
    local notif = NotifExample:Clone()
    notif.Text = text
    notif.BackgroundColor3 = color or Color3.new(0.776470, 0.850980, 0.501960)
    notif.UIStroke.Color = color or Color3.new(0.776470, 0.850980, 0.501960)
    notif.Parent = Paths.UI.Main.Notifications2
    notif.Visible = true
    task.wait(time or 3)
    notif:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,.25)
    task.wait(.25)
    notif:Destroy()
end

Paths.Remotes.ClientNotif.OnClientEvent:Connect(function(text,color,time)
    Setup:Notification(text,color,time)
end)

local function onPromptTriggered(promptObject, player)
    if player == game.Players.LocalPlayer then
        if promptObject.ActionText == "Open Fish Index" then
            Paths.Modules.Buttons:UIOn(Paths.UI.Center.Index,true)
        elseif promptObject.ActionText == "Get A Poofie!" then
            Paths.Modules.Buttons:UIOn(Paths.UI.Center.UnlockedEggs,true)
        end
    end
end

PromptService.PromptTriggered:Connect(onPromptTriggered)


return Setup
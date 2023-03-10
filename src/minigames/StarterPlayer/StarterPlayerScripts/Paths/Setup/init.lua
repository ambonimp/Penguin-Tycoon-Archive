local Setup = {}
local Paths = require(script.Parent)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

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
    game:GetService("Debris"):AddItem(notif,time or 3)
end

Paths.Remotes.ClientNotif.OnClientEvent:Connect(function(text,color,time)
    Setup:Notification(text,color,time)
end)

return Setup
local Setup = {}

local Paths = require(script.Parent)
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local Services = Paths.Services
local UI = Paths.UI

local NotifExample = Paths.UI.Main.Notifications.Example

function Setup:Notification(text,color,time)
    if Paths.Audio.Notif.IsPlaying == false then
        Paths.Audio.Notif:Play()
    end
    local notif = NotifExample:Clone()
    notif.Text = text
    notif.BackgroundColor3 = color or Color3.new(0.776470, 0.850980, 0.501960)
    notif.Parent = UI.Main.Notifications
    notif.Visible = true
    game:GetService("Debris"):AddItem(notif,time or 3)
end

Paths.Remotes.ClientNotif.OnClientEvent:Connect(function(text,color,time)
    Setup:Notification(text,color,time)
end)


Paths.Services.ProximityPromptService.PromptTriggered:Connect(function(Prompt, Player)
    if Player == Paths.Player then
        if Prompt.ActionText == "Sailboat" then
            Paths.Modules.Buttons:UIOff(UI.Center.PlaneUnlock)
			Paths.Modules.Buttons:UIOn(UI.Center.SailboatUnlock,true)

		elseif Prompt.ActionText == "Socials" then
			Paths.Modules.Buttons:UIOn(UI.Center.Codes,true)

        elseif Prompt.ActionText == "Spin" then
            Modules.Achievements.ButtonClicked(UI.Center.Achievements.Buttons.Spin,UI.Center.Achievements)
			Modules.Buttons:UIOn(UI.Center.Achievements,true)

		elseif Prompt.ActionText == "Money" then
			Modules.Store.ButtonClicked(UI.Center.Store.Buttons.Money,UI.Center.Store)
			Modules.Buttons:UIOn(UI.Center.Store,true)

		elseif Prompt.ActionText == "Gems" then
			Modules.Store.ButtonClicked(UI.Center.Store.Buttons.Gems,UI.Center.Store)
			Modules.Buttons:UIOn(UI.Center.Store,true)

        elseif Prompt.ActionText == "Plane" then
            Modules.Buttons:UIOff(UI.Center.BoatUnlock)
            Modules.Buttons:UIOn(UI.Center.PlaneUnlock,true)

		elseif Prompt.ObjectText == "Poofies Egg" then
            Modules.Buttons:UIOn(UI.Center.UnlockedEggs,true)
            --Modules.Pets.LoadEgg(Prompt:GetAttribute("Egg"),Prompt)

        elseif Prompt.ObjectText == "Gamepass" then
            local id = Prompt:GetAttribute("Gamepass")
            Paths.Services.MPService:PromptGamePassPurchase(Paths.Player, id)

        elseif Prompt.ActionText == "Penguin City" then
            Modules.Teleporting:OpenConfirmation()
            Modules.Buttons:UIOn(UI.Center.TeleportConfirmation,true)

        elseif Prompt.ActionText == "Blast Off" then
            Modules.Buttons:UIOn(UI.Center.WorldTeleport, true)
        end

    end

end)

return Setup
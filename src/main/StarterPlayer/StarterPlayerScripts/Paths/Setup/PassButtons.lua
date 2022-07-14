local Buttons = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI

local function LoadButton(Button)
    local Db

    task.spawn(function()
        local Hitbox = Button:WaitForChild("Hitbox", math.huge)

        Hitbox.Touched:Connect(function(Hit)
            if not Db and Hit.Parent == Paths.Player.Character then
                Db = true

                if Button.Name == "Gamepass" then
                    Paths.Services.MPService:PromptGamePassPurchase(Paths.Player, Button:GetAttribute("Id"))

                elseif Button.Name == "Money" then
                    Modules.Store.ButtonClicked(UI.Center.Store.Buttons.Money,UI.Center.Store)
                    Modules.Buttons:UIOn(UI.Center.Store, true)

                elseif Button.Name == "Gems" then
                    Modules.Store.ButtonClicked(UI.Center.Store.Buttons.Gems,UI.Center.Store)
                    Modules.Buttons:UIOn(UI.Center.Store, true)

                elseif Button.Name == "Socials" then
			        Paths.Modules.Buttons:UIOn(UI.Center.Codes, true)

                elseif Button.Name == "TycoonTeleport" then
                    if Button:IsDescendantOf(Paths.Tycoon) then
                        Modules.Buttons:UIOn(UI.Center.TycoonTeleport, true)
                    else
                        Modules.UIAnimations.BlinkTransition(function()
                            Remotes.TeleportInternal:InvokeServer(Paths.Player.Name)
                        end, true)
                    end
                end

                local Conn
                Conn = Hitbox.TouchEnded:Connect(function(Hit2)
                    if Hit2 == Hit then
                        Conn:Disconnect()
                        Db = false
                    end
                end)

            end

        end)

    end)

end

for _, Button in ipairs(Services.CollectionService:GetTagged("PassButton")) do
    LoadButton(Button)
end
Services.CollectionService:GetInstanceAddedSignal("PassButton"):Connect(LoadButton)


return Buttons
local PartyInvite = {}

local Paths = require(script.Parent.Parent.Parent)
local Services = Paths.Services
local Remotes = Paths.Remotes
local Modules = Paths.Modules
local UI = Paths.UI


local INVITE_DURATION = Modules.PartyUtil.INVITE_DURATION


local Settings =  Paths.UI.Center.Settings.Holder

local Frame = UI.Center.PartyInvite
local YesBtn = Frame.Actions.Yes
local NoBtn = Frame.Actions.No
local Timer = Frame.Timer.Bar



local Queue = {}
local CurrentInvite
local function openInvite(Sender)
    if CurrentInvite then
        if not table.find(Queue, Sender) then
            table.insert(Queue, Sender)
        end
    else
        local Maid = Modules.Maid.new()
        Maid:GiveTask(function()
            Modules.Buttons:UIOff(Frame)
            CurrentInvite = nil

            if Settings["Party Invites"].Toggle.IsToggled.Value then
                local NextInvite = Queue[1]
                if NextInvite then
                    table.remove(Queue, 1)
                    openInvite(NextInvite)
                end
            else
                Queue = {}
            end

        end)

        -- Check if the invite is still valid
        if  Modules.PartyUtil.IsInviteValid(Sender, Paths.Player) then
            CurrentInvite = Sender

            -- Get input
            Maid:GiveTask(YesBtn.MouseButton1Down:Connect(function()
                Remotes.PartyInviteAccepted:FireServer(Sender)
                Queue = {}
                Maid:Destroy()
            end))

            Maid:GiveTask(NoBtn.MouseButton1Down:Connect(function()
                Maid:Destroy()
            end))


            -- Open
            Modules.Buttons:UIOn(Frame)

            -- Countdown till close
            local Et = 0
            Timer.Size = UDim2.fromScale(1, 1)
            while CurrentInvite == Sender and Et < INVITE_DURATION do
                task.wait(1)
                Et += 1

                Timer:TweenSize(UDim2.fromScale(1 - Et / INVITE_DURATION, 1), Enum.EasingDirection.InOut, 1, true)

            end

            if CurrentInvite == Sender then
                Maid:Destroy()
            end


        else
            Maid:Destroy()
            return
        end

    end

end

-- Prompt party invites
Remotes.PartyInvite.OnClientEvent:Connect(function(Sender)
    openInvite(Sender)
end)

return PartyInvite
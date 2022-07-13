local Rebirths = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes

local UPGRADE = "RebirthMachine"

local Frame = Paths.UI.Center.Rebirth


Rebirths.Rebirthed = Modules.Signal.new()

local function CreatePrompt(Parent, ActionText, ObjectText)
    local Prompt = Instance.new("ProximityPrompt")
    Prompt.HoldDuration = 0.25
    Prompt.MaxActivationDistance = 15
    Prompt.RequiresLineOfSight = false
    Prompt.ObjectText = ObjectText or ""
    Prompt.ActionText = ActionText
    Prompt.Parent = Parent

    return Prompt
end

local function LoadMachine()
    local Prompt = CreatePrompt(Paths.Tycoon.Tycoon:WaitForChild(UPGRADE):WaitForChild("PromptPart"), "Rebirth")
    Prompt.Triggered:Connect(function()
        Frame.Description.Text = string.format('By rebirthing, you reset your entire tycoon and gain a <font color="#ffe600">%sx</font> money boost!.', 1 + (Remotes.GetStat:InvokeServer("Rebirths") + 1) * 0.002)
        Modules.Buttons:UIOn(Frame, true)
    end)
end

-- Interaction
local function Init()
    if Remotes.GetStat:InvokeServer("Tycoon")[UPGRADE] then
        LoadMachine()
    else
        local Conn
        Conn = Remotes.ButtonPurchased.OnClientEvent:Connect(function(_, Button)
            if Button == UPGRADE then
                Conn:Disconnect()
                LoadMachine()
            end
        end)
    end
end

local function Rebirth()
    Rebirths.Rebirthed:Fire()

    -- Reset
    Modules.Buttons:UIOff(Frame, true)
    Init()

end

Init()


-- UI
Frame.Exit.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOff(Frame, true)
end)

Frame.Purchase.Money.MouseButton1Down:Connect(function()
    if Remotes.GetStat:InvokeServer("Money") >= 10^10 then
        if Remotes.Rebirth:InvokeServer("Money") then
            Rebirth()
        end
    else
        -- TODO: Prompt purchase
    end

end)

Frame.Purchase.Gems.MouseButton1Down:Connect(function()
    if Remotes.GetStat:InvokeServer("Gems") >= 10^4 then
        if Remotes.Rebirth:InvokeServer("Gems") then
            Rebirth()
        end
    else
        -- TODO: Prompt purchase
    end

end)


return Rebirths
local Rebirths = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes

local UPGRADE = "RebirthMachine"

local Frame = Paths.UI.Center.Rebirth


local priceGems = 10^4
local priceMoney

Rebirths.Rebirthed = Modules.Signal.new()

local function updateRebirths(Rebirths)
    priceMoney = 10 ^ 9 + (10 ^ 9) * 0.25 * Rebirths
    Frame.Description.Text = string.format('By rebirthing, you reset your entire tycoon and gain a <font color="#ffe600">%s%%</font> money boost!.', 1 + (Rebirths + 1) / 10)
    Frame.Purchase.Money.Amount.Text = Modules.Format:FormatAbbreviated(10 ^ 9 + (10 ^ 9) * 0.25 * Rebirths)
end

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

local function Rebirth(Count)
    if not Count then return end

    Rebirths.Rebirthed:Fire()
    updateRebirths(Count)

    -- SFX
    Modules.UIAnimations.Confetti()
    Paths.Audio.Celebration:Play()

    -- Reset
    Modules.Buttons:UIOff(Frame, true)
    Init()

end

-- Init
updateRebirths(Remotes.GetStat:InvokeServer("Rebirths"))
Init()

-- UI
Frame.Exit.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOff(Frame, true)
end)

Frame.Purchase.Money.MouseButton1Down:Connect(function()
    if Remotes.GetStat:InvokeServer("Money") >= priceMoney then
        Modules.UIAnimations.BlinkTransition(function()
            Rebirth(Remotes.Rebirth:InvokeServer("Money"))
        end)

    else
        local ProductRequired = Modules.GameFunctions:GetRequiredMoneyProduct(Paths.Player, priceMoney)
        Services.MPService:PromptProductPurchase(Paths.Player, ProductRequired)
    end

end)

Frame.Purchase.Gems.MouseButton1Down:Connect(function()
    if Remotes.GetStat:InvokeServer("Gems") >= priceGems then
        Modules.UIAnimations.BlinkTransition(function()
            Rebirth(Remotes.Rebirth:InvokeServer("Gems"))
        end)
    else
        local ProductRequired = Modules.GameFunctions:GetRequiredGemProduct(priceGems)
        Services.MPService:PromptProductPurchase(Paths.Player, ProductRequired)
    end
end)


return Rebirths
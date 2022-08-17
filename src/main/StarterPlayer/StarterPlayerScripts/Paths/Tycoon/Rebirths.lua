local Rebirths = {}

local Paths = require(script.Parent.Parent)
local Modules = Paths.Modules
local Services = Paths.Services
local Remotes = Paths.Remotes

local UPGRADE = "RebirthMachine"

local Frame = Paths.UI.Center.Rebirth
local Popup = Paths.UI.Top.Bottom.Popups.Rebirth

local priceGems
local priceMoney

Rebirths.Rebirthed = Modules.Signal.new()

local function updateRebirths(Rebirths)
    priceMoney = 10 ^ 9 + (10 ^ 9) * 0.25 * Rebirths
    priceGems = 1000 + (1000) * 0.25 * Rebirths
    Frame.Description.Text = string.format('By rebirthing, you reset your entire tycoon and gain a <font color="#ffe600">%s%%</font> money boost!.', 1 + (Rebirths + 1) / 10)
    Frame.Purchase.Money.Amount.Text = Modules.Format:FormatAbbreviated(priceMoney)
    Frame.Purchase.Gems.Amount.Text = Modules.Format:FormatAbbreviated(priceGems)
end

-- Interaction
local function Rebirth(Count)
    if not Count then return end

    Rebirths.Rebirthed:Fire()
    updateRebirths(Count)

    -- SFX
    Modules.UIAnimations.Confetti()
    Paths.Audio.Celebration:Play()

    -- Reset
    Modules.Buttons:UIOff(Frame, true)
end

-- UI
updateRebirths(Remotes.GetStat:InvokeServer("Rebirths"))
Services.ProximityPrompt.PromptTriggered:Connect(function(Prompt, Player)
    if Prompt.ActionText == "Rebirth" and Player == Paths.Player then
        Modules.Buttons:UIOn(Frame, true)
    end
end)

Frame.Exit.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOff(Frame, true)
end)

Frame.Purchase.Money.MouseButton1Down:Connect(function()
    if Remotes.GetStat:InvokeServer("Money") >= priceMoney then
        Modules.UIAnimations.BlinkTransition(function()
            local RootPart = Paths.Player.Character.PrimaryPart
            RootPart.Anchored = true
            Rebirth(Remotes.Rebirth:InvokeServer("Money"))
            RootPart.Anchored = false
        end)

    else
        local ProductRequired = Modules.GameFunctions:GetRequiredMoneyProduct(Paths.Player, priceMoney)
        Services.MPService:PromptProductPurchase(Paths.Player, ProductRequired)
    end

end)

Frame.Purchase.Gems.MouseButton1Down:Connect(function()
    if Remotes.GetStat:InvokeServer("Gems") >= priceGems then
        Modules.UIAnimations.BlinkTransition(function()
            local RootPart = Paths.Player.Character.PrimaryPart
            RootPart.Anchored = true
            Rebirth(Remotes.Rebirth:InvokeServer("Gems"))
            RootPart.Anchored = false
        end)
    else
        local ProductRequired = Modules.GameFunctions:GetRequiredGemProduct(priceGems)
        Services.MPService:PromptProductPurchase(Paths.Player, ProductRequired)
    end
end)

-- Rebirth popup
Remotes.RebirthReady.OnClientEvent:Connect(function()
    Popup.Size = UDim2.fromScale(0,0)
    Popup.Visible = true
    Popup:TweenSize(UDim2.fromScale(0.457, 1), Enum.EasingDirection.Out,Enum.EasingStyle.Quad, 0.25, true, function()
        task.wait(5)
        Popup.Visible = false
    end)

end)

return Rebirths
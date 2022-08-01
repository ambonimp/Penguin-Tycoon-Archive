local Playtime = {}
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI.Center.Achievements.Sections.Gifts
local JoinTime = Paths.Player:GetAttribute("JoinTime")
local claimed = 0
local RewardTimes = {
    [1] = 5*60,
    [2] = 10*60,
    [3] = 15*60,
    [4] = 20*60,
    [5] = 30*60,
    [6] = 40*60,
    [7] = 50*60,
    [8] = 60*60,
    [9] = 75*60,
    [10] = 90*60,
    [11] = 120*60,
    [12] = 180*60,
}

if game.PlaceId == 9118436978 or game.PlaceId == 9118461324 then
	RewardTimes = {
        [1] = 5*6,
        [2] = 10*6,
        [3] = 15*6,
        [4] = 20*6,
        [5] = 30*6,
        [6] = 40*6,
        [7] = 50*6,
        [8] = 60*6,
        [9] = 75*6,
        [10] = 90*6,
        [11] = 120*6,
        [12] = 180*6,
    }
end

for i,Button in pairs (UI.Gifts:GetChildren()) do
    if Button:IsA("ImageButton") then
        Button.MouseButton1Down:Connect(function()
            if Button.Timer.Text == "Redeem!" then
                local result = tonumber(Button.Name)
                local Redeemed,check,am,am2 = Remotes.PlaytimeRedeem:InvokeServer(result)
                if Redeemed then
                    claimed += 1
                    UI.Claimed.Text = claimed.."/12 Gifts Claimed"
                    Button:SetAttribute("Redeemed",true)
                    Button.Claimed.Visible = true
                    Button.Timer.Text = ""
                    if check == "Owned" then
                        local text = "Already owned! You received "..am.." gems instead!"
                        Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
                    else
                        if check == "Income" then
                            local text = "You received $ "..Modules.Format:FormatComma(Paths.Player:GetAttribute("Income")*am).."!"
                            Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
                        elseif check == "Gems" then
                            local text = "You received "..am.." gems!"
                            Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
                        elseif check == "Boost" then
                            local text = "You received x"..am2.." "..am.." Boost!"
                            Paths.Modules.Setup:Notification(text,Color3.new(0.945098, 0.525490, 0.282352),7)
                        end
	                end
                end
            end
        end)
    end
end

task.spawn(function()
    local PlaytimeTable = Remotes.GetStat:InvokeServer("Playtime")
    repeat JoinTime = Paths.Player:GetAttribute("JoinTime"); task.wait(1); PlaytimeTable = Remotes.GetStat:InvokeServer("Playtime") until JoinTime and PlaytimeTable
    local current
    for i = 1,12 do
        local button = UI.Gifts:FindFirstChild(i)
        if not PlaytimeTable[3][i] then
            current = i-1
            break
        else
            claimed += 1
            button:SetAttribute("Redeemed",true)
            button.Claimed.Visible = true
            button.Timer.Text = ""
        end
    end
    if current == 0 then current = 1 end
    if claimed >= 12 then
        UI.Claimed.Text = claimed.."/12 Gifts Claimed"
        Paths.UI.Left.GemDisplay.Amount.Text = "Rewards fully unlocked!"
        return
    end
    
    local currentTimes = {
            JoinTime+(RewardTimes[1]),
            JoinTime+(RewardTimes[2]),
            JoinTime+(RewardTimes[3]),
            JoinTime+(RewardTimes[4]),
            JoinTime+(RewardTimes[5]),
            JoinTime+(RewardTimes[6]),
            JoinTime+(RewardTimes[7]),
            JoinTime+(RewardTimes[8]),
            JoinTime+(RewardTimes[9]),
            JoinTime+(RewardTimes[10]),
            JoinTime+(RewardTimes[11]),
            JoinTime+(RewardTimes[12]),
    }
    local tim = (currentTimes[1]-os.time())
    while task.wait(1) and current < 13 and claimed < 12 do
        UI.Claimed.Text = claimed.."/12 Gifts Claimed"
        tim = tim-1
        local toRedeem = false
        for i,v in pairs (currentTimes) do
            local button = UI.Gifts:FindFirstChild(i)
            if i >= current then
                local leftOver = (v-os.time())
                local t = string.format("%02i:%02i", leftOver/60%60,  leftOver%60)
                if leftOver >= 60*60 then
                    t = string.format("%02i:%02i:%02i", leftOver/60^2, leftOver/60%60, leftOver%60)
                elseif leftOver > 120 then
                    t = string.format("%02i:%02i", leftOver/60%60, leftOver%60)
                elseif leftOver > 60 then
                    t = string.format("%02i:%02i", leftOver/60%60, leftOver%60)
                elseif leftOver <= .5 then
                    t = "Redeem!"
                end
                button.Claimed.Visible = false
                button.Timer.Text = t
            elseif not button:GetAttribute("Redeemed") then
                toRedeem = true
                button.Timer.Text = "Redeem!"
                button.Claimed.Visible = false
            elseif button:GetAttribute("Redeemed") then
                button.Timer.Text = ""
                button.Claimed.Visible = true
            end
        end
        if toRedeem then
            Paths.UI.Left.GemDisplay.Notif.Visible = true
        else
            Paths.UI.Left.GemDisplay.Notif.Visible = false
        end
        if tim > 0 then
            local t = "Next Reward in "..string.format("%02i:%02i", tim/60%60, tim%60)
            if tim >= 60*60 then
                t = "Next Reward in "..string.format("%02i:%02i:%02i", tim/60^2, tim/60%60, tim%60)
            elseif tim > 120 then
                t = "Next Reward in "..string.format("%02i:%02i", tim/60%60, tim%60)
            elseif tim > 60 then
                t = "Next Reward in "..string.format("%02i:%02i", tim/60%60, tim%60)
            end
            
            Paths.UI.Left.GemDisplay.Amount.Text = t
        else
            current += 1
            if current > 12 then
                break
            end
            tim = ((JoinTime+(RewardTimes[current]))-os.time())
        end
    end
    if claimed >= 12 or current >= 12 then
        UI.Claimed.Text = claimed.."/12 Gifts Claimed"
        Paths.UI.Left.GemDisplay.Amount.Text = "Rewards fully unlocked!"
        if claimed < 12 then
            for i = 1,12 do
                local button = UI.Gifts:FindFirstChild(i)
                if not button:GetAttribute("Redeemed") then
                    button:SetAttribute("Redeemed",false)
                    button.Timer.Text = "Redeem!"
                    button.Claimed.Visible = false
                end
            end
        end
    end
    
end)

return Playtime
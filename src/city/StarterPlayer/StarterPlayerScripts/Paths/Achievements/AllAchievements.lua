local Achievements = {}
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local UI = Paths.UI.Center.Achievements.Sections.Achievements
local Example = UI.All.Example
Example.Parent = nil

function getReward(reward,item)
    if reward == "Gems" then
        return "rbxassetid://9846753652"
    elseif reward == "Accessory" then
        return item.."_Accessory"
    end
    return ""
end

for i,Achievement in (Modules.AchievementsDictionary) do
    local Template = Example:Clone()
    Template.Icon.Image = Achievement[2]
    Template.Description.Text = Achievement[1]
    if Achievement[3] == "Text" then
        Template.Reward.Icon.Visible = false
    else
        Template.Reward.Icon.Image = getReward(Achievement[3],Achievement[4])
    end
    Template.Reward.Text.Text = Achievement[4]
    Template.Parent = UI.All
end

return Achievements
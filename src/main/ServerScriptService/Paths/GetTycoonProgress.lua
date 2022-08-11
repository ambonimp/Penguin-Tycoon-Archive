local TycoonProgress = {}

local Paths = require(script.Parent)
local Services = Paths.Services
local Remotes = Paths.Remotes
local Modules = Paths.Modules

local Buttons = {}
local Tycoons = {
    [1] = {0,{}},
    [2] = {0,{}},
}

local NameToId = {
    ["Fishing"] = 1,
    ["Woodcutting"] = 2,
}

for i,button in pairs (Paths.Template.Buttons:GetChildren()) do
    if button:GetAttribute("CurrencyType") == "Money" and button.Name ~= "RebirthMachine" then
        local world = if button:GetAttribute("World") then button:GetAttribute("World") else 1
        Buttons[button.Name] = button:GetAttribute("World") or 1
        Tycoons[world][1] += 1
        Tycoons[world][2][button.Name] = true
    end
end

function TycoonProgress.getProgress(Player,Name)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    if Data then
        local TycoonData = Data["Tycoon"]
        local TycoonsProgress = {
            [1] = {0,{}},
            [2] = {0,{}},
        }

        for name,has in pairs (TycoonData) do
            if has and Buttons[name] then
                local world = Buttons[name]
                TycoonsProgress[world][1] += 1
                TycoonsProgress[world][2][name] = true
            end
        end
        return TycoonsProgress[NameToId[Name]][1]/Tycoons[NameToId[Name]][1]
    end
end

Remotes.TycoonProgress.OnServerInvoke = TycoonProgress.getProgress

return TycoonProgress
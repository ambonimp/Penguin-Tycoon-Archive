local Events = {}

--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Dependency = Services.RStorage.ClientDependency[script.Name]
local FinishedUI = Paths.UI.Center.GeneralEventFinished

local RANKINGS_TEXT = {
	[1] = "1ST",
	[2] = "2ND",
	[3] = "3RD",
	[4] = "4TH",
	[5] = "5TH",
	[6] = "6TH",
	[7] = "7TH",
	[8] = "8TH",
	[9] = "9TH",
	[10] = "10TH",
	[11] = "11TH",
	[12] = "12TH",
	[13] = "13TH",
	[14] = "14TH",
	[15] = "15TH",
	[16] = "16TH",
	[17] = "17TH",
	[18] = "18TH",
	[19] = "19TH",
	[20] = "20TH",
}

local MEDALS = {
    "rbxassetid://9375533145",
    "rbxassetid://9375531827",
    "rbxassetid://9375532976"
}

local SCORE_UNIT = {
    ["Sled Race"] = "s",
    ["Skate Race"] = "s",
    ["Falling Tiles"] = "s"

}

local Player = game.Players.LocalPlayer

local function Reset()
    for _, Placement in FinishedUI.Placement:GetChildren() do
        if Placement:IsA("Frame") then
            Placement:Destroy()
        end
    end
end

local function AddPlacement(Ranking, Info)
    if FinishedUI.Placement:FindFirstChild(Info.PlayerName) then return end

    local Placement = Dependency.Placement:Clone()
    Placement.Name = Info.PlayerName
    Placement.PlayerName.Text = Info.PlayerName
    Placement.Score.Text = string.format("%.1f", Info.Score) .. (SCORE_UNIT[Player:GetAttribute("Minigame")] or "")
    Placement.Medal.Image = MEDALS[Ranking] or ""
    Placement.Parent = FinishedUI.Placement

    if Info.PlayerName == Player.Name then
        Placement.BackgroundColor3 = Color3.new(0.901960, 0.843137, 0.058823)

        FinishedUI.Visible = true
        Paths.Modules.Buttons:UIOn(FinishedUI,true)
        FinishedUI.Title.Text = "YOU PLACED ".. RANKINGS_TEXT[Ranking]

    else
        Placement.BackgroundColor3 = Color3.new(1, 1, 1)
    end

end

function Events:UpdateRankings(Rankings)
    for i, Ranked in ipairs(Rankings) do
        if #Ranked > 0 then
            for _, Ranked2 in ipairs(Ranked) do
                AddPlacement(i, Ranked2)
            end
        else
            AddPlacement(i, Ranked)
        end

    end

end

function Events:EventStarted()
    FinishedUI.Visible = false
    Reset()
end

function Events:EventEnded()
    FinishedUI.Exit.Visible = true
end

-- Resetting
FinishedUI.Exit.MouseButton1Down:Connect(Reset)

return Events
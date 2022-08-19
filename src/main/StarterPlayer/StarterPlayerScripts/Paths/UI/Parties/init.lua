local Players = game:GetService("Players")
local Parties = {}

local Paths = require(script.Parent.Parent)
local Services = Paths.Services
local Remotes = Paths.Remotes
local Modules = Paths.Modules
local UI = Paths.UI

local Dependencies = Services.RStorage.ClientDependency.Party
local Party = require(script.Party)
local Invites = require(script.Invites)


local INVITE_COOLDOWN = Modules.PartyUtil.INVITE_COOLDOWN



local Frame = UI.Center.Party
local LeftDiv = Frame.Left
local RightDiv = Frame.Right

local Search = LeftDiv.Search
local PlayerList = LeftDiv.PlayerList


local MyParty
local InviteDBs = {}

local PotentialPartyMembers = {}

local function LevenshteinDistance(s1, s2)
    if s1 == s2 then return 0 end
    if string.len(s1) == 0 then return string.len(s2) end
    if string.len(s2) == 0 then return string.len(s1) end
    if string.len(s1) < string.len(s2) then s1, s2 = s2, s1 end

    local d = {}

    for i = 1,#s1+1 do
        d[i] = {i-1}
    end

    for j = 1,#s2+1 do
        d[1][j] = j-1
    end

    local cost = 0
    for i = 2,#s1+1 do
        for j = 2,#s2+1 do
            if string.sub(string.lower(s1), i-1, i-1) == string.sub(string.lower(s2), j-1, j-1) then
                cost = 0
            else
                cost = 2
            end

            d[i][j] = math.min(
                d[i-1][j] + 1,
                d[i][j-1] + 1,
                d[i-1][j-1] + cost
            )

        end

    end

    return d[#s1+1][#s2+1]
end

local function AddToPlayerList(Player)
    if not Player:GetAttribute("Party") and Player:GetAttribute("AcceptingPartyInvites") then
        local Name = Player.Name
        table.insert(PotentialPartyMembers, Name)

        local ListItem = Dependencies.PlayerTemplate:Clone()
        ListItem.Name = Name
        ListItem.TextLabel.Text = Name
        ListItem.Parent = PlayerList


        InviteDBs[Player] = nil

        local InviteBtn = ListItem.Invite
        InviteBtn.MouseButton1Down:Connect(function()
            if not InviteDBs[Player] then
                local CanInvite, ReasonWhyNot = Modules.PartyUtil.IsInviteValid(Paths.Player, Player)
                if CanInvite then
                    InviteDBs[Player] = true

                    InviteBtn.BackgroundColor3 = Color3.fromRGB(173, 173, 173)
                    InviteBtn.Icon.ImageTransparency = 0.5

                    Remotes.PartyInvite:FireServer(Player)

                    task.wait(INVITE_COOLDOWN)
                    InviteDBs[Player] = nil

                    if ListItem.Parent then
                        InviteBtn.BackgroundColor3 = Color3.fromRGB(255, 226, 0)
                        InviteBtn.Icon.ImageTransparency = 0
                    end

                else
                    Modules.Snackbars.Error(ReasonWhyNot)
                end

            end

        end)

    end

end

local function RemoveFromPlayerList(Player)
    local ListItem = PlayerList:FindFirstChild(Player.Name)
    if ListItem then
        ListItem:Destroy()
        table.remove(PotentialPartyMembers, table.find(PotentialPartyMembers, Player.Name))
    else
        warn(PlayerList:GetChildren())
    end

end

local function LoadPlayer(Player)
    local IsLocalPlayer = Player == Paths.Player

    if IsLocalPlayer then
        local PartyId = Player:GetAttribute("Party")
        if PartyId then
            MyParty = Party.new(PartyId)
        end

        Player:GetAttributeChangedSignal("Party"):Connect(function()
            local PartyId = Player:GetAttribute("Party")

            if not PartyId then
                if MyParty then
                  -- Server removed you from party
                    MyParty:Destroy()
                end

            elseif not MyParty then
                MyParty = Party.new(PartyId)
            end

        end)

    else
        AddToPlayerList(Player)

        Player:GetAttributeChangedSignal("Party"):Connect(function()
            local PartyId = Player:GetAttribute("Party")

            if PartyId then
                if MyParty and MyParty.Id == PartyId  then -- Fellow party member
                    MyParty:AddMember(Player)
                end
                RemoveFromPlayerList(Player)
            else
                if MyParty then
                    -- Checks if they were in inside party, if so, removes them
                    MyParty:RemoveMember(Player)
                end

                AddToPlayerList(Player)

            end

        end)

        Player:GetAttributeChangedSignal("AcceptingPartyInvites"):Connect(function()
            local AcceptingInvites =  Player:GetAttribute("AcceptingPartyInvites")

            if AcceptingInvites then
                AddToPlayerList(Player)
            else
                RemoveFromPlayerList(Player)
            end

        end)

    end

end


local function UnloadPlayer(Player)
    InviteDBs[Player] = false

    if MyParty then
        MyParty:RemoveMember(Player)
    end
    RemoveFromPlayerList(Player)
end





function Parties.ExitParty()
    MyParty = nil

    RightDiv.InParty.Visible = false
    RightDiv.OutOfParty.Visible = true

end


-- Testing
game:GetService("UserInputService").InputBegan:Connect(function(input, p)
    if p then return end
    if input.KeyCode == Enum.KeyCode.E then
        Remotes.PartyInvite:FireServer(Paths.Player)
    elseif input.KeyCode == Enum.KeyCode.R then
        MyParty:AddMember(Paths.Player)
    end
end)



-- Setup ui
Parties.ExitParty()

-- Add and remove player to PlayerList
for _, Player in ipairs(Players:GetPlayers()) do
    LoadPlayer(Player)
end
Players.PlayerAdded:Connect(LoadPlayer)
Players.PlayerRemoving:Connect(UnloadPlayer)

-- Search
Search:GetPropertyChangedSignal("Text"):Connect(function()
    local Text = Search.Text

    if Text == "" then
        PlayerList.UIGridLayout.SortOrder = Enum.SortOrder.Name
    else
        PlayerList.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local ToOrder = Modules.FuncLib.TableClone(PotentialPartyMembers)
        for i = 1, #PotentialPartyMembers do
            local LowestScore = math.huge
            local ClosestName

            for _, Name in ipairs(ToOrder) do
                local Score = LevenshteinDistance(Text, Name)

                if Score < LowestScore then
                    LowestScore = Score
                    ClosestName = Name
                end

            end

            table.remove(ToOrder, table.find(ToOrder, ClosestName))
            PlayerList:FindFirstChild(ClosestName).LayoutOrder = i

        end

    end

end)


return Parties
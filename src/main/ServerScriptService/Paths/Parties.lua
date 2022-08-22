local Players = game:GetService("Players")
local Parties = {}

local Paths = require(script.Parent)
local Services = Paths.Services
local Remotes = Paths.Remotes
local Modules = Paths.Modules

local InviteHistory = {
}

local INVITE_COOLDOWN = Modules.PartyUtil.INVITE_COOLDOWN

local function GetInviteId(Sender, Receiver)
    return Sender.Name .. Receiver.Name
end

local function JoinParty(Leader, NewMember)
    local PartyId = Leader.UserId
    NewMember:SetAttribute("Party", PartyId)
    NewMember:SetAttribute("WaitingParty", nil)

    Leader:SetAttribute("Party", PartyId)
    Leader:SetAttribute("WaitingParty", nil)

end

Remotes.PartyInvite.OnServerEvent:Connect(function(Sender, Receiver)
    if Modules.PartyUtil.IsInviteValid(Sender, Receiver) then
        Remotes.PartyInvite:FireClient(Receiver, Sender)

        local InviteId = GetInviteId(Sender, Receiver)
        InviteHistory[InviteId] = true
        task.delay(INVITE_COOLDOWN, function()
            InviteHistory[InviteId] = false
        end)

    end

end)

Remotes.PartyInviteAccepted.OnServerEvent:Connect(function(Receiver , Sender)
    local InviteId = GetInviteId(Sender, Receiver)
    if InviteHistory[InviteId] then
        InviteHistory[InviteId] = nil

        JoinParty(Sender, Receiver)

    end

end)

Remotes.KickFromParty.OnServerEvent:Connect(function(Kicker, Kicking)
    local PartyId = if Kicker == Kicking then Kicker:GetAttribute("Party") else Kicker.UserId
    if Kicking:GetAttribute("Party") == PartyId then
        Kicking:SetAttribute("Party", nil)

        -- Player can't be in a party by themselves
        if #Modules.PartyUtil.GetPartyMembers(PartyId) == 1 then
            Players:GetPlayerByUserId(PartyId):SetAttribute("Party", nil)
        end
    end

end)


function Parties.LoadPlayer(Player)
    local Data = Modules.PlayerData.sessionData[Player.Name]
    local PartyId = Data.TeleportedParty

    if PartyId then
        Data.PartyId = nil

        local Members = Modules.PartyUtil.GetPartyMembers(PartyId)
        if #Members > 0 then
            -- Add Late-comer to party from old place
            Player:SetAttribute("Party", PartyId)

        else
            Player:SetAttribute("WaitingParty", PartyId)
            if PartyId == Player.UserId then -- This user is the leader
                local MembersLoadingConn
                local JoiningOtherPartyConn

                local function LoadParty(FirstMember)
                    if FirstMember:GetAttribute("WaitingParty") == PartyId then
                        JoinParty(Player, FirstMember)
                        MembersLoadingConn:Disconnect()
                    end
                end

                -- Wait for first other member to join and then create a party with members from old one
                for _, Player in ipairs(Services.Players:GetPlayers()) do
                    LoadParty(Player)
                end
                MembersLoadingConn = Services.Players.PlayerAdded:Connect(LoadParty)

                -- If you leader joins another party, this party is disbanded
                JoiningOtherPartyConn = Player:GetAttributeChangedSignal("Party"):Connect(function()
                    MembersLoadingConn:Disconnect()
                    JoiningOtherPartyConn:Disconnect()
                end)

            end

        end

    end

    Player:SetAttribute("AcceptingPartyInvites", Data.Settings["Party Invites"])

end

return Parties
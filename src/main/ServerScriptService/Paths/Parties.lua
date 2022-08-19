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

        local PartyId = Sender.UserId
        Receiver:SetAttribute("Party", PartyId)
        Sender:SetAttribute("Party", PartyId)

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
    Player:SetAttribute("AcceptingPartyInvites", Data.Settings["Party Invites"])
end

return Parties
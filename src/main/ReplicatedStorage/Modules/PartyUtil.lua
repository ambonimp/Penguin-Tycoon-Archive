local Players = game:GetService("Players")

local PartyUtil = {}

PartyUtil.INVITE_DURATION = 10
PartyUtil.INVITE_COOLDOWN = 30
PartyUtil.MEMBER_CAP = 6

function PartyUtil.GetPartyMembers(Id)
    local Members = {}

    if Id then
        for _, OtherPlayer in Players:GetPlayers() do
            if OtherPlayer:GetAttribute("Party") == Id then
                table.insert(Members, OtherPlayer)
            end

        end

    end

    return Members
end

function PartyUtil.IsInviteValid(Sender, Receiver)
    local PartyId = Sender.UserId
    local PartyMembers = PartyUtil.GetPartyMembers(PartyId)

    if not  Sender.Parent then return false, "Player left the game" end
    if not  Receiver.Parent then return false, "Player left the game" end
    if #PartyMembers >= PartyUtil.MEMBER_CAP then return false, "Party full" end
    if not Receiver:GetAttribute("AcceptingPartyInvites") then return false, "Player not acceping party invites" end
    if Receiver:GetAttribute("Party") then return false, "Player already in party" end

    return true

end


return PartyUtil
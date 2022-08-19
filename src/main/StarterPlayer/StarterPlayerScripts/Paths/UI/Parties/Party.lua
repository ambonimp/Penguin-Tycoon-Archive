local Party = {}
Party.__index = Party

local Paths = require(script.Parent.Parent.Parent)
local Services = Paths.Services
local Remotes = Paths.Remotes
local Modules = Paths.Modules
local UI = Paths.UI

local Dependencies = Services.RStorage.ClientDependency.Party


local MEMBER_CAP = Modules.PartyUtil.MEMBER_CAP


local Frame = UI.Center.Party
local LeftDiv = Frame.Left
local RightDiv  = Frame.Right

local Section = RightDiv.InParty -- Section where stuff pertaining to a party can be found
local MemberList = Section.MemberList

local Header = Section.Header
local MemberCount = Header.MemberCount
local LeaveBtn = Header.Leave

local HotbarBtn = UI.Bottom.Buttons.Party

local DefaultRightDivSize = RightDiv.Size


function Party.new(Id)
    local self = setmetatable({}, Party)
    self.Maid = Modules.Maid.new()

    self.Id = Id
    self.AmLeader = Id == Paths.Player.UserId

    self.Members = {}
    for _, Member in (Modules.PartyUtil.GetPartyMembers(Id)) do
        self:AddMember(Member)
    end
    self:UpdateMemberCount()


    -- Restructure layout
    HotbarBtn.Visible = true

    Section.Visible = true
    RightDiv.OutOfParty.Visible = false

    if not self.AmLeader then
        Modules.Snackbars.Info("Party created")

        -- Non leader don't need to see the playerlist, they can't invite
        LeftDiv.Visible = false
        RightDiv.Size = UDim2.fromScale(1, RightDiv.Size.Y.Scale)

        -- Only non-leaders can leave a party
        LeaveBtn.Visible = true
        self.Maid:GiveTask(LeaveBtn.MouseButton1Down:Connect(function()
            Remotes.KickFromParty:FireServer(Paths.Player)
        end))

    else
        Modules.Snackbars.Info("Party joined")
        LeaveBtn.Visible = false
    end

    return self
end

function Party:AddMember(Player)
    local i = #self.Members + 1
    local IsLeader = Player.UserId == self.Id
    self.Members[i] = Player

    self:UpdateMemberCount()

    local ListItem = MemberList[i]
    ListItem.Occupied.Visible = true
    ListItem.Unoccupied.Visible = false
    ListItem.LayoutOrder = if IsLeader then 0 else i


    local Info = ListItem.Occupied.Info
    Info.Leader.Visible = IsLeader
    Info.PlayerName.Text = Player.Name

    pcall(function()
        Info.Thumbnail.Image = game.Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)

    local KickBtn = ListItem.Occupied.Kick
    if self.AmLeader and not IsLeader then
        KickBtn.Visible = true
        self.Maid:GiveTask(KickBtn.MouseButton1Down:Connect(function()
            Remotes.KickFromParty:FireServer(Player)
        end))
    else
        KickBtn.Visible = false
    end

end

function Party:RemoveMember(Player)
    local i = table.find(self.Members, Player)

    if i then
        table.remove(self.Members, i)
        self:UpdateMemberCount()

        local ListItem = MemberList[i]
        ListItem.Occupied.Visible = false
        ListItem.Unoccupied.Visible = true
        ListItem.LayoutOrder = 10

        if self.AmLeader then
            Modules.Snackbars.Info(string.format("%s left your party", Player.Name))
        end
    else
        warn(self.Members)
    end

end

function Party:UpdateMemberCount()
    MemberCount.Text = string.format("Members (%s/%s)", #self.Members, MEMBER_CAP)
end


function Party:Destroy()
    -- Revert layout
    LeftDiv.Visible = true
    RightDiv.Size = DefaultRightDivSize

    HotbarBtn.Visible = false
    Modules.Parties.ExitParty()

    for i in self.Members do
        local ListItem = MemberList[i]
        ListItem.Occupied.Visible = false
        ListItem.Unoccupied.Visible = true
        ListItem.LayoutOrder = 10
    end

    self.Maid:Destroy()
    setmetatable(self, nil)
end


-- Initialize section
HotbarBtn.MouseButton1Down:Connect(function()
    Modules.Buttons:UIOn(Frame, true)
end)

for i = 1, MEMBER_CAP do
    local ListItem = Dependencies.MemberTemplate:Clone()
    ListItem.Name = i
    ListItem.Occupied.Visible = false
    ListItem.Unoccupied.Visible = true
    ListItem.LayoutOrder = 10
    ListItem.Parent = MemberList
end

return Party
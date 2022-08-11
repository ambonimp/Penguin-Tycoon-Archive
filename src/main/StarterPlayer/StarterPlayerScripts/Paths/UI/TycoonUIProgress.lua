local TycoonUIProgress = {}

local Paths = require(script.Parent.Parent)
local Remotes = Paths.Remotes
local Modules = Paths.Modules
local Services = Paths.Services
local UI = Paths.UI

local TycoonsUnlocked = {}

local Frame = UI.Center.WorldTeleport
local List = Frame.Sections.Tycoon.List

local PlayersFrame = UI.Center.WorldTeleport.Sections.Players
local TeleportsFrame = PlayersFrame.List
local CurrentLocation = Paths.Player.UserId

function TycoonUIProgress.IsUnlocked(Name) 
    return TycoonsUnlocked[Name]
end
local Data = Remotes.GetStat:InvokeServer("Tycoon")
local RocketUnlocked = Data["Rocketship#1"] or false
local lastUpdated = os.time()-10
local Progress = {
    ["Fishing"] = nil,
    ["Woodcutting"] = nil}

function TycoonUIProgress.Update(Object)
    if os.time()-lastUpdated < 1 and Object ~= "Rocketship#1" then return end
    lastUpdated = os.time()
    if Object == "Rocketship#1" then
        RocketUnlocked = true
    end
    for i,World in pairs (List:GetChildren()) do
        local WorldName = World:GetAttribute("Name")
        if WorldName then
            if (WorldName ~= "Fishing" and RocketUnlocked) or WorldName == "Fishing" then
                Progress[WorldName] = Remotes.TycoonProgress:InvokeServer(WorldName)

                local per = math.floor(Progress[WorldName]*10000)/100
                if Progress[WorldName] < .05 then
                    World.Progress.Frame.Size = UDim2.fromScale(.05,1)
                else
                    World.Progress.Frame.Size = UDim2.fromScale(Progress[WorldName],1)
                end
                
                World.ProgressText.Text = per.."%"
                World:SetAttribute("Unlocked",true)
            end
        end
    end
end

function addPlayerToTeleport(Player)
    local emptyFrame = nil
    for i,v in pairs (TeleportsFrame:GetChildren()) do
        if v:IsA("ImageButton") and not v.Visible then
            emptyFrame = v
            break
        end
    end

    if emptyFrame then
        emptyFrame.Icon.Image = Services.Players:GetUserThumbnailAsync(Player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
        if Player == Paths.Player then
            emptyFrame.LayoutOrder = -1
            emptyFrame.TextLabel.Text = "My Tycoon"
        else
            emptyFrame.TextLabel.Text = Player.Name
        end
        emptyFrame:SetAttribute("Player",Player.UserId)
        emptyFrame.Visible = true
    end
end

for i,v in pairs (TeleportsFrame:GetChildren()) do
    if v:IsA("ImageButton") then
        v.Teleport.MouseButton1Down:Connect(function()
            local id = v:GetAttribute("Player")
            if id and CurrentLocation ~= id then
                local player = Services.Players:GetPlayerByUserId(id) 
                CurrentLocation = id
                Modules.Buttons:UIOff(Frame, true)
                Modules.UIAnimations.BlinkTransition(function()
                    local Name = player.Name
                    Remotes.TeleportInternal:InvokeServer(Name)
        
                end, true)
            elseif id == nil then
                v.Visible = false
            end
        end)
    end
end

function playerLeft(Player)
    if CurrentLocation == Player.UserId then
        CurrentLocation = Paths.Player.UserId
        Modules.UIAnimations.BlinkTransition(function()
            local Name = Paths.Player.Name
            Remotes.TeleportInternal:InvokeServer(Name)

        end, true)
    end
    local frame = nil
    for i,v in pairs (TeleportsFrame:GetChildren()) do
        if v:GetAttribute("Player") == Player.UserId then
            frame = v
            break
        end
    end
    frame:SetAttribute("Player",nil)
    frame.Visible = false
end

for i,v in pairs (Services.Players:GetPlayers()) do
    addPlayerToTeleport(v)
end

Services.Players.PlayerAdded:Connect(addPlayerToTeleport)
Services.Players.PlayerRemoving:Connect(playerLeft)

TycoonUIProgress.Update()

return TycoonUIProgress
local BoatSpawner = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local TycoonTemplate = Services.RStorage.Template

-- Functions
function BoatSpawner.Equipped(Player)

end

-- Events ==
Remotes.VehicleSpawned.OnServerEvent:Connect(function(Client, Id, CF)
    local Data =  Modules.PlayerData.sessionData[Client.Name]
    if not Data and not Data.Gamepasses[tostring(54396254)] then return end

    -- Get info
    local Details = Modules.VehicleDetails[Id]

    local Island = if Details.Source == "Button" then TycoonTemplate.Buttons[Id]:GetAttribute("Island") else Details.Island
    local Vehicle = TycoonTemplate.Upgrades[Island][Id]:GetAttribute("Vehicle")
    local Unlocked = workspace.Tycoons[string.gsub(Client.Team.Name, " Island", "")].Tycoon:FindFirstChild(Id)

    if Unlocked then
        -- Check that position is valid
        local Model = Services.RStorage.Assets.Vehicles[Vehicle]
        local Center, Size = Model:GetBoundingBox()

        CanPlace = true
        local Colliding = workspace:GetPartBoundsInBox(CF + Vector3.new(0, 1, 0), Size, OverlapParams.new())
        for _, Part in ipairs(Colliding) do
            if Part.CanCollide and Part.Transparency ~= 1 then
                CanPlace = false
                break
            end
        end

        -- Boats must spawn on water
        if CanPlace and Details.Type == "Boat" then
            local RParams = RaycastParams.new()
            RParams.IgnoreWater = false

            CanPlace = workspace:Raycast(CF.Position, Vector3.new(0, -Size.Y*0.6, 0), RParams).Instance == workspace.Terrain
        end

       if CanPlace then
            Modules.Vehicles:SpawnVehicle(Client, Vehicle, CF * Center:ToObjectSpace(Model.PrimaryPart.CFrame))
       end

    end

end)

-- Testing
if game.PlaceId == 9118461324 or game.PlaceId == 9118436978 then
    task.spawn(function()
        require(game.ServerScriptService:WaitForChild("ChatServiceRunner").ChatService):RegisterProcessCommandsFunction("Commands", function(Speaker, Message)
            local Player = game.Players[Speaker]
            if Player then
                if string.find(Message, "EnableVehicleSpawner") then
                   Modules.Gamepasses:AwardGamepass(Speaker, 54396254)
                end
            end

            return false
        end)

    end)

end



return BoatSpawner

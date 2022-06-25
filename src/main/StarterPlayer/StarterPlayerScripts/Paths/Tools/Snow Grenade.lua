local Launcher = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes

local Assets = Services.RStorage.Assets.Tools[script.Name]

local BLAST_RADIUS = 5
task.spawn(function()
    repeat task.wait() until Modules.Tools
    local BASE
    repeat
        BASE =  Modules.Tools.Handlers["Projectile Launcher"]
        task.wait()
    until BASE

    local Handler = BASE.new(script.Name, function(_, Position)
        if Launcher.Damageables then
            local Registered = {}
            -- Explosion
            for _, Hit in workspace:GetPartBoundsInRadius(Position, 8, OverlapParams.new()) do
                for _, Model in ipairs(Launcher.Damageables) do
                    if not Registered[Model] and Hit:IsDescendantOf(Model) then
                        Launcher.Hit:Fire(Model)
                        Registered[Model] = true

                        break
                    end

                end

            end

        end

        -- Special effects
        local FX = Assets["HitFX"]:Clone()
        FX.Parent = workspace
        FX.Position = Position

        local Particles = FX.Attachment
        for _, Particle in ipairs(Particles:GetChildren()) do
            Particle:Emit(1)
        end
        game:GetService("Debris"):AddItem(FX, 2)

        return true

    end)

    for k, v in Handler do
        Launcher[k] = v
    end

end)


return Launcher
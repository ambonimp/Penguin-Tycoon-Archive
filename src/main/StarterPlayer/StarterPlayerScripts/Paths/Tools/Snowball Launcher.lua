local Launcher = {}

local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes


local Assets = Services.RStorage.Assets.Tools[script.Name]

task.spawn(function()
    repeat task.wait() until Modules.Tools
    local BASE
    repeat
        BASE =  Modules.Tools.Handlers["Projectile Launcher"]
        task.wait()
    until BASE

    local Handler = BASE.new(script.Name, function(Hit, Position)
        local HitSomethingUseful

        if Launcher.Damageables then
            for i, Model in ipairs(Launcher.Damageables) do
                if Hit:IsDescendantOf(Model) then
                    Launcher.Hit:Fire(Model)
                    HitSomethingUseful = false

                    break

                end

            end

        end

        -- Special effects
         local FX = Assets["HitFX"]:Clone()
         FX.Parent = workspace
         FX.Position = Position

         local Particles = FX.Attachment
         for _, Particle in ipairs(Particles:GetChildren()) do
             Particle:Emit(3)
         end
         game:GetService("Debris"):AddItem(FX, 2)

        return HitSomethingUseful
    end)

    for k, v in Handler do
        Launcher[k] = v
    end

end)


return Launcher
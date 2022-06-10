local Lighting = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes






--- Lighting Variables ---
local Presets = Services.RStorage.LightingPresets
Lighting.CurrentLocation = "Night Skating" -- require(Services.RStorage.Modules.EventsConfig).Names[game.PlaceId]

--- Functions ---
function Lighting:ChangeLighting(Preset)
	if not Presets:FindFirstChild(Preset) or Preset == Lighting.CurrentLocation then return end
	Lighting.CurrentLocation = Preset
	Services.Lighting:ClearAllChildren()

	-- Module is loaded after this one, so not a garuantee that it exists in Modules when this event is fired
	if not Modules.AudioHandler then
		repeat task.wait() until Modules.AudioHandler
	end
	Modules.AudioHandler:LocationChanged(Preset)

	for i, v in pairs(Presets[Preset]:GetChildren()) do
		if not v:IsA("Folder") then
			v:Clone().Parent = Services.Lighting
		else
			for i, v in pairs(v:GetChildren()) do
				if Services.Lighting[v.Name] then
					Services.Lighting[v.Name] = v.Value
				end
			end 
		end
	end

end

Remotes.Lighting.OnClientEvent:Connect(function(Location)
	Lighting:ChangeLighting(Location)
end)


-- Initiate Little World Lighting

return Lighting
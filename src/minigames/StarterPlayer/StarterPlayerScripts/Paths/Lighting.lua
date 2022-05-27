local Lighting = {}


--- Main Variables ---
local Paths = require(script.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Lighting Variables ---
local Presets = Services.RStorage.LightingPresets
Lighting.CurrentLocation = "Night Skating"



--- Functions ---
function Lighting:ChangeLighting(Preset)
	-- Module is loaded after this one, so not a garuantee that it exists in Modules when this event is fired
	repeat task.wait() until Modules.AudioHandler

	if not Presets:FindFirstChild(Preset) or Preset == Lighting.CurrentLocation then return end
	Lighting.CurrentLocation = Preset
	Modules.AudioHandler:LocationChanged(Preset)
	Services.Lighting:ClearAllChildren()

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
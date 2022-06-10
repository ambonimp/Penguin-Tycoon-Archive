local FallingTiles = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes



--- Event Variables ---
local Participants = Services.RStorage.Modules.EventsConfig.Participants
local EventInfoUI = Paths.UI.Top.EventInfo



--- Event Functions ---

function FallingTiles.InitiateEvent()
	local Map = workspace.Event:FindFirstChild("Event Map")

	local Debounces = {}

	for _, Layer in pairs(Map.Layers:GetChildren()) do
		for _, Tile in ipairs(Layer:GetChildren()) do
			Tile.Hitbox.Touched:Connect(function(Hit)
				if not Debounces[Tile] and (string.find(Hit.Name, "Leg") or Hit.Name == "Main") and Map.Active.Value == true then
					Debounces[Tile] = true

					local Completed
					for _, Child in ipairs(Tile:GetChildren()) do
						if Child:IsA("BasePart") then
							local Tween = Services.TweenService:Create(Child, TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = 1})
							Completed = Completed or Tween.Completed
							Tween:Play()
						end
					end

					task.delay(0.25, function()
						Tile.Collideable.CanCollide = false
					end)

				end

			end)

		end

	end

end

Remotes.FallingTiles.OnClientEvent:Connect(function(Event, ...)
	local Params = table.pack(...)

	if Event == "Finished" then
        local Rankings = Params[1]
        Modules.EventsUI:UpdateRankings(Rankings)
	end

end)

return FallingTiles

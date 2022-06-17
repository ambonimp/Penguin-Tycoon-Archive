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
		for _, Tile in pairs(Layer:GetChildren()) do
			Tile.Hitbox.Touched:Connect(function(part)
				if not Debounces[Tile] and (string.find(part.Name, "Leg") or part.Name == "Main") and Map.Active.Value == true then
					Debounces[Tile] = true

					for _ = 0, 20, 1 do
						if _ == 8 then
							task.spawn(function()
								for i = 0, 1, 0.1 do
									if Tile and Tile.Parent then
										Tile.TopTile.Transparency = i
										Tile.BottomTile.Transparency = i
									else
										return
									end
									task.wait()
								end

							end)

						end

						if Tile and Tile.Parent then
							Tile.TopTile.Position = Vector3.new(Tile.TopTile.Position.X, Tile.TopTile.Position.Y - 0.06, Tile.TopTile.Position.Z)
							Tile.BottomTile.Position = Vector3.new(Tile.BottomTile.Position.X, Tile.BottomTile.Position.Y - 0.06, Tile.BottomTile.Position.Z)
							task.wait()
						else
							return
						end

					end

					if Tile and Tile.Parent then
						Tile:Destroy()
					end
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

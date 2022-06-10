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

	local TilesTouched = {}

		for i, layer in pairs(Map.Layers:GetChildren()) do
			for i, tile in pairs(layer:GetChildren()) do
				if not tile:FindFirstChild("Hitbox") then break end
				tile.Hitbox.Touched:Connect(function(part)
					if not TilesTouched[tile] and (string.find(part.Name, "Leg") or part.Name == "Main") and Map.Active.Value == true then
						TilesTouched[tile] = true

						for i = 0, 20, 1 do
							if i == 8 then
								coroutine.resume(coroutine.create(function()
									for i = 0, 1, 0.1 do
										if tile then
											tile.TopTile.Transparency = i
											tile.BottomTile.Transparency = i
										end
										wait()
									end
								end))
							end
							if tile then
								tile.TopTile.Position = Vector3.new(tile.TopTile.Position.X, tile.TopTile.Position.Y - 0.06, tile.TopTile.Position.Z)
								tile.BottomTile.Position = Vector3.new(tile.BottomTile.Position.X, tile.BottomTile.Position.Y - 0.06, tile.BottomTile.Position.Z)
								wait()
							else break
							end
						end

						if tile then tile:Destroy() end
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

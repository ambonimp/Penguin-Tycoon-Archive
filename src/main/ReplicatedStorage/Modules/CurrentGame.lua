local CurrentGame = {}
local IDs = {--dev,qa,live
	["Tycoon"] = {9549503548,9118461324,7951464846}, 
	["City"] = {9170899192,9170919040,7967681044},
}

function CurrentGame.getGame()
	if table.find(IDs["Tycoon"],game.PlaceId) then
		return "Tycoon"
	elseif table.find(IDs["City"],game.PlaceId) then
		return "City"
	else
		return "Minigames"
	end
end

local game = CurrentGame.getGame()

workspace:SetAttribute("WorldPlace",game)

return CurrentGame
local Ids = {}

local GameId = game.GameId

if GameId == 3073627998 then -- Main
    Ids["Penguin Tycoon"] = 7951464846
    Ids["Penguin City"] = 7967681044
    Ids["Falling Tiles"] = 9731097292
    Ids["Skate Race"] = 9731100542
    Ids["Candy Rush"] = 9731101983
    Ids["Soccer"] = 9731106565
    Ids["Ice Cream Extravaganza"] = 9731108400
elseif GameId == 3425588324 then -- DEV
    Ids["Penguin Tycoon"] = 9118436978
    Ids["Penguin City"] = 9170899192
    Ids["Falling Tiles"] = 9648022475
    Ids["Skate Race"] = 9647517478
    Ids["Candy Rush"] = 9648025781
    Ids["Soccer"] = 9648024554
    Ids["Ice Cream Extravaganza"] = 9656094271
elseif GameId == 3425594443 then -- QA
    Ids["Penguin Tycoon"] = 9118461324
	Ids["Penguin City"] = 9170919040
    Ids["Skate Race"] = 9731035076
    Ids["Falling Tiles"] = 9731064019
    Ids["Soccer"] = 9731069338
    Ids["Candy Rush"] = 9731075144
    Ids["Ice Cream Extravaganza"] = 9731078128
end

return Ids
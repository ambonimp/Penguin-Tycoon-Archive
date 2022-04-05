local VoldexGames = require(game.ReplicatedStorage.VoldexAdmin.VoldexGames)
local VoldexMiddleware = {}

-- Returns true if the local player is an authorized moderator
function VoldexMiddleware.IsPlayerAuthorized(player: Player): boolean
    local groupData = VoldexGames[game.PlaceId]
    if not groupData then
        return false
    end
    
    local groupId = groupData.groupId
    local groupRank = groupData.groupRank
	return player:GetRankInGroup(groupId) >= groupRank
end

return VoldexMiddleware
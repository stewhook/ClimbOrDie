local ServerBadgeCache = require(script.Parent.ServerBadgeCache)
local m = {}

function m.playerOwns(player: Player, badgeID)
	if not player then
		return
	end
	if not badgeID then
		return
	end
	if not ServerBadgeCache[player] then
		return
	end
	for _, ID in ServerBadgeCache[player] do
		if badgeID == ID then
			return true
		end
	end
	return false
end

return m

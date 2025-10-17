local Players = game:GetService("Players")
local player = Players.LocalPlayer
local BadgeCache = require(player.PlayerScripts.CacheHandler.BadgeCache.BadgeCache)
local m = {}

function m.playerOwnsBadge(ID)
	for _, Badge in BadgeCache.OwnedBadges do
		if ID == Badge then
			return true
		end
	end
	return false
end

return m
local Players = game:GetService("Players")
local module = {}

module.AvatarCache = {}

function module.AddToCache(player: Player)
	if not player then
		return
	end
	if module.AvatarCache[player.UserId] then
		return
	end

	local avatar = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
	module.AvatarCache[player.UserId] = avatar
	return avatar
end

function module.SynchronizeCache()
	for _, player in Players:GetPlayers() do
		if not player.Parent then
			continue
		end

		if module.AvatarCache[player.UserId] then
			continue
		end

		local avatar = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
		module.AvatarCache[player.UserId] = avatar
	end
end

function module.RemoveFromCache(player: Player)
	if not module.AvatarCache[player.UserId] then
		return
	end
	module.AvatarCache[player.UserId] = nil
end

return module

local Players = game:GetService("Players")
local AvatarCache = require(script.Parent.AvatarCache)

Players.PlayerAdded:Connect(AvatarCache.AddToCache)
Players.PlayerRemoving:Connect(AvatarCache.RemoveFromCache)

AvatarCache.SynchronizeCache()
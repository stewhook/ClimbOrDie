local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductKey = require(ReplicatedStorage.StaticData.DevProductKey)
local eventFolder = ReplicatedStorage.Events.Marketplace

local joinMidGameEvent: RemoteEvent = eventFolder.JoinMidGameEvent
local revivePlayerEvent: RemoteEvent = eventFolder.RevivePlayerEvent

joinMidGameEvent.OnServerEvent:Connect(function(player: Player)
    MarketplaceService:PromptProductPurchase(player, DevProductKey.JoinActive)
end)

revivePlayerEvent.OnServerEvent:Connect(function(player: Player)
    MarketplaceService:PromptProductPurchase(player, DevProductKey.Revive)
end)
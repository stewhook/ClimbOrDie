local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductKey = require(ReplicatedStorage.StaticData.DevProductKey)
local eventFolder = ReplicatedStorage.Events.Marketplace

local revivePlayerEvent: RemoteEvent = eventFolder.RevivePlayerEvent

revivePlayerEvent.OnServerEvent:Connect(function(player: Player)
    MarketplaceService:PromptProductPurchase(player, DevProductKey.Revive)
end)
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductKey = require(ReplicatedStorage.StaticData.DevProductKey)
local eventFolder = ReplicatedStorage.Events.Marketplace

local revivePlayerEvent: RemoteEvent = eventFolder.RevivePlayerEvent
local devProductEvent: RemoteEvent = eventFolder.PromptProduct
local devProductBind: BindableEvent = eventFolder.PromptProductBind

revivePlayerEvent.OnServerEvent:Connect(function(player: Player)
	MarketplaceService:PromptProductPurchase(player, DevProductKey.Revive)
end)

devProductEvent.OnServerEvent:Connect(function(player: Player, productID: number)
	MarketplaceService:PromptProductPurchase(player, productID)
end)

devProductBind.Event:Connect(function(player: Player, productID: number)
	MarketplaceService:PromptProductPurchase(player, productID)
end)

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassCache = require(script.Parent.GamepassCache)
local GamepassKeys = require(ReplicatedStorage.StaticData.GamepassKeys)

local gamePassInitEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Marketplace"):WaitForChild("LocalGamepassPriceInit")

local function initCache()
	for _, ID in GamepassKeys do
		local success, data = pcall(function()
			return MarketplaceService:GetProductInfo(ID, Enum.InfoType.GamePass)
		end)

		local success2, data2 = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, ID)
		end)

		if not success or not success2 then
			player:Kick("Error during loading. Please Rejoin")
			return
		end

		local payload = {
			ProductInfo = data,
			PlayerOwns = data2,
		}
		GamepassCache[ID] = payload
	end
end

local function sendPricingData()
	local payload = {}
	for ID, data in GamepassCache do
		payload[ID] = data.ProductInfo.PriceInRobux
	end
    print(payload)
	gamePassInitEvent:FireServer(payload)
end

initCache()
sendPricingData()
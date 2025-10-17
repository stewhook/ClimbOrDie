local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local GearDetails = require(ReplicatedStorage.StaticData.Gear.GearDetails)
local DataManager = require(ServerScriptService.DataStore.DataManager)

local gearBuyRequest: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.BuyItemRequest

gearBuyRequest.OnServerEvent:Connect(function(player: Player, gearID: string)
	if not player then
		return
	end
	local details = GearDetails[gearID]
	if not details then
		return
	end
	local itemCache = player:WaitForChild("ItemCache", 3)
	if not itemCache then
		return
	end
	local playerOwns = itemCache:FindFirstChild(gearID)
	if playerOwns then
		return
	end
	local profile = DataManager.verifyProfile(player)
	if not profile then
		return
	end

	if details.Price == nil and details.GamepassID ~= nil then
		-- Store the gear ID for this player's pending gamepass purchase
		MarketplaceService:PromptGamePassPurchase(player, details.GamepassID)
		return
	end

	local playerBal = profile.Data.Coins
	if not playerBal then
		return
	end

	if playerBal < details.Price then
		return
	end

	DataManager.incrementValue(player, "Coins", -details.Price)
	DataManager.adjustInventory(player, gearID, true)
end)
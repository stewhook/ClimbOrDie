local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local GearDetails = require(ReplicatedStorage.StaticData.Gear.GearDetails)
local DataManager = require(ServerScriptService.DataStore.DataManager)

local gearBuyRequest: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.BuyItemRequest

-- Track pending gamepass purchases to match them with gear
local pendingGamepassPurchases = {}

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
		pendingGamepassPurchases[player.UserId] = gearID
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

-- Listen for gamepass purchase completion
MarketplaceService.PromptGamePassPurchaseFinished:Connect(
	function(player: Player, gamepassId: number, wasPurchased: boolean)
		if not player then
			return
		end

		-- Check if this player has a pending gamepass purchase
		local pendingGearID = pendingGamepassPurchases[player.UserId]
		if not pendingGearID then
			return
		end

		-- Clear the pending purchase
		pendingGamepassPurchases[player.UserId] = nil

		-- Check if the purchase was successful
		if not wasPurchased then
			print(`[GearPurchase] Player {player.Name} cancelled gamepass purchase for gear: {pendingGearID}`)
			return
		end

		-- Verify the gamepass ID matches what we expected
		local gearDetails = GearDetails[pendingGearID]
		if not gearDetails or gearDetails.GamepassID ~= gamepassId then
			warn(
				`[GearPurchase] Gamepass ID mismatch for player {player.Name}. Expected: {gearDetails and gearDetails.GamepassID or "nil"}, Got: {gamepassId}`
			)
			return
		end

		-- Verify player profile still exists
		local profile = DataManager.verifyProfile(player)
		if not profile then
			warn(`[GearPurchase] Player {player.Name} profile not found after gamepass purchase`)
			return
		end

		-- Grant the gear to the player
		DataManager.adjustInventory(player, pendingGearID, true)
		print(
			`[GearPurchase] Successfully granted gear '{pendingGearID}' to player {player.Name} after gamepass purchase`
		)
	end
)

-- Clean up pending purchases when players leave
game.Players.PlayerRemoving:Connect(function(player: Player)
	if pendingGamepassPurchases[player.UserId] then
		pendingGamepassPurchases[player.UserId] = nil
		print(`[GearPurchase] Cleaned up pending gamepass purchase for leaving player: {player.Name}`)
	end
end)

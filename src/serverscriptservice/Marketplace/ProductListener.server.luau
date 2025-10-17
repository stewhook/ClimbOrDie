local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DevProductFunctions = require(script.Parent.DevProductFunctions)

-- Process receipt function
local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

	-- Check if player is still in the game
	if not player then
		warn(`Player with UserId {receiptInfo.PlayerId} left before purchase could be processed`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Try to process the purchase using DevProductFunctions
	local success, result = pcall(function()
		return DevProductFunctions.Handler(player, receiptInfo.ProductId)
	end)

	if success and result then
		print(`Successfully processed purchase for {player.Name} - ProductId: {receiptInfo.ProductId}`)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn(`Failed to process purchase for {player.Name} - ProductId: {receiptInfo.ProductId}`)
		if not success then
			warn(`Error: {result}`)
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- Set up the callback
MarketplaceService.ProcessReceipt = processReceipt
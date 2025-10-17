local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for required modules and events
local GamepassFunctions = require(script.Parent.GamepassFunctions)
local GamepassKeys = require(ReplicatedStorage.StaticData.GamepassKeys)

-- Get RemoteEvents
local promptGamepassEvent: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Marketplace"):WaitForChild("PromptGamepass")

-- Listen for gamepass prompt requests from other scripts
promptGamepassEvent.OnServerEvent:Connect(function(player: Player, gamepassId: number)
	if not player or not gamepassId or type(gamepassId) ~= "number" then
		warn("Invalid gamepass prompt request from player:", player and player.Name or "Unknown")
		return
	end

	-- Validate that the gamepass ID exists in our handlers
	if not GamepassFunctions[gamepassId] then
		warn("Unknown gamepass ID requested:", gamepassId, "from player:", player.Name)
		return
	end

	-- Prompt the player to purchase the gamepass
	local success, errorMessage = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, gamepassId)
	end)

	if not success then
		warn("Failed to prompt gamepass purchase for player:", player.Name, "Error:", errorMessage)
	end
end)

-- Listen for completed gamepass purchases
local function onGamepassPurchase(player: Player, gamepassId: number)
	if not player or not gamepassId then
		return
	end

	print(player.Name .. " completed purchase for gamepass ID:", gamepassId)

	-- Get the appropriate handler function
	local handlerFunction = GamepassFunctions[gamepassId]
	if handlerFunction then
		-- Execute the handler function
		local success, errorMessage = pcall(handlerFunction, player)
		if not success then
			warn("Error executing gamepass handler for ID:", gamepassId, "Player:", player.Name, "Error:", errorMessage)
		end
	else
		warn("No handler found for gamepass ID:", gamepassId, "from player:", player.Name)
	end
end

-- Connect the MarketplaceService purchase event
MarketplaceService.PromptGamePassPurchaseFinished:Connect(onGamepassPurchase)

-- Optional: Add a function to manually trigger gamepass prompts (for testing or admin use)
local function promptPlayerGamepass(player: Player, gamepassId: number)
	if not player or not gamepassId then
		return false
	end

	if not GamepassFunctions[gamepassId] then
		warn("Unknown gamepass ID:", gamepassId)
		return false
	end

	local success, _ = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, gamepassId)
	end)

	return success
end

print("GamepassPurchaseHandler initialized successfully")

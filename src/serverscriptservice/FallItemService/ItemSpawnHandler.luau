local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local HitboxData = require(script.Parent.HitboxData)
local ServerItemFunctions = require(script.Parent.ServerItemFunctions)
-- Get cached hitbox data from module
local cachedHitboxes = HitboxData.getHitboxes()
local cachedTotalWeight = HitboxData.getTotalWeight()

-- Spawn system state
local spawnSystemState = {
	isRunning = false,
	currentSpawns = 0,
	maxSpawns = 0,
	spawnInterval = 0.25,
	hitboxes = cachedHitboxes,
	totalWeight = cachedTotalWeight,
	customSpawnQueue = {},
}

-- Function to randomly select a hitbox based on weights from a given hitbox list
local function selectWeightedHitbox(hitboxList, totalWeight)
	if not hitboxList or #hitboxList == 0 then
		warn("No hitboxes provided for selection")
		return nil
	end

	-- Generate random number between 0 and totalWeight
	local randomValue = math.random() * totalWeight

	-- Find the selected hitbox
	local currentWeight = 0
	for _, hitbox in pairs(hitboxList) do
		currentWeight = currentWeight + hitbox.weight
		if randomValue <= currentWeight then
			return hitbox.object
		end
	end

	-- Fallback to first hitbox (shouldn't happen)
	return hitboxList[1].object
end

local function retrieveRandomSpawn()
	return workspace.Map.PartSpawns:GetChildren()[math.random(1, #workspace.Map.PartSpawns:GetChildren())]
end

-- Function to spawn hitbox at spawnpoint
local function spawnHitbox(useCustomHitboxList, customHitboxes, customTotalWeight, sender)
	sender = sender or nil
	local hitboxList = useCustomHitboxList and customHitboxes or spawnSystemState.hitboxes
	local totalWeight = useCustomHitboxList and customTotalWeight or spawnSystemState.totalWeight

	local selectedHitbox = selectWeightedHitbox(hitboxList, totalWeight)

	if not selectedHitbox then
		warn("No hitbox selected for spawning")
		return
	end

	-- Clone the hitbox
	local clonedHitbox = selectedHitbox:Clone()

	-- Position it at the spawnpoint
	local spawnPoint = retrieveRandomSpawn()
	if spawnPoint then
		if useCustomHitboxList then
			if sender then
				DataManager.incrementValue(sender, "SentItems", 1)
			end
			clonedHitbox:SetAttribute("Custom", sender.UserId)
		end

		if clonedHitbox:GetAttribute("Function") then
			ServerItemFunctions.Handler(clonedHitbox, clonedHitbox:GetAttribute("Function"))
		end

		clonedHitbox.Transparency = 1
		clonedHitbox.CollisionGroup = "FallPart"
		clonedHitbox.Parent = workspace.FallingParts
		clonedHitbox:PivotTo(spawnPoint.CFrame)
	else
		warn("SpawnPoint not found in workspace")
	end
end

-- Main spawn loop that runs continuously
local function spawnLoop()
	while spawnSystemState.isRunning do
		-- Check for custom spawns in queue first (priority)
		if #spawnSystemState.customSpawnQueue > 0 then
			local customSpawn = table.remove(spawnSystemState.customSpawnQueue, 1)

			-- Conditionally increase max spawns based on the increaseMaxSpawns flag
			if customSpawn.increaseMaxSpawns then
				spawnSystemState.maxSpawns = spawnSystemState.maxSpawns + customSpawn.count
			end

			-- Determine the delay to use for this batch
			local delayToUse = customSpawn.spawnDelay or spawnSystemState.spawnInterval

			-- Spawn all items in this custom spawn batch
			for i = 1, customSpawn.count do
				spawnHitbox(true, customSpawn.hitboxes, customSpawn.totalWeight, customSpawn.sender)

				-- Only increment currentSpawns if this counts toward the limit
				if customSpawn.increaseMaxSpawns then
					spawnSystemState.currentSpawns = spawnSystemState.currentSpawns + 1
				end

				-- Wait between spawns if not the last one
				if i < customSpawn.count then
					task.wait(delayToUse)
				end
			end

			-- Don't wait after custom batch if there are more custom spawns queued
			-- This allows rapid custom spawns to process immediately
			if
				#spawnSystemState.customSpawnQueue == 0
				and spawnSystemState.currentSpawns < spawnSystemState.maxSpawns
			then
				task.wait(spawnSystemState.spawnInterval)
			end
		-- Check if we should do a regular spawn
		elseif spawnSystemState.currentSpawns < spawnSystemState.maxSpawns then
			-- Regular spawn
			spawnHitbox()
			spawnSystemState.currentSpawns = spawnSystemState.currentSpawns + 1

			if spawnSystemState.currentSpawns < spawnSystemState.maxSpawns then
				task.wait(spawnSystemState.spawnInterval)
			end
		else
			-- No more spawns needed and queue is empty, exit loop
			break
		end
	end

	-- Reset state when done
	spawnSystemState.isRunning = false
	spawnSystemState.currentSpawns = 0
	spawnSystemState.maxSpawns = 0
	spawnSystemState.customSpawnQueue = {}
end

-- Start the continuous hitbox spawning system
local function startHitboxSpawnLoop(spawnInterval, totalSpawns, hitboxes, totalWeight)
	if spawnSystemState.isRunning then
		warn("Spawn system is already running")
		return
	end

	-- Configure spawn system
	spawnSystemState.spawnInterval = spawnInterval or 0.25
	spawnSystemState.maxSpawns = totalSpawns or 10
	spawnSystemState.hitboxes = hitboxes or cachedHitboxes
	spawnSystemState.totalWeight = totalWeight or cachedTotalWeight
	spawnSystemState.isRunning = true
	spawnSystemState.currentSpawns = 0
	spawnSystemState.customSpawnQueue = {}

	-- Start the spawn loop
	spawnLoop()
end

-- Stop the spawn system
local function stopHitboxSpawnLoop()
	spawnSystemState.isRunning = false
end

-- Add custom spawns to the queue
-- @param customHitboxes: Table of hitboxes to spawn
-- @param spawnCount: Number of hitboxes to spawn
-- @param customSpawnDelay: Optional delay between spawns (defaults to system interval)
-- @param sender: Player who initiated the spawn
-- @param increaseMaxSpawns: Boolean - if true, increases max spawn count; if false, uses existing slots (defaults to true for backwards compatibility)
local function addCustomSpawns(customHitboxes, spawnCount, customSpawnDelay, sender: Player, increaseMaxSpawns)
	if not spawnSystemState.isRunning then
		warn("Spawn system is not running")
		return
	end

	if not customHitboxes or #customHitboxes == 0 then
		warn("No custom hitboxes provided")
		return
	end

	-- Calculate total weight for custom hitboxes
	local totalWeight = 0
	for _, hitbox in pairs(customHitboxes) do
		totalWeight = totalWeight + (hitbox.weight or 1)
	end

	-- Add to queue
	local customSpawnData = {
		hitboxes = customHitboxes,
		totalWeight = totalWeight,
		count = spawnCount or 1,
		sender = sender,
		increaseMaxSpawns = if increaseMaxSpawns ~= nil then increaseMaxSpawns else true, -- Default to true for backwards compatibility
	}

	-- Add custom spawn delay if provided
	if customSpawnDelay and type(customSpawnDelay) == "number" and customSpawnDelay >= 0 then
		customSpawnData.spawnDelay = customSpawnDelay
	end

	table.insert(spawnSystemState.customSpawnQueue, customSpawnData)
end

-- Get current spawn system status
local function getSpawnSystemStatus()
	return {
		isRunning = spawnSystemState.isRunning,
		currentSpawns = spawnSystemState.currentSpawns,
		maxSpawns = spawnSystemState.maxSpawns,
		spawnInterval = spawnSystemState.spawnInterval,
		queuedCustomSpawns = #spawnSystemState.customSpawnQueue,
	}
end

return {
	StartHitboxSpawnLoop = startHitboxSpawnLoop,
	StopHitboxSpawnLoop = stopHitboxSpawnLoop,
	AddCustomSpawns = addCustomSpawns,
	GetSpawnSystemStatus = getSpawnSystemStatus,
}

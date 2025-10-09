local HitboxData = require(script.Parent.HitboxData)
-- Get cached hitbox data from module
local cachedHitboxes = HitboxData.getHitboxes()
local cachedTotalWeight = HitboxData.getTotalWeight()

print(cachedHitboxes)

-- Function to randomly select a hitbox based on cached weights
local function selectWeightedHitbox()
	if #cachedHitboxes == 0 then
		warn("No hitboxes found with valid Weight attributes")
		return nil
	end

	-- Generate random number between 0 and totalWeight
	local randomValue = math.random() * cachedTotalWeight

	-- Find the selected hitbox
	local currentWeight = 0
	for _, hitbox in pairs(cachedHitboxes) do
		currentWeight = currentWeight + hitbox.weight
		if randomValue <= currentWeight then
			return hitbox.object
		end
	end

	-- Fallback to first hitbox (shouldn't happen)
	return cachedHitboxes[1].object
end

local function retrieveRandomSpawn()
	return workspace.Map.PartSpawns:GetChildren()[math.random(1, #workspace.Map.PartSpawns:GetChildren())]
end

-- Function to spawn hitbox at spawnpoint
local function spawnHitbox()
	local selectedHitbox = selectWeightedHitbox()

	if not selectedHitbox then
		warn("No hitbox selected for spawning")
		return
	end

	-- Clone the hitbox
	local clonedHitbox = selectedHitbox:Clone()

	-- Position it at the spawnpoint
	local spawnPoint = retrieveRandomSpawn()
	if spawnPoint then
		clonedHitbox.Transparency = 1
		clonedHitbox.CollisionGroup = "FallPart"
		clonedHitbox.Parent = workspace.FallingParts
		clonedHitbox:PivotTo(spawnPoint.CFrame)
	else
		warn("SpawnPoint not found in workspace")
	end
end

local function startHitboxSpawnLoop(spawnInterval, totalSpawns, hitboxes, totalWeight)
	spawnInterval = spawnInterval or 0.25 -- seconds between spawns
	totalSpawns = totalSpawns or 10 -- default total spawns if not specified

	for i = 1, totalSpawns do
		spawnHitbox()
		if i < totalSpawns then
			task.wait(spawnInterval)
		end
	end
end

-- Start the hitbox spawning system with cached data
-- Example: startHitboxSpawnLoop(0.25, 5, cachedHitboxes, cachedTotalWeight)
-- startHitboxSpawnLoop(0.25, 10, cachedHitboxes, cachedTotalWeight)

return {
	StartHitboxSpawnLoop = startHitboxSpawnLoop,
}

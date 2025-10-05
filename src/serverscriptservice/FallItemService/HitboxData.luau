-- HitboxData module for managing hitbox information
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local hitboxFolder = ReplicatedStorage.Hitboxes

-- Initialize hitbox data once
local function initializeHitboxes()
	local hitboxes = {}
	local totalWeight = 0

	print("Initializing hitbox system...")
	for _, hitbox in pairs(hitboxFolder:GetChildren()) do
		if hitbox:IsA("Model") or hitbox:IsA("Part") then
			local weightAttribute = hitbox:GetAttribute("Weight")
			if weightAttribute and type(weightAttribute) == "number" and weightAttribute > 0 then
				table.insert(hitboxes, {
					object = hitbox,
					weight = weightAttribute,
				})
				totalWeight = totalWeight + weightAttribute
			end
		end
	end

	print(string.format("Loaded %d hitboxes with total weight of %d", #hitboxes, totalWeight))
	return hitboxes, totalWeight
end

-- Cache hitbox data (initialized once)
local cachedHitboxes, cachedTotalWeight = initializeHitboxes()

-- Module exports
local HitboxData = {}

function HitboxData.getHitboxes()
	return cachedHitboxes
end

function HitboxData.getTotalWeight()
	return cachedTotalWeight
end

function HitboxData.getHitboxCount()
	return #cachedHitboxes
end

return HitboxData

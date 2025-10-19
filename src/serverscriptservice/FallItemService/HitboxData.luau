-- HitboxData module for managing hitbox information
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local hitboxFolder = ReplicatedStorage.Hitboxes

-- Initialize hitbox data once
local function initializeHitboxes()
	local hitboxes = {}
	local totalWeight = 0

	for _, hitbox in pairs(hitboxFolder:GetChildren()) do
		if hitbox:IsA("Model") or hitbox:IsA("Part") or hitbox:IsA("MeshPart") then
			if hitbox:IsA("Model") then
				for _, stuff in hitbox:GetDescendants() do
					if stuff:IsA("BasePart") or stuff:IsA("MeshPart") then
						stuff.Transparency = 0.75
					end
				end
			else
				hitbox.Transparency = 0.75
			end
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

function HitboxData.getHitboxesByType(specialID: string)
	local matchingHitboxes = {}
	for _, hitboxData in ipairs(cachedHitboxes) do
		local specialType = hitboxData.object:GetAttribute("SpecialType")
		if specialID == specialType then
			table.insert(matchingHitboxes, hitboxData)
		end
	end
	return matchingHitboxes
end

return HitboxData

-- local RunService = game:GetService("RunService") -- Reserved for future use

-- Configuration
local MIN_COLLISION_SPEED = 50 -- Minimum velocity magnitude to qualify as a collision (studs/second)
local SPEED_SMOOTHING_FACTOR = 0.7 -- For smoothing velocity calculations

-- Track active objects and their velocity data
local trackedObjects = {}
local collisionCallbacks = {}

-- Function to get the primary part of an object (for Models)
local function getPrimaryPart(object)
	if object:IsA("BasePart") then
		return object
	elseif object:IsA("Model") then
		return object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
	end
	return nil
end

-- Function to get velocity magnitude from an object
local function getVelocityMagnitude(object)
	local primaryPart = getPrimaryPart(object)
	if not primaryPart or not primaryPart:IsA("BasePart") then
		return 0
	end

	-- Get velocity and return its magnitude
	local velocity = primaryPart.Velocity
	return velocity.Magnitude
end

-- Function to cleanup tracking for a specific hitbox
local function cleanupFallConnection(hitbox)
	if trackedObjects[hitbox] then
		if trackedObjects[hitbox].connection then
			trackedObjects[hitbox].connection:Disconnect()
		end
		if trackedObjects[hitbox].ancestryConnection then
			trackedObjects[hitbox].ancestryConnection:Disconnect()
		end
		trackedObjects[hitbox] = nil
		collisionCallbacks[hitbox] = nil
		print("Cleaned up fall collision detection for:", hitbox.Name)
	end
end

-- Function to setup collision detection for a specific hitbox
local function setupFallConnection(hitbox, collisionFunction)
	if not hitbox then
		warn("setupFallConnection: hitbox is nil")
		return
	end

	local primaryPart = getPrimaryPart(hitbox)
	if not primaryPart then
		warn("setupFallConnection: No primary part found for hitbox", hitbox.Name)
		return
	end

	-- Store collision callback for this hitbox
	collisionCallbacks[hitbox] = collisionFunction

	-- Initialize tracking data for this object
	trackedObjects[hitbox] = {
		smoothedSpeed = 0,
		isColliding = false,
		collisionCount = 0,
	}

	-- Connect to the Touched event for collision detection
	local connection
	connection = primaryPart.Touched:Connect(function(hit)
		if hit.CollisionGroup == "Map" then
			return
		end
		local trackedData = trackedObjects[hitbox]
		if not trackedData then
			return
		end

		-- Get current velocity magnitude directly from the object
		local currentSpeed = getVelocityMagnitude(hitbox)

		-- Smooth the speed calculation to avoid spikes
		trackedData.smoothedSpeed = trackedData.smoothedSpeed * SPEED_SMOOTHING_FACTOR
			+ currentSpeed * (1 - SPEED_SMOOTHING_FACTOR)

		-- Check if speed meets collision threshold and we're not already in a collision state
		if trackedData.smoothedSpeed >= MIN_COLLISION_SPEED and not trackedData.isColliding then
			trackedData.isColliding = true

			-- Call the collision function if it exists
			if collisionFunction then
				local success, err = pcall(collisionFunction, hitbox, hit, trackedData.smoothedSpeed)
				if not success then
					warn("Collision function error:", err)
				end
			end

			-- Increment collision count and cleanup after two qualified collisions
			trackedData.collisionCount += 1
			if trackedData.collisionCount >= 1 then
				cleanupFallConnection(hitbox)
				return
			end

			-- Reset collision state after a short delay
			task.wait(0.5)
			trackedData.isColliding = false
		end
	end)

	-- Store the connection for cleanup
	trackedObjects[hitbox].connection = connection

	-- Automatically setup cleanup when hitbox is removed
	local ancestryConnection = hitbox.AncestryChanged:Connect(function()
		if not hitbox.Parent then
			cleanupFallConnection(hitbox)
		end
	end)

	-- Store ancestry connection for cleanup
	trackedObjects[hitbox].ancestryConnection = ancestryConnection
end

return {
	StartFallConnection = setupFallConnection,
}

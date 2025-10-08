-- Client-side collision detector script
local RunService = game:GetService("RunService")

-- local fallingPartsFolder: Folder = workspace.FallingParts -- Not used anymore

-- Configuration
local MIN_DELTA_SPEED = 60 -- Minimum change in velocity magnitude to qualify as a collision (studs/second)
local COLLISION_COOLDOWN = 0.3 -- Seconds to wait before another collision can be triggered for the same object
local HITBOX_LIFETIME = 20 -- Seconds before a tracked hitbox auto-cleans up regardless of collisions

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
-- helper removed (no longer used)

-- Function to cleanup tracking for a specific hitbox
local function cleanupFallConnection(hitbox)
	print("Cleaning up connections for ", hitbox.Name)
	if trackedObjects[hitbox] then
		if trackedObjects[hitbox].connection then
			trackedObjects[hitbox].connection:Disconnect()
		end
		if trackedObjects[hitbox].ancestryConnection then
			trackedObjects[hitbox].ancestryConnection:Disconnect()
		end
		trackedObjects[hitbox] = nil
		collisionCallbacks[hitbox] = nil
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

	-- Use RunService.Heartbeat to detect sudden velocity changes on the client
	local lastVelocity = primaryPart.AssemblyLinearVelocity
	local lastImpactTime = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(_dt)
		local trackedData = trackedObjects[hitbox]
		if not trackedData then
			return
		end

		local currentVelocity = primaryPart.AssemblyLinearVelocity
		local deltaSpeed = (currentVelocity - lastVelocity).Magnitude
		lastVelocity = currentVelocity

		if deltaSpeed >= MIN_DELTA_SPEED then
			local now = time()
			if (now - lastImpactTime) >= COLLISION_COOLDOWN and not trackedData.isColliding then
				trackedData.isColliding = true
				lastImpactTime = now

				if collisionFunction then
					local success, err = pcall(collisionFunction, hitbox, primaryPart, deltaSpeed)
					if not success then
						warn("Collision function error:", err)
					end
				end

				trackedData.collisionCount += 1
				if trackedData.collisionCount >= 2 then
					cleanupFallConnection(hitbox)
					return
				end

				task.delay(COLLISION_COOLDOWN, function()
					if trackedObjects[hitbox] then
						trackedObjects[hitbox].isColliding = false
					end
				end)
			end
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

	-- Auto-cleanup after a configurable lifetime
	task.delay(HITBOX_LIFETIME, function()
		if trackedObjects[hitbox] then
			cleanupFallConnection(hitbox)
		end
	end)
end

-- Loops through a folder and creates connections for pre-existing hitboxes
local function initializeExistingHitboxes(folder: Instance, collisionFunction)
	if not folder or not folder:IsA("Folder") then
		warn("InitializeExistingHitboxes: Invalid folder")
		return
	end
	for _, child in ipairs(folder:GetChildren()) do
		local primary = getPrimaryPart(child)
		if primary then
			print("Setting up detection for", child.Name)
			setupFallConnection(child, collisionFunction)
		end
	end
end

-- Watches a folder for new hitboxes and connects detection for each new one
local function subscribeNewHitboxes(folder: Instance, collisionFunction)
	if not folder or not folder:IsA("Folder") then
		warn("SubscribeNewHitboxes: Invalid folder")
		return nil
	end
	local conn = folder.ChildAdded:Connect(function(child)
		local primary = getPrimaryPart(child)
		if primary then
			print("Setting up detection for", child.Name)
			setupFallConnection(child, collisionFunction)
		end
	end)
	return conn
end

-- Bootstrapping for local player session
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local fallingPartsFolder: Folder = Workspace:WaitForChild("FallingParts")

local function onCollision(hitbox, _part, _deltaSpeed)
	-- Signal impact to other client systems (e.g., ImpactDetection) via attribute
	print("Collision Detected")
	local soundID = hitbox:GetAttribute("SoundID")
	if soundID then
		SoundHandler.PlaySoundAtPart(hitbox:GetAttribute("SoundID"), hitbox)
	end
end

initializeExistingHitboxes(fallingPartsFolder, onCollision)
subscribeNewHitboxes(fallingPartsFolder, onCollision)

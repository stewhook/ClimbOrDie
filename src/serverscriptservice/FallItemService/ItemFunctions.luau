local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local FallItemBalancing = require(ReplicatedStorage.StaticData.FallItemBalancing)

local VFXBurstEvent: RemoteEvent = ReplicatedStorage.Events.RoundManagement.PlayVFXBurst

local function TNTFunction(hitbox)
	local itemID = hitbox:GetAttribute("ID")
	if not itemID then
		return
	end
	local itemBalancing = FallItemBalancing[itemID]
	if not itemBalancing then
		return
	end

	local oParams = OverlapParams.new()
	oParams.CollisionGroup = "DetectPlayers"

	local fuzeSound = nil
	local explodeSound = nil

	local explodeTime = tick() + itemBalancing.FUZE_TIME

	local function startFuzeSound()
		if not hitbox then
			return
		end
		fuzeSound = ReplicatedStorage.Sounds.AreaSounds.ItemEffects.TNT_Fuze:Clone()
		fuzeSound.Parent = hitbox
		fuzeSound:Play()
	end

	local function startExplodeSound()
		if not hitbox then
			return
		end
		if fuzeSound then
			fuzeSound:Stop()
			fuzeSound = nil
		end
		explodeSound = ReplicatedStorage.Sounds.AreaSounds.ItemEffects.TNT_Explode:Clone()
		explodeSound.Parent = hitbox
		explodeSound.PlayOnRemove = true
		explodeSound:Destroy()
	end

	local function ragdoll(targetHumanoid: Humanoid, enabling)
		if enabling then
			targetHumanoid.PlatformStand = true
			targetHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
		else
			targetHumanoid.PlatformStand = false
			targetHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end

	local function applyRandomRotation(targetHRP: BasePart)
		-- Generate random rotational force on each axis
		local randomX = math.random(-100, 100)
		local randomY = math.random(-100, 100)
		local randomZ = math.random(-100, 100)

		-- Apply the random angular velocity
		targetHRP.AssemblyAngularVelocity = Vector3.new(randomX, randomY, randomZ)
	end

	local function applyImpact(directionList)
		for char, direction in directionList do
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp or not humanoid or humanoid.Health <= 0 then
				continue
			end
			ragdoll(humanoid, true)
			hrp.AssemblyLinearVelocity = direction * itemBalancing.EXPLOSION_FORCE
			applyRandomRotation(hrp)
			task.spawn(function()
				task.wait(itemBalancing.GETUP_TIME)
				ragdoll(humanoid, false)
			end)
		end
	end

	local function getLookVector(origin: Vector3, target: Vector3): Vector3
		-- Calculate the direction from origin to target
		local direction = (target - origin)

		-- Return the normalized look vector
		return direction.Unit
	end

	local function buildDirections(hitboxPos: Vector3, charList)
		local directionList = {}
		for char, bool in charList do
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				continue
			end
			directionList[char] = getLookVector(hitboxPos, hrp.Position)
		end
		return directionList
	end

	local function fireVFXBurstSafe(target: Instance?)
		if typeof(target) ~= "Instance" then return end
		-- Must be parented (and ideally under workspace) before we defer
		if not target.Parent then return end
	
		-- Defer one heartbeat so clients have time to receive the new instance
		task.defer(function()
			-- still valid and still in the world?
			if target and target.Parent and target:IsDescendantOf(workspace) then
				VFXBurstEvent:FireAllClients(target)
			end
		end)
	end

	local function getCharsInRadius()
		local charList = Workspace:GetPartBoundsInRadius(hitbox.Position, itemBalancing.EXPLOSION_RADIUS, oParams)
		local filteredList = {}
		for _, part in charList do
			local char = part.Parent
			if not char or filteredList[char] then
				continue
			end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				continue
			end
			filteredList[char] = true
		end
		return filteredList
	end

	local function explodeTNT()
		local explodePos = hitbox.Position
		VFXBurstEvent:FireAllClients(explodePos)
		local charList = getCharsInRadius()
		if next(charList) ~= nil then
			local directionList = buildDirections(explodePos, charList)
			applyImpact(directionList)
		end
		startExplodeSound()
		hitbox:Destroy()
	end

	local waitingFor = true
	local function checkTime(explodeTime: number)
		if tick() >= explodeTime then
			waitingFor = false
			explodeTNT()
			return true
		else
			return false
		end
	end

	startFuzeSound()
	while waitingFor do
		checkTime(explodeTime)
		task.wait(itemBalancing.SCAN_TIME)
	end
end

local functionKey = {
	TNT = TNTFunction,
}

local function handler(hitbox, functionID: string)
	if not functionKey[functionID] then
		return
	end
	functionKey[functionID](hitbox)
end

return {
	Handler = handler,
}

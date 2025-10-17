local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PushBalancing = require(ReplicatedStorage.StaticData.PushBalancing)
local player = Players.LocalPlayer

local connection = nil

local function ragdoll(targetHumanoid: Humanoid, targetHRP: BasePart, enabling)
	if enabling then
		targetHumanoid.PlatformStand = true
		targetHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		targetHumanoid.PlatformStand = false
		targetHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function applyPush(targetHRP: BasePart, pushDirection)
	targetHRP.AssemblyLinearVelocity = pushDirection * PushBalancing.PUSH_FORCE
end

local function getLookVector(origin: BasePart, target: BasePart): Vector3
	-- Calculate the direction from origin to target
	local direction = (target.Position - origin.Position)

	-- Return the normalized look vector
	return direction.Unit
end

local function onPush(char: Model, pusherID)
	if pusherID == 0 then
		return
	end
	if not char or not pusherID then
		return
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then
		return
	end
	local pusher = Players:GetPlayerByUserId(pusherID)
	if not pusher then
		return
	end
	local pushChar = pusher.Character
	if not pushChar then
		return
	end
	local pushHumanoid = pushChar:FindFirstChildOfClass("Humanoid")
	local pushHRP = pushChar:FindFirstChild("HumanoidRootPart")
	if not pushHRP or not pushHumanoid or pushHumanoid.Health <= 0 then
		return
	end
	local pushDirection = getLookVector(pushHRP, hrp)
	ragdoll(humanoid, hrp, true)
	applyPush(hrp, pushDirection)
	task.wait(PushBalancing.TIME_TILL_GETUP)
	ragdoll(humanoid, hrp, false)
end

local function beginPushConnection(char: Model)
	connection = char:GetAttributeChangedSignal("Pushed"):Connect(function()
		onPush(char, char:GetAttribute("Pushed"))
	end)
end

local function clearPushConnection(char)
	if not connection then
		return
	end
	connection:Disconnect()
	connection = nil
end

player.CharacterAdded:Connect(beginPushConnection)
player.CharacterRemoving:Connect(clearPushConnection)

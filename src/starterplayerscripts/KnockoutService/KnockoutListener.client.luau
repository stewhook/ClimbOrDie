local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knockoutEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerManagement"):WaitForChild("PlayerKnockedOut")
local getupEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerManagement"):WaitForChild("ForcePlayerGetup")

local player = Players.LocalPlayer
local humanoid

-- Function to be called when player enters FallingDown state
local function onFallingDown()
	print("[CLIENT] Player has entered the FallingDown state!")
	knockoutEvent:FireServer()
end

-- Function to set up state change detection for a character
local function setupHumanoidStateListener(character)
	humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then
		warn("Humanoid not found in character")
		return
	end

	-- Connect to StateChanged event
	humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.FallingDown then
			onFallingDown()
		end
	end)

	print("Humanoid state listener set up successfully")
end

-- Set up listener for current character if it exists
if player.Character then
	setupHumanoidStateListener(player.Character)
end

-- Set up listener for future character respawns
player.CharacterAdded:Connect(setupHumanoidStateListener)

local function enableCooldown(humanoid: Humanoid)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	task.wait(1)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
end

getupEvent.OnClientEvent:Connect(function()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	print("FORCEFULLY GETTING UP")
	task.spawn(enableCooldown, humanoid)
	humanoid.PlatformStand = false
	humanoid.AutoRotate = true
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end)
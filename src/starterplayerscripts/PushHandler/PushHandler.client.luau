local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassKeys = require(ReplicatedStorage.StaticData.GamepassKeys)
local BasicUtils = require(localPlayer.PlayerScripts.BasicUtilities.BasicUtils)

local pushEvent: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerManagement"):WaitForChild("PushRequest")
local promptGamepass: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Marketplace"):WaitForChild("PromptGamepass")

local connectionIndex = {}

local function establishConnection(char: Model, prompt: ProximityPrompt)
	if not char then
		return
	end
	if not prompt:IsA("ProximityPrompt") then
		return
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then
		return
	end

	local connection = prompt.Triggered:Connect(function(triggerPlayer: Player)
		if triggerPlayer ~= localPlayer then
			return
		end

		local triggerChar = triggerPlayer.Character
		if not triggerChar then
			return
		end

		local triggerHumanoid = triggerChar:FindFirstChildOfClass("Humanoid")
		local triggerHRP = triggerChar:FindFirstChild("HumanoidRootPart")
		if not triggerHumanoid or not triggerHRP or triggerHumanoid.Health <= 0 then
			return
		end

		if BasicUtils.ownsGamepass(GamepassKeys.PushPlayers) then
			pushEvent:FireServer(char)
			-- Play a local push effect or something.
		else
			promptGamepass:FireServer(GamepassKeys.PushPlayers)
		end
	end)
	return connection
end

local function buildPrompt(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	if not char then
		return
	end
	local hrp = char:WaitForChild("HumanoidRootPart", 3)
	if not hrp then
		return
	end

	local promptTemplate = ReplicatedStorage.GeneralUtils.Pushing.PushPrompt
	if not promptTemplate then
		return
	end

	local prompt = promptTemplate:Clone()
	local connection = establishConnection(char, prompt)
	if not connection then
		prompt:Destroy()
		return
	end
	connectionIndex[char] = connection
	prompt.Parent = hrp
end

local function clearPrompt(char: Model)
	if connectionIndex[char] then
		connectionIndex[char]:Disconnect()
		connectionIndex[char] = nil
	end
end

local function initPrompts()
	for _, player in Players:GetPlayers() do
		if localPlayer == player then
			continue
		end
		buildPrompt(player)
		player.CharacterAdded:Connect(function(char)
			buildPrompt(player)
		end)
		player.CharacterRemoving:Connect(clearPrompt)
	end
end

initPrompts()

Players.PlayerAdded:Connect(function(player: Player)
	if localPlayer == player then
		return
	end
	buildPrompt(player)
	player.CharacterAdded:Connect(function(char)
		buildPrompt(player)
	end)
	player.CharacterRemoving:Connect(clearPrompt)
end)

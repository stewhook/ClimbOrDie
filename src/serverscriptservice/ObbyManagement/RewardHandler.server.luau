local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local lobbyFolder = workspace.Lobby
local obbyFinishPart = lobbyFolder.Obby.FinishPad

local cooldowns = {}
local COOLDOWN_TIME = 5

local function grabRandomSpawn()
	local spawnList = lobbyFolder.PlayerSpawns:GetChildren()
	return spawnList[math.random(1, #spawnList)]
end

local function handlePart(part: Instance)
	local reward = obbyFinishPart:GetAttribute("Reward") or 25

	local char = part.Parent
	if not char and not char:IsA("Model") then
		return
	end
	if cooldowns[char] then
		return
	end
	cooldowns[char] = tick() + COOLDOWN_TIME
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid or humanoid.Health <= 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(char)
	DataManager.incrementValue(player, "Coins", reward)
	SoundHandler.PlaySoundAtPart("PLAYERROUNDREWARD", hrp)
	char:PivotTo(grabRandomSpawn().CFrame)
end

obbyFinishPart.Touched:Connect(handlePart)

local function synchronizeCooldowns()
	if next(cooldowns) == nil then
		return
	end
	for char, coolTime in cooldowns do
		if tick() >= coolTime then
			cooldowns[char] = nil
		end
	end
end

while script.Parent do
	synchronizeCooldowns()
	task.wait(0.1)
end
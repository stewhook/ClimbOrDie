local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HitboxData = require(ServerScriptService.FallItemService.HitboxData)
local ItemSpawnHandler = require(ServerScriptService.FallItemService.ItemSpawnHandler)
local DoorHandler = require(script.Parent.DoorHandler)
local GameSettings = require(script.Parent.GameSettings)
local InGamePlayers = require(script.Parent.InGamePlayers)

local deathConnections = {}

local roundInfoFolder = ReplicatedStorage.RoundInfo
local RoundBalancing = require(script.Parent.RoundBalancing)

local roundEvents = ReplicatedStorage.Events.RoundManagement
local startIntermissionEvent: RemoteEvent = roundEvents.StartIntermission

local hitboxes = HitboxData.getHitboxes()
local totalWeight = HitboxData.getTotalWeight()

local mapFolder = workspace.Map

local function checkForMinimumPlayers()
	if #Players:GetChildren() >= GameSettings.MINIMUM_PLAYERS then
		return true
	else
		return false
	end
end

local function addPlayerData(player: Player)
	local dataPayload = true
	InGamePlayers[player] = dataPayload
end

local function removePlayerData(player: Player)
	InGamePlayers[player] = nil
end

local function teleportPlayer(player: Player, locationPart: BasePart)
	if not player then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not humanoid or humanoid.Health <= 0 then
		return
	end
	char:PivotTo(locationPart.CFrame)
end

local function createDeathConnection(player: Player, humanoid: Humanoid)
	local connection = humanoid.Died:Connect(function()
		removePlayerData(player)
	end)
	deathConnections[player] = connection
end

local function removeDeathConnections(player: Player)
	deathConnections[player]:Disconnect()
	deathConnections[player] = nil
end

local function loadGameUI(player: Player) end

local function loadLobbyUI(player: Player) end

local function selectRandomSpawn()
	local spawnFolder = GameSettings.SPAWN_FOLDER
	if not spawnFolder then
		return
	end
end

local function playerJoin(player: Player)
	if not player then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not humanoid or humanoid.Health <= 0 then
		return
	end

	addPlayerData(player)
	createDeathConnection(player, humanoid)
	loadGameUI(player)
	-- add teleport to game spawn
end

local function playerLeave(player: Player)
	removePlayerData(player)
	removeDeathConnections(player)
	loadLobbyUI(player)
	-- add teleport to lobby
end

local function gatherPlayers()
	return Players:GetPlayers() -- add functionality to detect when a player is opting out
end

local function startIntermission(countTime: number?)
	countTime = countTime or GameSettings.INTERMISSION_TIME
	roundInfoFolder.IntermissionTime.Value = GameSettings.INTERMISSION_TIME
	startIntermissionEvent:FireAllClients()
	while roundInfoFolder.IntermissionTime.Value > 0 do
		print(roundInfoFolder.IntermissionTime.Value)
		task.wait(1)
		roundInfoFolder.IntermissionTime.Value -= 1
	end
end

local function resetBarriers()
	for _, folder in mapFolder.Barriers:GetChildren() do
		for _, barrier in folder:GetChildren() do
			barrier.CollisionGroup = "PartBarrier"
		end
	end
end

local function solidifyBarrier(roundNumber: number)
	if not RoundBalancing[roundNumber] then
		return
	end
	for _, barrier in RoundBalancing[roundNumber].BarrierFolder:GetChildren() do
		barrier.CollisionGroup = "SolidPartBarrier"
	end
end

local function startRound(roundNumber: number)
	local roundData = RoundBalancing[roundNumber]
	ItemSpawnHandler.StartHitboxSpawnLoop(roundData.SpawnInterval, roundData.MaxItemSpawn, hitboxes, totalWeight)
	task.wait(2)
end

local function endRound(roundNumber: number)
	print("Ending round " .. roundNumber)
	DoorHandler.CloseDoor(DoorHandler.DoorKey[roundNumber], true)
	DoorHandler.OpenDoor(DoorHandler.DoorKey[roundNumber - 1])
	solidifyBarrier(roundNumber - 1)
	-- function that drops all the stuff etc and clears it out. Must halt the function until everything is clear.
	task.wait(4)
	for _, part in workspace.FallingParts:GetChildren() do
		part:Destroy()
	end
end

local function endGame() end

local function cleanRound()
	for player, data in InGamePlayers do
		InGamePlayers[player] = nil
	end
end

local function setupDoorStart()
	print(DoorHandler.DoorKey)
	for ID, door in DoorHandler.DoorKey do
		if ID == 0 then
			continue
		end
		DoorHandler.OpenDoor(door)
	end
	DoorHandler.CloseDoor(DoorHandler.DoorKey[0], true)
	task.wait(1.5)
end

local function setupMap()
	setupDoorStart()
	resetBarriers()
end

local function lockPlayersInPlace(playerList: { Player })
	for _, player in playerList do
		if not player.Character.HumanoidRootPart then
			continue
		end
		player.Character.HumanoidRootPart.Anchored = true
	end
end

local function unlockPlayers(playerList: { Player })
	for _, player in playerList do
		if not player.Character.HumanoidRootPart then
			continue
		end
		player.Character.HumanoidRootPart.Anchored = false
	end
end

local function startLoop()
	while script.Parent do
		local elligible = checkForMinimumPlayers()
		if elligible then
			break
		end
		task.wait(0.5)
	end

	startIntermission() -- halts with a countdown so players can opt in etc.
	local playerList = gatherPlayers() -- returns a list of all players who are currently opted in.

	setupMap() -- sets up door system, resets lights, etc.
	print("Map has been setup")

	for _, player in playerList do
		playerJoin(player)
	end

	print("Players joined")

	startRound(1) -- round starts. Loop is halted
	endRound(1) -- round ends

	print("Round 1 Done")

	startRound(2) -- round starts. Loop is halted
	endRound(2) -- round ends

	print("Round 2 Done")

	startRound(3) -- round starts. Loop is halted
	endRound(3) -- round ends

	print("Round 3 Done")

	startRound(4) -- round starts. Loop is halted
	endRound(4) -- round ends

	print("Round 4 Done")

	endGame() -- game ends, players teleported away
	print("Game ended")
	cleanRound() -- cleanup player data, remove any potential connections, final stop to ensure a clean slate.
	print("Game Cleaned")
end

while script.Parent do
	startLoop()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local HitboxData = require(ServerScriptService.FallItemService.HitboxData)
local ItemSpawnHandler = require(ServerScriptService.FallItemService.ItemSpawnHandler)
local DoorHandler = require(script.Parent.DoorHandler)
local GameSettings = require(script.Parent.GameSettings)
local InGamePlayers = require(script.Parent.InGamePlayers)

local deathConnections = {}
local IndexUI = {}

local roundInfoFolder = ReplicatedStorage.RoundInfo
local RoundBalancing = require(script.Parent.RoundBalancing)

local roundEvents = ReplicatedStorage.Events.RoundManagement
local startIntermissionEvent: RemoteEvent = roundEvents.StartIntermission
local startRoundEvent: RemoteEvent = roundEvents.StartRound
local gameJoinEvent: RemoteEvent = roundEvents.GameJoin
local gameLeaveEvent: RemoteEvent = roundEvents.GameLeave

local bindableEvents = ReplicatedStorage.Events.BindableEvents
local joinActiveBind: BindableEvent = bindableEvents.JoinActiveGame
local revivePlayerBind: BindableEvent = bindableEvents.RevivePlayer

local hitboxes = HitboxData.getHitboxes()
local totalWeight = HitboxData.getTotalWeight()

local mapFolder = workspace.Map

local function isOptedOut(player)
	local profile = DataManager.verifyProfile(player)
	if not profile then
		return false
	end
	return profile.Data.OptedOut
end

local function checkForMinimumPlayers()
	local elligiblePlayers = 0
	for _, player in Players:GetPlayers() do
		if not isOptedOut(player) then
			print("Player Elligible")
			elligiblePlayers += 1
		end
	end
	if elligiblePlayers >= GameSettings.MINIMUM_PLAYERS then
		return true
	else
		return false
	end
end

local function addPlayerData(player: Player)
	local dataPayload = true -- change this later
	InGamePlayers[player] = dataPayload
end

local function removePlayerData(player: Player)
	InGamePlayers[player] = nil
end

local function removeDeathConnections(player: Player)
	deathConnections[player]:Disconnect()
	deathConnections[player] = nil
end

local function createRoundUI(player: Player)
	if IndexUI[player] then
		return
	end
	if not player then
		return
	end
	local playerGui = player.PlayerGui
	if not playerGui then
		return
	end
	local roundUI = ReplicatedStorage.UIComponents.RoundUtils.RoundGui:Clone()
	IndexUI[player] = roundUI
	roundUI.Parent = playerGui
	return playerGui
end

local function removeRoundUI(player: Player)
	if not player then
		return
	end
	if not IndexUI[player] then
		return
	end
	IndexUI[player]:Destroy()
	IndexUI[player] = nil
end

local function selectRandomSpawn(spawnFolder)
	if not spawnFolder then
		return
	end
	local list = spawnFolder:GetChildren()
	return list[math.random(1, #list)]
end

local function teleportToSpawn(player: Player, spawn: BasePart)
	if not spawn then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp: BasePart = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then
		return
	end
	hrp:PivotTo(spawn.CFrame)
end

local function giveHighlight(player: Player)
	local highlight = ReplicatedStorage.RoundUtils.Highlights.PlayerHighlight

	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then
		return
	end

	local clone = highlight:Clone()
	clone.Parent = char
end

local function removeHighlight(player: Player)
	local char = player.Character
	if not char then
		return
	end

	char:FindFirstChildOfClass("Highlight"):Destroy()
end

local function getSessionData(player: Player)
	return player:FindFirstChild("SessionData")
end

local function addPlayerToCache(player: Player)
	local cacheFolder = ReplicatedStorage.Caches.GamePlayers
	if not player or not cacheFolder then
		return
	end
	if cacheFolder:FindFirstChild(tostring(player.UserId)) then
		return cacheFolder:FindFirstChild(tostring(player.UserId))
	end
	local boolVal = Instance.new("BoolValue")
	boolVal.Name = player.UserId
	boolVal.Value = true
	boolVal.Parent = cacheFolder
	return boolVal
end

local function removePlayerFromCache(player: Player)
	local boolVal = ReplicatedStorage.Caches.GamePlayers:FindFirstChild(tostring(player.UserId))
	if not boolVal then
		return
	end
	boolVal:Destroy()
end

local function playerLeave(player: Player)
	print("Player Leave Function Running")
	gameLeaveEvent:FireClient(player)
	removePlayerData(player)
	removeDeathConnections(player)
	removeHighlight(player)
	teleportToSpawn(player, selectRandomSpawn(GameSettings.LOBBY_SPAWN_FOLDER))
	removeRoundUI(player)
	removePlayerFromCache(player)
	local sessionData = getSessionData(player)
	if sessionData and sessionData:FindFirstChild("InGame") then
		sessionData:FindFirstChild("InGame").Value = false
	end
end

local function createDeathConnection(player: Player, humanoid: Humanoid)
	local connection = humanoid.Died:Connect(function()
		playerLeave(player)
	end)
	deathConnections[player] = connection
end

local function grabCustomSpawn(roundNumber: number)
	for _, spawnPart: Instance in mapFolder.CustomSpawns:GetChildren() do
		local spawnID = spawnPart:GetAttribute("Round")
		if not spawnID then
			continue
		end
		if roundNumber == spawnID then
			return spawnPart
		end
	end
	return nil
end

local function playerJoin(player: Player, customSpawn: boolean?)
	customSpawn = customSpawn or false
	if roundInfoFolder.GameActive.Value ~= true then
		return
	end

	if not player then
		return
	end

	if isOptedOut(player) then
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
	gameJoinEvent:FireClient(player, InGamePlayers[player])
	createDeathConnection(player, humanoid)
	giveHighlight(player)

	local playerSpawn = nil
	if customSpawn then
		playerSpawn = grabCustomSpawn(roundInfoFolder.CurrentRound.Value)
	else
		playerSpawn = selectRandomSpawn(GameSettings.GAME_SPAWN_FOLDER)
	end

	teleportToSpawn(player, playerSpawn)
	addPlayerToCache(player)
	createRoundUI(player)

	local sessionData = getSessionData(player)
	if sessionData and sessionData:FindFirstChild("InGame") then
		sessionData:FindFirstChild("InGame").Value = true
	end
end

local function gatherPlayers()
	local playerList = {}
	for _, player: Player in Players:GetPlayers() do
		if isOptedOut(player) or not player or not player.Character then
			continue
		end
		table.insert(playerList, player)
	end
	return playerList -- add functionality to detect when a player is opting out
end

local function giveReward(player: Player, roundNumber: number)
	local coinAmount = RoundBalancing[roundNumber].CoinReward
	DataManager.incrementValue(player, "Coins", coinAmount)

	local char = player.Character
	if not char then
		return
	end

	char:SetAttribute("RoundReward", coinAmount)
end

local function rewardSequence(roundNumber: number)
	task.wait(1)

	if not RoundBalancing[roundNumber] then
		return
	end
	for player, data in InGamePlayers do
		giveReward(player, roundNumber)
	end

	task.wait(2)
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

local oParams = OverlapParams.new()
oParams.CollisionGroup = "DetectPlayers"
local function retrieveCharInParts(folder: Instance)
	local found = {}
	local charList = {}
	for _, barrier in folder:GetChildren() do
		local list = Workspace:GetPartsInPart(barrier, oParams)
		for _, item in list do
			if item.Name == "HumanoidRootPart" and item.Parent:IsA("Model") then
				if found[item.Parent] then
					continue
				end
				found[item.Parent] = true
				table.insert(charList, item.Parent)
			end
		end
	end
	return charList
end

local function solidifyBarrier(roundNumber: number)
	if not RoundBalancing[roundNumber] then
		return
	end
	for _, barrier in RoundBalancing[roundNumber].BarrierFolder:GetChildren() do
		barrier.CollisionGroup = "SolidPartBarrier"
	end
	local foundChars = retrieveCharInParts(RoundBalancing[roundNumber].BarrierFolder)
	if next(foundChars) ~= nil then
		for _, char in foundChars do
			char:PivotTo(GameSettings.DROP_SPOT.CFrame)
		end
	end
end

local function startRound(roundNumber: number)
	local roundData = RoundBalancing[roundNumber]
	if not roundData then
		return
	end

	roundInfoFolder.RoundActive.Value = true
	roundInfoFolder.CurrentRound.Value = roundNumber

	local setupData = {
		SongChoice = math.random(1, #SoundService.InGame.RoundMusic:GetChildren()),
	}

	for player, data in InGamePlayers do
		startRoundEvent:FireClient(player, roundNumber, setupData)
	end
	ItemSpawnHandler.StartHitboxSpawnLoop(roundData.SpawnInterval, roundData.MaxItemSpawn, hitboxes, totalWeight)
	task.wait(2)
end

local function startWarning()
	print("Warning seequnce started.")
	roundInfoFolder.WarningSequence.Value = true
	task.wait(3)
	roundInfoFolder.WarningSequence.Value = false
end

local function endRound(roundNumber: number)
	print("Ending round " .. roundNumber)
	roundInfoFolder.RoundActive.Value = false
	startWarning()
	solidifyBarrier(roundNumber - 1)
	DoorHandler.OpenDoor(DoorHandler.DoorKey[roundNumber - 1], true)
	task.wait(4)
	DoorHandler.CloseDoor(DoorHandler.DoorKey[roundNumber], true)
	for _, part in workspace.FallingParts:GetChildren() do
		part:Destroy()
	end
end

local function resetRoundInfo()
	roundInfoFolder.RoundActive.Value = false
	roundInfoFolder.CurrentRound.Value = 0
end

local function cleanGame()
	resetRoundInfo()

	for player, data in InGamePlayers do
		InGamePlayers[player] = nil
	end
end

local function endGame()
	roundInfoFolder.GameActive.Value = false
	for player, data in InGamePlayers do
		DataManager.incrementValue(player, "Wins", 1)
		playerLeave(player)
	end
	cleanGame() -- cleanup player data, remove any potential connections, final stop to ensure a clean slate, reset round info.
end

local function setupDoorStart()
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

local function initRoundInfo()
	roundInfoFolder.MaxRounds.Value = GameSettings.ROUND_COUNT
end

local function startGame(playerList)
	initRoundInfo()
	roundInfoFolder.GameActive.Value = true
	for _, player in playerList do
		playerJoin(player)
	end
end

local function checkToContinue()
	local index = 0
	for player, data in InGamePlayers do
		index += 1
	end

	if index <= 0 then
		endGame()
		return false
	else
		return true
	end
end

setupMap()
local function startLoop()
	while script.Parent do
		if checkForMinimumPlayers() then
			break
		end
		task.wait(0.5)
	end

	startIntermission() -- halts with a countdown so players can opt in etc.
	local playerList = gatherPlayers() -- returns a list of all players who are currently opted in.

	if #playerList < GameSettings.MINIMUM_PLAYERS then
		return
	end

	setupMap() -- sets up door system, resets lights, etc.

	startGame(playerList) -- teleports players in and runs init functions for them.

	startRound(1) -- round starts. Loop is halted
	endRound(1) -- round ends
	rewardSequence(1)

	if checkToContinue() == false then
		return
	end

	startRound(2) -- round starts. Loop is halted
	endRound(2) -- round ends
	rewardSequence(2)

	if checkToContinue() == false then
		return
	end

	startRound(3) -- round starts. Loop is halted
	endRound(3) -- round ends
	rewardSequence(3)

	if checkToContinue() == false then
		return
	end

	startRound(4) -- round starts. Loop is halted
	endRound(4) -- round ends
	rewardSequence(4)

	endGame() -- game ends, players teleported away
end

joinActiveBind.Event:Connect(function(player: Player)
	if roundInfoFolder.GameActive.Value ~= true then
		return
	end
	playerJoin(player, true)
end)

while script.Parent do
	startLoop()
end

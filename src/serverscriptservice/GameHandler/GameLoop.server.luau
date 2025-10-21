local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local GearBalancing = require(ReplicatedStorage.StaticData.Gear.GearBalancing)
local GearDetails = require(ReplicatedStorage.StaticData.Gear.GearDetails)
local BuildPlayerData = require(script.Parent.BuildPlayerData)
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
local playerEvents = ReplicatedStorage.Events.PlayerManagement
local startIntermissionEvent: RemoteEvent = roundEvents.StartIntermission
local startRoundEvent: RemoteEvent = roundEvents.StartRound
local gameJoinEvent: RemoteEvent = roundEvents.GameJoin
local gameLeaveEvent: RemoteEvent = roundEvents.GameLeave
local joinActiveEvent: RemoteEvent = roundEvents.JoinActiveGame

local bindableEvents = ReplicatedStorage.Events.BindableEvents
local revivePlayerBind: BindableEvent = bindableEvents.RevivePlayer

local hitboxes = HitboxData.getHitboxes()
local totalWeight = HitboxData.getTotalWeight()

local mapFolder = workspace.Map

local function isOptedOut(player)
	local profile = DataManager.verifyProfile(player)
	if not profile then
		warn(`[GameLoop] isOptedOut: No profile for {player and player.Name or "nil player"}`)
		return false
	end
	local opted = profile.Data.OptedOut
	print(`[GameLoop] isOptedOut: {player.Name} optedOut={opted}`)
	return opted
end

local function checkForMinimumPlayers()
	local elligiblePlayers = 0
	for _, player in Players:GetPlayers() do
		if not isOptedOut(player) then
			elligiblePlayers += 1
		end
	end
	if elligiblePlayers >= GameSettings.MINIMUM_PLAYERS then
		print(`[GameLoop] checkForMinimumPlayers: {elligiblePlayers}>={GameSettings.MINIMUM_PLAYERS} => true`)
		return true
	else
		print(`[GameLoop] checkForMinimumPlayers: {elligiblePlayers}<{GameSettings.MINIMUM_PLAYERS} => false`)
		return false
	end
end

local function getEquippedGear(player: Player)
	local gearCache = player:FindFirstChild("ItemCache")
	if not gearCache then
		warn(`[GameLoop] getEquippedGear: ItemCache not found for {player.Name}`)
		return nil
	end
	for _, obj in gearCache:GetChildren() do
		if obj.Value == true then
			print(`[GameLoop] getEquippedGear: {player.Name} equipped {obj.Name}`)
			return obj.Name
		end
	end
	print(`[GameLoop] getEquippedGear: {player.Name} has no equipped gear`)
	return nil
end

local function addPlayerData(player: Player)
	local equippedGear = getEquippedGear(player)
	print(
		`[GameLoop] Adding player data for {player.Name} (UserId: {player.UserId}) with gear: {equippedGear or "None"}`
	)
	InGamePlayers[player] = BuildPlayerData.BuildData(player, equippedGear)
end

local function removePlayerData(player: Player)
	print(`[GameLoop] Removing player data for {player.Name} (UserId: {player.UserId})`)
	InGamePlayers[player] = nil
end

local function grabPlayerTag(hrp: BasePart)
	local tag = hrp:FindFirstChildOfClass("BillboardGui")
	if not tag then
		warn("[GameLoop] grabPlayerTag: BillboardGui not found on HRP")
	end
	return tag
end

local function createGearImage(player: Player)
	if not player then
		warn("[GameLoop] createGearImage: player is nil")
		return
	end
	local playerData = InGamePlayers[player]
	if not playerData then
		warn(`[GameLoop] createGearImage: No InGamePlayers data for {player.Name}`)
		return
	end
	local equipped = playerData.EquippedGear
	if not equipped then
		print(`[GameLoop] createGearImage: {player.Name} has no equipped gear`)
		return
	end
	local char = player.Character
	if not char then
		warn(`[GameLoop] createGearImage: {player.Name} has no character`)
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		warn(`[GameLoop] createGearImage: {player.Name} has no HumanoidRootPart`)
		return
	end
	local tag = grabPlayerTag(hrp)
	if not tag then
		return
	end
	tag.BaseFrame.GearImageFrame.GearImage.Image = GearDetails[equipped].Image
	tag.BaseFrame.GearImageFrame.Visible = true
	print(`[GameLoop] createGearImage: Set gear image for {player.Name} to {equipped}`)
end

local function removeGearImage(player: Player)
	if not player then
		warn("[GameLoop] removeGearImage: player is nil")
		return
	end
	local char = player.Character
	if not char then
		warn(`[GameLoop] removeGearImage: {player.Name} has no character`)
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		warn(`[GameLoop] removeGearImage: {player.Name} has no HumanoidRootPart`)
		return
	end
	local tag = grabPlayerTag(hrp)
	if tag then
		tag.BaseFrame.GearImageFrame.Visible = false
		print(`[GameLoop] removeGearImage: Hid gear image for {player.Name}`)
	end
end

local function startGearFunctions(player: Player)
	local gameData = InGamePlayers[player]
	if not gameData then
		warn(`[GameLoop] startGearFunctions: No InGamePlayers data for {player.Name}`)
		return
	end
	local startFunction = gameData.StartFunction
	if startFunction then
		print(`[GameLoop] startGearFunctions: Executing StartFunction for {player.Name}`)
		startFunction(player)
	else
		print(`[GameLoop] startGearFunctions: No StartFunction for {player.Name}`)
	end
	createGearImage(player)
end

local function endGearFunctions(player: Player)
	local gameData = InGamePlayers[player]
	if not gameData then
		warn(`[GameLoop] endGearFunctions: No InGamePlayers data for {player.Name}`)
		return
	end
	local endFunction = gameData.EndFunction
	if endFunction then
		print(`[GameLoop] endGearFunctions: Executing EndFunction for {player.Name}`)
		endFunction(player)
	else
		print(`[GameLoop] endGearFunctions: No EndFunction for {player.Name}`)
	end
	removeGearImage(player)
end

local function removeDeathConnections(player: Player)
	if deathConnections[player] then
		deathConnections[player]:Disconnect()
		deathConnections[player] = nil
	end
end

local function createRoundUI(player: Player)
	if IndexUI[player] then
		print(`[GameLoop] createRoundUI: UI already exists for {player.Name}`)
		return
	end
	if not player then
		warn("[GameLoop] createRoundUI: player is nil")
		return
	end
	local playerGui = player.PlayerGui
	if not playerGui then
		warn(`[GameLoop] createRoundUI: {player.Name} has no PlayerGui`)
		return
	end
	local roundUI = ReplicatedStorage.UIComponents.RoundUtils.RoundGui:Clone()
	IndexUI[player] = roundUI
	roundUI.Parent = playerGui
	print(`[GameLoop] createRoundUI: Attached round UI to {player.Name}`)
	return playerGui
end

local function removeRoundUI(player: Player)
	if not player then
		warn("[GameLoop] removeRoundUI: player is nil")
		return
	end
	if not IndexUI[player] then
		print(`[GameLoop] removeRoundUI: No UI to remove for {player.Name}`)
		return
	end
	IndexUI[player]:Destroy()
	IndexUI[player] = nil
	print(`[GameLoop] removeRoundUI: Removed UI for {player.Name}`)
end

local function selectRandomSpawn(spawnFolder)
	if not spawnFolder then
		warn("[GameLoop] selectRandomSpawn: spawnFolder is nil")
		return
	end
	local list = spawnFolder:GetChildren()
	if #list == 0 then
		warn("[GameLoop] selectRandomSpawn: spawnFolder has no children")
		return nil
	end
	local chosen = list[math.random(1, #list)]
	print(`[GameLoop] selectRandomSpawn: Chose spawn '{chosen.Name}' from folder '{spawnFolder.Name}'`)
	return chosen
end

local function teleportToSpawn(player: Player, spawn: BasePart)
	if not spawn then
		warn(`[GameLoop] teleportToSpawn: spawn is nil for {player and player.Name or "nil player"}`)
		return
	end
	local char = player.Character
	if not char then
		warn(`[GameLoop] teleportToSpawn: {player.Name} has no character`)
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp: BasePart = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then
		warn(
			`[GameLoop] teleportToSpawn: Missing HRP/Humanoid or dead for {player.Name} (humanoid={humanoid ~= nil}, hrp={hrp ~= nil}, health={humanoid and humanoid.Health or "N/A"})`
		)
		return
	end
	hrp:PivotTo(spawn.CFrame)
	print(`[GameLoop] teleportToSpawn: Teleported {player.Name} to {spawn.Name}`)
end

local function giveHighlight(player: Player)
	local highlight = ReplicatedStorage.RoundUtils.Highlights.PlayerHighlight

	local char = player.Character
	if not char then
		warn(`[GameLoop] giveHighlight: {player.Name} has no character`)
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then
		warn(`[GameLoop] giveHighlight: Missing HRP/Humanoid or dead for {player.Name}`)
		return
	end

	local clone = highlight:Clone()
	clone.Parent = char
	print(`[GameLoop] giveHighlight: Added highlight to {player.Name}`)
end

local function removeHighlight(player: Player)
	local char = player.Character
	if not char then
		warn(`[GameLoop] removeHighlight: {player.Name} has no character`)
		return
	end

	local playerHighlight = char:FindFirstChildOfClass("Highlight")
	if playerHighlight then
		playerHighlight:Destroy()
		print(`[GameLoop] removeHighlight: Removed highlight from {player.Name}`)
	else
		print(`[GameLoop] removeHighlight: No highlight to remove for {player.Name}`)
	end
end

local function getSessionData(player: Player)
	return player:FindFirstChild("SessionData")
end

local function addPlayerToCache(player: Player)
	local cacheFolder = ReplicatedStorage.Caches.GamePlayers
	if not player or not cacheFolder then
		warn("[GameLoop] addPlayerToCache: player or cacheFolder is nil")
		return
	end
	if cacheFolder:FindFirstChild(tostring(player.UserId)) then
		print(`[GameLoop] addPlayerToCache: Entry already exists for {player.Name}`)
		return cacheFolder:FindFirstChild(tostring(player.UserId))
	end
	local boolVal = Instance.new("BoolValue")
	boolVal.Name = player.UserId
	boolVal.Value = true
	boolVal.Parent = cacheFolder
	print(`[GameLoop] addPlayerToCache: Created cache entry for {player.Name}`)
	return boolVal
end

local function removePlayerFromCache(player: Player)
	local boolVal = ReplicatedStorage.Caches.GamePlayers:FindFirstChild(tostring(player.UserId))
	if not boolVal then
		print(`[GameLoop] removePlayerFromCache: No cache entry for {player.Name}`)
		return
	end
	boolVal:Destroy()
	print(`[GameLoop] removePlayerFromCache: Removed cache entry for {player.Name}`)
end

local function playerLeave(player: Player)
	print(`[GameLoop] Player leaving game: {player.Name} (UserId: {player.UserId})`)
	task.spawn(function()
		local sendData = InGamePlayers[player]
		if sendData.EndFunction then
			sendData.EndFunction = nil
		end
		if sendData.StartFunction then
			sendData.StartFunction = nil
		end
		gameLeaveEvent:FireClient(player, InGamePlayers[player])
	end)
	removeDeathConnections(player)
	removeHighlight(player)
	endGearFunctions(player)
	teleportToSpawn(player, selectRandomSpawn(GameSettings.LOBBY_SPAWN_FOLDER))
	removeRoundUI(player)
	removePlayerFromCache(player)
	removePlayerData(player)
	local sessionData = getSessionData(player)
	if sessionData and sessionData:FindFirstChild("InGame") then
		sessionData:FindFirstChild("InGame").Value = false
	end
	print(`[GameLoop] Player {player.Name} successfully left game`)
end

local function createDeathConnection(player: Player, humanoid: Humanoid)
	local connection = humanoid.Died:Connect(function()
		print(`[GameLoop] Player {player.Name} died, triggering playerLeave`)
		playerLeave(player)
		player:SetAttribute("Died", Workspace:GetServerTimeNow())
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
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

local activeSong = nil
local function playerJoin(player: Player, customSpawn: boolean?)
	customSpawn = customSpawn or false
	print(`[GameLoop] Attempting to join player: {player.Name} (UserId: {player.UserId}), CustomSpawn: {customSpawn}`)

	if roundInfoFolder.GameActive.Value ~= true then
		print(`[GameLoop] Player {player.Name} join FAILED: Game not active`)
		return
	end

	if not player then
		print(`[GameLoop] Player join FAILED: Player is nil`)
		return
	end

	if isOptedOut(player) and not customSpawn then
		print(`[GameLoop] Player {player.Name} join FAILED: Player opted out`)
		return
	end

	local char = player.Character
	if not char then
		print(`[GameLoop] Player {player.Name} join FAILED: No character`)
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp or not humanoid or humanoid.Health <= 0 then
		print(
			`[GameLoop] Player {player.Name} join FAILED: Missing humanoid/HRP or dead (Health: {humanoid and humanoid.Health or "N/A"})`
		)
		return
	end

	addPlayerData(player)
	task.spawn(function()
		gameJoinEvent:FireClient(player, InGamePlayers[player])
	end)
	createDeathConnection(player, humanoid)
	giveHighlight(player)

	local playerSpawn = nil
	if customSpawn then
		print(`[GameLoop] Player {player.Name} joining with custom spawn (Round {roundInfoFolder.CurrentRound.Value})`)
		if activeSong then
			playerEvents.PlaySongByIndex:FireClient(player, activeSong)
		end
		playerSpawn = grabCustomSpawn(roundInfoFolder.CurrentRound.Value)
	else
		print(`[GameLoop] Player {player.Name} joining with regular spawn`)
		playerSpawn = selectRandomSpawn(GameSettings.GAME_SPAWN_FOLDER)
	end

	startGearFunctions(player)
	teleportToSpawn(player, playerSpawn)
	addPlayerToCache(player)
	createRoundUI(player)

	local sessionData = getSessionData(player)
	if sessionData and sessionData:FindFirstChild("InGame") then
		sessionData:FindFirstChild("InGame").Value = true
	end

	print(`[GameLoop] Player {player.Name} successfully joined game`)
end

local function gatherPlayers()
	local playerList = {}
	for _, player: Player in Players:GetPlayers() do
		if isOptedOut(player) or not player or not player.Character then
			continue
		end
		table.insert(playerList, player)
	end
	print(`[GameLoop] Gathered {#playerList} eligible players for game start`)
	return playerList -- add functionality to detect when a player is opting out
end

local function giveReward(player: Player, roundNumber: number)
	local playerData = InGamePlayers[player]
	if not playerData then
		return
	end
	local coinAmount
	if playerData.EquippedGear == "PiggyBank" then
		coinAmount = math.round(RoundBalancing[roundNumber].CoinReward * GearBalancing.PiggyBank.MoneyMultiplier)
	else
		coinAmount = RoundBalancing[roundNumber].CoinReward
	end
	print(coinAmount)
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
	activeSong = setupData.SongChoice
	for player, data in InGamePlayers do
		if InGamePlayers[player] then
			startRoundEvent:FireClient(player, roundNumber, setupData)
		end
	end
	ItemSpawnHandler.StartHitboxSpawnLoop(roundData.SpawnInterval, roundData.MaxItemSpawn, hitboxes, totalWeight)
	task.wait(2)
end

local function startWarning()
	roundInfoFolder.WarningSequence.Value = true
	task.wait(3)
	roundInfoFolder.WarningSequence.Value = false
end

local function endRound(roundNumber: number)
	roundInfoFolder.RoundActive.Value = false
	activeSong = nil
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
	print(`[GameLoop] Ending game`)
	roundInfoFolder.GameActive.Value = false
	local playerCount = 0
	for player, data in InGamePlayers do
		playerCount += 1
		DataManager.incrementValue(player, "Wins", 1)
		playerLeave(player)
	end
	print(`[GameLoop] Game ended, processed {playerCount} winning players`)
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
	print(`[GameLoop] Starting game with {#playerList} players`)
	initRoundInfo()
	roundInfoFolder.GameActive.Value = true
	for _, player in playerList do
		playerJoin(player)
	end
	print(`[GameLoop] Game start complete`)
end

local function checkToContinue()
	local index = 0
	for player, data in InGamePlayers do
		index += 1
	end

	print(`[GameLoop] CheckToContinue: {index} players remaining in game`)

	if index <= 0 then
		print(`[GameLoop] No players remaining, ending game`)
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

joinActiveEvent.OnServerEvent:Connect(function(player: Player)
	print(`[GameLoop] JoinActiveEvent received from {player.Name}`)
	if roundInfoFolder.GameActive.Value ~= true then
		print(`[GameLoop] JoinActive FAILED for {player.Name}: Game not active`)
		return
	end
	local profile = DataManager.verifyProfile(player)
	if not profile then
		print(`[GameLoop] JoinActive FAILED for {player.Name}: No profile`)
		return
	end

	if profile.Data.HasJoinActive == true then
		print(`[GameLoop] JoinActive SUCCESS for {player.Name}: HasJoinActive is true`)
		DataManager.setValue(player, "HasJoinActive", false)
		playerJoin(player, true)
	else
		print(`[GameLoop] JoinActive SKIPPED for {player.Name}: HasJoinActive is false`)
	end
end)

revivePlayerBind.Event:Connect(function(player: Player)
	print(`[GameLoop] RevivePlayer event received for {player.Name}`)
	if roundInfoFolder.GameActive.Value ~= true then
		print(`[GameLoop] Revive FAILED for {player.Name}: Game not active`)
		return
	end

	playerJoin(player, true)
end)

while script.Parent do
	startLoop()
end

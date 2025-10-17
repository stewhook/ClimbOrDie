local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local index = {}

local function addPlayer(player: Player)
	index[player] = true
end

local function removePlayer(player: Player)
	index[player] = nil
end

local function setSessionTime(player: Player, time: number)
	DataManager.setValue(player, "SessionTime", time)
	DataManager.updateCache(player, "SessionTime", time)
end

local function synchronizePlayerTimes(time)
	for player, _ in pairs(index) do
		setSessionTime(player, time)
	end
end

Players.PlayerRemoving:Connect(removePlayer)

local loopStarted = false
local function startSyncLoop()
	if loopStarted then
		return
	end
	loopStarted = true
	task.spawn(function()
		while true do
			local now = os.time()
			synchronizePlayerTimes(now)
			task.wait(1)
		end
	end)
end

startSyncLoop()

return {
	AddPlayer = addPlayer,
}

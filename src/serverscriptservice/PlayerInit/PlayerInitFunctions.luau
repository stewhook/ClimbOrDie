local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local module = {}

local settingsInitEvent: RemoteEvent = ReplicatedStorage.Events.Settings.SettingsInit
function module.createSettingsCache(player: Player)
	local index = 0
	local max = 50
	while not DataManager.verifyProfile(player) do
		if DataManager.verifyProfile(player) then
			break
		end
		if index > max then
			return
		end
		index += 1
		task.wait(0.1)
	end
	local profile = DataManager.verifyProfile(player)
	settingsInitEvent:FireClient(player, profile.Data.Settings)
end

return module

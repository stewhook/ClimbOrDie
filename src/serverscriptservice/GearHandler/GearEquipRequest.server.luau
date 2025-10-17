local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local equipItemEvent: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.EquipItemRequest

equipItemEvent.OnServerEvent:Connect(function(player: Player, gearID: string)
	if not player then
		return
	end

	local playerOwns = DataManager.verifyItemOwnership(player, gearID)
	if not playerOwns then
		return
	end

	DataManager.equipItem(player, gearID)
end)
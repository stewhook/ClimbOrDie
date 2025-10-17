local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local GamepassKeys = require(ReplicatedStorage.StaticData.GamepassKeys)
local module = {}

module[GamepassKeys.GoldenShield] = function(player: Player)
    DataManager.adjustInventory(player, "GoldenShield", true)
end

module[GamepassKeys.PushPlayers] = function(player: Player)
    print("Push Player Gamepass Ran")
end

return module
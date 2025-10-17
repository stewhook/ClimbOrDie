local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupDataCache = require(script.Parent.GroupDataCache)

local groupDataSend: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.GroupDataSend

local function createCache(player: Player, groupRank: number)
    GroupDataCache.Cache[player] = groupRank
end

local function removeCache(player: Player)
    GroupDataCache.Cache[player] = nil
end

groupDataSend.OnServerEvent:Connect(createCache)

Players.PlayerRemoving:Connect(removeCache)
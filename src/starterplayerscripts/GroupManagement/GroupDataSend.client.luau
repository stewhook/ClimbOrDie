local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalGroupCache = require(script.Parent.LocalGroupCache)
local GlobalStuff = require(ReplicatedStorage.StaticData.GlobalStuff)
local player = Players.LocalPlayer

local dataSendEvent: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerManagement"):WaitForChild("GroupDataSend")

local rank = player:GetRankInGroup(GlobalStuff.GROUP_ID)

if rank > 0 then
	LocalGroupCache[player] = rank
end
dataSendEvent:FireServer(rank)

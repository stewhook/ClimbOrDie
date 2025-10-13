local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalStuff = require(ReplicatedStorage.StaticData.GlobalStuff)
local player = Players.LocalPlayer

local dataSendEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerManagement"):WaitForChild("GroupDataSend")

local rank = player:GetRankInGroup(GlobalStuff.GROUP_ID)

dataSendEvent:FireServer(rank)
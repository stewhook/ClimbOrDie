local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundMusicHandler = require(script.Parent.RoundMusicHandler)

local roundEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement")
local playerEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerManagement")
local startRoundEvent: RemoteEvent = roundEvents:WaitForChild("StartRound")
local playSongByIndexEvent: RemoteEvent = playerEvents:WaitForChild("PlaySongByIndex")

startRoundEvent.OnClientEvent:Connect(function(roundNumuber: number, payload)
	if not payload then
		return
	end
	RoundMusicHandler.Init(payload.SongChoice)
end)

playSongByIndexEvent.OnClientEvent:Connect(function(index)
	RoundMusicHandler.Init(index)
end)
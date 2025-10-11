local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundMusicHandler = require(script.Parent.RoundMusicHandler)

local roundEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement")
local startRoundEvent: RemoteEvent = roundEvents:WaitForChild("StartRound")

startRoundEvent.OnClientEvent:Connect(function(roundNumuber: number, payload)
	if not payload then
		return
	end
	RoundMusicHandler.Init(payload.SongChoice)
end)

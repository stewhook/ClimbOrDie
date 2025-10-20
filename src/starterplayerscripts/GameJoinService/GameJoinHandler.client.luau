local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local GearFunctions = require(StarterPlayer.StarterPlayerScripts.GearManagement.GearFunctions)
local RoundMusicHandler = require(player.PlayerScripts.RoundStartService.RoundMusicHandler)
local GameJoinFunctions = require(script.Parent.GameJoinFunctions)

local gameJoinEvent: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement"):WaitForChild("GameJoin")
local gameLeaveEvent: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement"):WaitForChild("GameLeave")

gameJoinEvent.OnClientEvent:Connect(function(payload)
	payload = payload or nil
	GameJoinFunctions.beginAlertListener()
	GameJoinFunctions.clearLobbyUI()
	GearFunctions.Start(payload.EquippedGear)
end)

gameLeaveEvent.OnClientEvent:Connect(function(payload)
	payload = payload or nil
	GameJoinFunctions.closeAlertListener()
	RoundMusicHandler.CancelMusic()
	GameJoinFunctions.initLobbyUI()
	GearFunctions.End(payload.EquippedGear)
end)
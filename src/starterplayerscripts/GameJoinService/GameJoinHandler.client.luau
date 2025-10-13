local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundMusicHandler = require(player.PlayerScripts.RoundStartService.RoundMusicHandler)
local GameJoinFunctions = require(script.Parent.GameJoinFunctions)

local gameJoinEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement"):WaitForChild("GameJoin")
local gameLeaveEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement"):WaitForChild("GameLeave")

gameJoinEvent.OnClientEvent:Connect(function(payload)
    GameJoinFunctions.beginAlertListener()
    GameJoinFunctions.initGameUI()
end)

gameLeaveEvent.OnClientEvent:Connect(function()
    GameJoinFunctions.closeAlertListener()
    RoundMusicHandler.CancelMusic()
    GameJoinFunctions.initLobbyUI()
end)

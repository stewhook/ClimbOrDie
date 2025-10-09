local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameJoinFunctions = require(script.Parent.GameJoinFunctions)

local gameJoinEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement"):WaitForChild("GameJoin")
local gameLeaveEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement"):WaitForChild("GameLeave")

gameJoinEvent.OnClientEvent:Connect(function(payload)
    GameJoinFunctions.beginAlertListener()
end)

gameLeaveEvent.OnClientEvent:Connect(function()
    GameJoinFunctions.closeAlertListener()
end)

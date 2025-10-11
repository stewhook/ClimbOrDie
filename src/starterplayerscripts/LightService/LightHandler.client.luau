local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LightManagement = require(script.Parent.LightManagement)

local warningSequence = ReplicatedStorage:WaitForChild("RoundInfo"):WaitForChild("WarningSequence")

local conn = warningSequence:GetPropertyChangedSignal("Value"):Connect(function()
    local value = warningSequence.Value
    if value == true then
        LightManagement.StartWarning()
    else
        LightManagement.StopWarning()
    end
end)
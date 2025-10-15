local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReviveFunctions = require(script.Parent.ReviveFunctions)
local BasicUtils = require(StarterPlayer.StarterPlayerScripts.BasicUtilities.BasicUtils)
local player = Players.LocalPlayer

player.CharacterAdded:Connect(function(char)
    local lastDeath = player:GetAttribute("Died")
    if not lastDeath or lastDeath > BasicUtils.GetServerTime() then return end

    ReviveFunctions.createPopup()
end)

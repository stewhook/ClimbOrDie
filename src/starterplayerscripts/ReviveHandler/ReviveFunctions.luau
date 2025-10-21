local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local module = {}

function module.createPopup()
	local isPopup = player.PlayerGui:FindFirstChild("RevivePopup")
	if isPopup then return end
	local revivePopup = ReplicatedStorage.UIComponents.Utils.Revive.RevivePopup:Clone()
	revivePopup.Parent = player.PlayerGui
end

return module

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local module = {}

module.ActivePopup = false

function module.createPopup()
    if module.ActivePopup then return end
	module.ActivePopup = true
	local revivePopup = ReplicatedStorage.UIComponents.Utils.Revive.RevivePopup:Clone()
	revivePopup.Parent = player.PlayerGui
end

return module

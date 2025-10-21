local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)

local function checkForPrompt()
	return player:FindFirstChild("GroupPrompt")
end

local function createPrompt()
	if checkForPrompt() then
		return
	end
	SoundHandler.PlayUISound("ITEMFALLALERT")
	local groupPrompt = ReplicatedStorage.UIComponents.Utils.Group.GroupPrompt:Clone()
	groupPrompt.Parent = player.PlayerGui
end

return {
	CreatePrompt = createPrompt,
}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local function createPrompt()
    SoundHandler.PlayUISound("ITEMFALLALERT")
    local groupPrompt = ReplicatedStorage.UIComponents.Utils.Group.groupPrompt:Clone()
    groupPrompt.Parent = player.PlayerGui
end

return {
    CreatePrompt = createPrompt,
}
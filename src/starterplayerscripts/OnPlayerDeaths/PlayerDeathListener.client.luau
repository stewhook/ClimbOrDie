local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local BasicUtils = require(StarterPlayer.StarterPlayerScripts.BasicUtilities.BasicUtils)
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)

local inGamePlayersCache = ReplicatedStorage:WaitForChild("Caches"):WaitForChild("GamePlayers")

inGamePlayersCache.ChildRemoved:Connect(function(child: Instance)
	local playerID = tonumber(child.Name)
	if not playerID then
		return
	end
	-- functions on death play here.
	if BasicUtils.IsInGame() then
		SoundHandler.PlayRandomUISound(SoundService.InGame.SoundEffects.DeathSounds)
	end
end)

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local BasicUtils = require(StarterPlayer.StarterPlayerScripts.BasicUtilities.BasicUtils)
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local CustomHitbox = require(script.Parent.CustomHitbox)
local player = Players.LocalPlayer

local modelFolder = workspace:WaitForChild("LocalModels")

modelFolder.ChildAdded:Connect(function(child: Instance)
	local custom = child:GetAttribute("Custom")
	if not custom then
		return
	end

	if BasicUtils.IsInGame() == false then
        print("Creating Highlight")
		SoundHandler.PlayRandomUISound(SoundService.InGame.HitboxSpawnSounds)
		CustomHitbox.CreateHighlight(child)
	end
end)

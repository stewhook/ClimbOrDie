local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundKey = require(script.Parent.SoundKey)
local function preloadSounds()
	local soundFolder = {}
	print(ReplicatedStorage:WaitForChild("Sounds"):GetDescendants())
	for _, sound in ReplicatedStorage:WaitForChild("Sounds"):GetDescendants() do
		if sound:IsA("Sound") then
			table.insert(soundFolder, sound)
		end
	end
	ContentProvider:PreloadAsync(soundFolder)
end

preloadSounds()

local function playSoundAtPart(soundID: string, part)
	local sound = SoundKey[tostring(soundID)]
	if not sound then
		return
	end
    local clone = sound:Clone()
	if not clone.PlayOnRemove then
		clone.PlayOnRemove = true
	end
    clone.Parent = part
    clone:Destroy()
end

local function playUISound(soundID: string)
    local sound = SoundKey[tostring(soundID)]
	if not sound then
		return
	end
    sound:Play()
end

return {
	PlaySoundAtPart = playSoundAtPart,
    PlayUISound = playUISound,
}
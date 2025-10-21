local StarterPlayer = game:GetService("StarterPlayer")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local module = {}

function module.PlaySound(item: Part)
	local soundID = item:GetAttribute("SoundID")
	if not soundID then
		return
	end
	SoundHandler.PlaySoundAtPart(soundID, item)
end

return module

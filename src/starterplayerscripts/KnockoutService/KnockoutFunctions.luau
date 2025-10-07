local StarterPlayer = game:GetService("StarterPlayer")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local module = {}

function module.PlayKnockoutSound(character: Model)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	SoundHandler.PlaySoundAtPart("KNOCKOUT", hrp)
end

return module

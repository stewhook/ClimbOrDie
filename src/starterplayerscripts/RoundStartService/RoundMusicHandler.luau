local SoundService = game:GetService("SoundService")

local currentSong = nil

local function retrieveSong(index: number)
	return SoundService.InGame.RoundMusic:GetChildren()[index]
end

local function startMusic()
	if not currentSong then
		return
	end
	currentSong:Play()
end

local function pauseMusic()
	if not currentSong then
		return
	end
	currentSong:Pause()
end

local function clearMusic()
	if not currentSong then
		return
	end
	currentSong:Stop()
	currentSong = nil
end

local function initMusic(index: number)
	if currentSong then
		clearMusic()
	end
	currentSong = retrieveSong(index)
	startMusic()
end

return {
	Init = initMusic,
	StartMusic = startMusic,
	PauseMusic = pauseMusic,
	CancelMusic = clearMusic,
}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local loaded = false

local function haltTillLoaded()
	while not loaded do
        task.wait()
	end
    return
end

local function startLoadWait()
	if loaded then
		return
	end
	if ReplicatedStorage:WaitForChild("Caches"):WaitForChild("LoadedPlayers"):FindFirstChild(player.UserId) then
		loaded = true
		return
	else
		while not loaded do
			if ReplicatedStorage:WaitForChild("Caches"):WaitForChild("LoadedPlayers"):FindFirstChild(player.UserId) then
				loaded = true
				return
			end
			task.wait(0.01)
		end
	end
end

task.spawn(startLoadWait)

return {
    Wait = haltTillLoaded,
}
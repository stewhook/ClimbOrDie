local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local InGamePlayers = require(ServerScriptService.GameHandler.InGamePlayers)
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)

local playerKnockoutEvent: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.PlayerKnockedOut
local forceGetup: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.ForcePlayerGetup

local function knockoutHandler(player: Player)
	if not player or not player.Character then
		return
	end

	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local hrp: BasePart = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	SoundHandler.PlaySoundAtPart("KNOCKOUT", hrp)

	local playerGameData = InGamePlayers[player]
	if not playerGameData then
		return
	end

	local playerGear = playerGameData.EquippedGear
	local gearData = playerGameData.GearData
	if playerGear and gearData then
		if playerGear == "OldHelmet" or playerGear == "GoldenShield" then
			local protectionCount = gearData.Uses
			if protectionCount and protectionCount > 0 then
				gearData.Uses -= 1
				SoundHandler.PlaySoundAtPart("ARMOURHIT", hrp)
				forceGetup:FireClient(player, playerGear)
			end
		end
	end
end

playerKnockoutEvent.OnServerEvent:Connect(knockoutHandler)

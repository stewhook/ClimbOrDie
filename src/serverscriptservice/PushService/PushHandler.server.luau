local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local PushBalancing = require(ReplicatedStorage.StaticData.PushBalancing)

local pushEvent: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.PushRequest

local pushCooldowns = {}

local function pushPlayer(player: Player, targetChar)
	if not player then
		return
	end
	if not targetChar then
		return
	end

	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHRP then
		return
	end

	if pushCooldowns[player] then
		return
	end

	local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
	if not targetPlayer then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	pushCooldowns[player] = tick() + PushBalancing.PUSH_COOLDOWN
	targetChar:SetAttribute("Pushed", player.UserId)
    SoundHandler.PlaySoundAtPart("KNOCKOUT", targetHRP)
	task.wait(PushBalancing.TIME_TILL_GETUP)
	targetChar:SetAttribute("Pushed", 0)
end

pushEvent.OnServerEvent:Connect(pushPlayer)

local function synchronizeCooldown()
	if next(pushCooldowns) == nil then
		return
	end
	for player, coolTime in pushCooldowns do
		if tick() >= coolTime then
			pushCooldowns[player] = nil
		end
	end
end

while script.Parent do
	synchronizeCooldown()
	task.wait(0.05)
end

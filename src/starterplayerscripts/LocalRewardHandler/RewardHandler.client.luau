local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local RewardFunctions = require(script.Parent.RewardFunctions)

-- index[player] = { playerConn = RBXScriptConnection, chars = { [character] = { RBXScriptConnection, ... } } }
local index = {}

local function disconnectAll(conns)
	if not conns then
		return
	end
	for _, c in ipairs(conns) do
		if typeof(c) == "RBXScriptConnection" then
			c:Disconnect()
		end
	end
	table.clear(conns)
end

local function cleanupCharacter(player: Player, char: Model)
	local bucket = index[player]
	if not bucket or not bucket.chars then
		return
	end
	local list = bucket.chars[char]
	if list then
		disconnectAll(list)
		bucket.chars[char] = nil
	end
end

local function onCharacterAdded(player: Player, char)
	local bucket = index[player]
	if not bucket then
		return
	end

	bucket.chars[char] = {}

	local function track(conn)
		table.insert(bucket.chars[char], conn)
		return conn
	end

	-- Attribute listener (ragdoll flag set elsewhere)
	track(char:GetAttributeChangedSignal("RoundReward"):Connect(function()
		if not char.Parent then
			return
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		if char:GetAttribute("RoundReward") then
			-- functions begin here.
			SoundHandler.PlaySoundAtPart("PLAYERROUNDREWARD", hrp)
			RewardFunctions.playVFX(char, char:GetAttribute("RoundReward"))
		end
	end))

	-- Clean on death AND on removal
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		track(hum.Died:Connect(function()
			cleanupCharacter(player, char)
		end))
	end

	track(char.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			cleanupCharacter(player, char)
		end
	end))
end

local function startListener(player: Player)
	if index[player] then
		return
	end
	index[player] = { chars = {} }

	index[player].playerConn = player.CharacterAdded:Connect(function(char)
		onCharacterAdded(player, char)
	end)

	-- If character already exists, wire now
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end

local function wipeAllListeners(player: Player)
	local bucket = index[player]
	if not bucket then
		return
	end

	-- Disconnect CharacterAdded
	if typeof(bucket.playerConn) == "RBXScriptConnection" then
		bucket.playerConn:Disconnect()
	end

	-- Disconnect every character’s connections
	for char, list in pairs(bucket.chars) do
		disconnectAll(list)
		bucket.chars[char] = nil
	end

	index[player] = nil
end

-- Init for current players
for _, p in ipairs(Players:GetPlayers()) do
	startListener(p)
end

Players.PlayerAdded:Connect(startListener)
Players.PlayerRemoving:Connect(wipeAllListeners)

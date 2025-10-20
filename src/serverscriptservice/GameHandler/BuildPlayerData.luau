local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local GearBalancing = require(ReplicatedStorage.StaticData.Gear.GearBalancing)

local gearFolder = ServerStorage.Gear

local dataKey = {
	OldHelmet = {
		Uses = 1,
	},
	GoldenShield = {
		Uses = math.huge,
	},
	PiggyBank = nil,
	XRay = nil,
	Balloon = nil,
}

local gearCache = {}

local function clearCache(player: Player)
	if gearCache[player] then
		gearCache[player] = nil
	end
end

local startFunctions = {
	PiggyBank = function(player: Player)
		local gearData = GearBalancing["PiggyBank"]
		if not gearData then
			return
		end
		if not player then
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
		humanoid.WalkSpeed = gearData.ActiveWalkSpeed
		humanoid.JumpHeight = gearData.ActiveJumpHeight
	end,
	GravityCoil = function(player: Player)
		if not player then
			return
		end
		local char = player.Character
		if not char then
			return
		end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not humanoid or not hrp then
			return
		end
		local playerBackpack = player.Backpack
		if not playerBackpack then
			return
		end
		local clone = gearFolder.GravityCoil.GravityCoil:Clone()
		gearCache[player] = {
			Coil = clone,
		}
		clone.Parent = playerBackpack
	end,
}

local endFunctions = {
	PiggyBank = function(player: Player)
		local gearData = GearBalancing["PiggyBank"]
		if not gearData then
			return
		end
		if not player then
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
		humanoid.WalkSpeed = gearData.DefaultWalkSpeed
		humanoid.JumpHeight = gearData.DefaultJumpHeight
	end,
	GravityCoil = function(player: Player)
		if not player then
			return
		end

		local cached = gearCache[player]
		if cached and cached.Coil then
			cached.Coil:Destroy()
			clearCache(player)
		end
	end,
}

Players.PlayerRemoving:Connect(clearCache)

local function buildData(player: Player, gearID: string?)
	gearID = gearID or nil
	if not player then
		return
	end
	local table = {
		EquippedGear = gearID,
		StartFunction = startFunctions[gearID],
		EndFunction = endFunctions[gearID],
		GearData = dataKey[gearID],
	}
	return table
end

return {
	BuildData = buildData,
}

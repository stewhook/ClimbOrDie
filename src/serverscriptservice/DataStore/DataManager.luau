local ServerStorage = game:GetService("ServerStorage")
local module = {}

module.Profiles = {}

function module.verifyProfile(player: Player)
	if module.Profiles[player] ~= nil then
		return module.Profiles[player]
	end
	while module.Profiles[player] == nil do
		task.wait(0.05)
		if module.Profiles[player] ~= nil then
			return module.Profiles[player]
		end
	end
	return
end

function module.retrieveCache(player: Player)
	return player:FindFirstChild("CachedData")
end

local function checkForCache(player, valueName)
	return player:FindFirstChild("CachedData"):FindFirstChild(valueName)
end

local function checkForLeaderstat(player, valueName)
	return player:FindFirstChild("leaderstats"):FindFirstChild(valueName)
end

local function updateLeaderstat(player: Player, valueName: string?, value)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local valueObj = leaderstats:FindFirstChild(tostring(valueName))
	if not valueObj then
		return
	end
	valueObj.Value = value
end

function module.incrementValue(player: Player, valueName: string?, value: number)
	local profile = module.verifyProfile(player)
	if not profile then
		return
	end

	if profile.Data[valueName] == nil then
		return
	end

	profile.Data[valueName] += value

	local cache = checkForCache(player, valueName)
	if cache then
		cache.Value = profile.Data[valueName]
	end
	updateLeaderstat(player, valueName, profile.Data[valueName])
end

function module.setValue(player: Player, valueName: string?, value: number)
	local profile = module.verifyProfile(player)
	if not profile then
		return
	end

	local data = profile.Data[valueName]
	if data == nil then
		return
	end

	profile.Data[valueName] = value

	local cache = checkForCache(player, valueName)
	if cache then
		cache.Value = profile.Data[valueName]
	end
	updateLeaderstat(player, valueName, profile.Data[valueName])
end

function module.updateCache(player: Player, valueName: string?, value)
	local playerCache = player:FindFirstChild("CachedData")
	if not playerCache then
		return
	end
	local valueObj = playerCache:FindFirstChild(tostring(valueName))
	if not valueObj then
		return
	end
	valueObj.Value = value
end

function module.updateSessionData(player: Player, valueName: string?, value)
	local sessionData = player:FindFirstChild("SessionData")
	if not sessionData then
		return
	end
	local valueObj = sessionData:FindFirstChild(tostring(valueName))
	if not valueObj then
		return
	end
	valueObj.Value = value
end

function module.createLeaderstats(player: Player)
	local profile = module.verifyProfile(player)
	if not profile then
		return
	end
	local leaderstats = ServerStorage.Data:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end
	local clone = leaderstats:Clone()
	clone.Parent = player
	updateLeaderstat(player, "Wins", profile.Data.Wins)
	return clone
end

function module.createSessionData(player: Player)
	local sessionData = ServerStorage.Data:FindFirstChild("SessionData")
	if not sessionData then
		return
	end

	local clone = sessionData:Clone()
	clone.Parent = player
end

local function synchronizePlayerCache(cache, profile)
	for valueName, value in profile.Data do
		local obj = cache:FindFirstChild(tostring(valueName))
		if obj then
			obj.Value = value
		end
	end
end

function module.createPlayerCache(player: Player)
	local profile = module.verifyProfile(player)
	if not profile then
		return
	end
	local playerCache = ServerStorage.Data:FindFirstChild("CachedData")
	if not playerCache then
		return
	end

	local clone = playerCache:Clone()
	synchronizePlayerCache(clone, profile)
	clone.Parent = player
end

function module.isFirstJoin(player: Player)
	local profile = module.verifyProfile(player)
	if not profile then
		return
	end

	if profile.Data.FirstJoin == true then
		-- Start First Join Functions
		profile.Data.FirstJoin = false
	end
end

function module.syncSettings(player: Player, payload)
	local profile = module.verifyProfile(player)
	if not profile then
		return
	end
	for name, value in payload do
		if not profile.Data.Settings[name] then
			continue
		end
		profile.Data.Settings[name] = value
	end
end

return module

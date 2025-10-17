local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local BadgeFunctions = require(script.Parent.BadgeFunctions)
local BadgeKey = require(ReplicatedStorage.StaticData.BadgeKey)
local BadgeCache = require(player.PlayerScripts.CacheHandler.BadgeCache.BadgeCache)

local giveCoolBadgeEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerManagement"):WaitForChild("FirstBadgeEvent")

local function retrieveBadgeList()
	local t = {}
	print(BadgeKey)
	for _, ID in BadgeKey do
		table.insert(t, ID)
	end
	return t
end

local badgeList = retrieveBadgeList()
BadgeCache.OwnedBadges = BadgeService:CheckUserBadgesAsync(player.UserId, badgeList)

local coolBadgeList = {
	[1] = 1199958641001219,
	[2] = 2509153543285733,
	[3] = 2038483466587649,
	[4] = 814524174300860,
	[5] = 1580114724878928,
	[6] = 4297522458559883,
	[7] = 3938196168592659,
	[8] = 588893778664259,
	[9] = 1526536147734970,
	[10] = 432430901016325,
}

local function giveStartingBadges()
	for _, badgeID in ipairs(coolBadgeList) do
		if BadgeFunctions.playerOwnsBadge(badgeID) then
			print("Player Owns This Badge")
			continue
		end
		return true
	end
	return false
end

local sendEvent = giveStartingBadges()
print(sendEvent)

if sendEvent then
	giveCoolBadgeEvent:FireServer()
end

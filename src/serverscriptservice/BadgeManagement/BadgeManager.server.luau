local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeFunctions = require(script.Parent.BadgeFunctions)

local titleBadgeEvent: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.FirstBadgeEvent

local function giveTitleBadges(player: Player)
	local orderedList = {
		[10] = 1199958641001219,
		[9] = 2509153543285733,
		[8] = 2038483466587649,
		[7] = 814524174300860,
		[6] = 1580114724878928,
		[5] = 4297522458559883,
		[4] = 3938196168592659,
		[3] = 588893778664259,
		[2] = 1526536147734970,
		[1] = 432430901016325,
	}
	for _, ID in ipairs(orderedList) do
		if BadgeFunctions.playerOwns(player, ID) then
			continue
		end
		BadgeService:AwardBadge(player.UserId, ID)
	end
end

titleBadgeEvent.OnServerEvent:Connect(giveTitleBadges)

local ServerScriptService = game:GetService("ServerScriptService")
local HitboxData = require(ServerScriptService.FallItemService.HitboxData)
local ItemSpawnHandler = require(ServerScriptService.FallItemService.ItemSpawnHandler)

local function spawnThree(player: Player)
	ItemSpawnHandler.AddCustomSpawns(HitboxData.getHitboxes(), 3, 0.1, player)
end

local function spawnFive(player: Player)
	ItemSpawnHandler.AddCustomSpawns(HitboxData.getHitboxes(), 5, 0.1, player)
end

local function largeThree(player: Player)
	ItemSpawnHandler.AddCustomSpawns(HitboxData.getHitboxesByType("LARGE"), 3, 0.15, player)
end

local functionKey = {
	Regular3 = spawnThree,
	Regular5 = spawnFive,
	Large3 = largeThree,
}
local function handler(typeOf: string, player: Player)
	if not functionKey[typeOf] then
		warn("No Button Type Found In Functions")
		return
	end
	functionKey[typeOf](player)
end

return {
	Handler = handler,
}

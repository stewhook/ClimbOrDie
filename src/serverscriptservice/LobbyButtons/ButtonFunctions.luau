local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HitboxData = require(ServerScriptService.FallItemService.HitboxData)
local ItemSpawnHandler = require(ServerScriptService.FallItemService.ItemSpawnHandler)

local hitboxFolder = ReplicatedStorage.Hitboxes

local function spawnThree(player: Player)
	ItemSpawnHandler.AddCustomSpawns(HitboxData.getHitboxes(), 3, 0.1, player)
end

local functionKey = {
	Regular3 = spawnThree,
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

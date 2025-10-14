local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductKey = require(ReplicatedStorage.StaticData.DevProductKey)

local bindableEvents = ReplicatedStorage.Events.BindableEvents
local revivePlayerBind: BindableEvent = bindableEvents.RevivePlayer

local module = {}

-- Product handler functions
local productFunctions = {}

-- Handler for Revive product
productFunctions[DevProductKey.Revive] = function(player: Player)
	revivePlayerBind:Fire(player)
    return true
end


-- Global handler function
function module.Handler(player: Player, devProductId: number)
	local handlerFunction = productFunctions[devProductId]

	if not handlerFunction then
		warn(`No handler function found for ProductId: {devProductId}`)
		return false
	end

	return handlerFunction(player)
end

return module

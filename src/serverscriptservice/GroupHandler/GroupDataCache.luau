local module = {}

module.Cache = {}

function module.SafeRetrieve(player: Player)
	if not player then
		return
	end
	if module.Cache[player] then
		return module.Cache[player]
	end
	while not module.Cache[player] do
		task.wait(0.05)
		if module.Cache[player] then
			return module.Cache[player]
		end
	end
end

return module

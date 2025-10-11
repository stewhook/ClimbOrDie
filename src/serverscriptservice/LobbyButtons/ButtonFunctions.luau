local function spawnThree()
	print("Running Spawn 3 Function")
end

local functionKey = {
	Regular3 = spawnThree,
}
local function handler(typeOf: string)
	if not functionKey[typeOf] then
		warn("No Button Type Found In Functions")
		return
	end
	functionKey[typeOf]()
end

return {
	Handler = handler,
}

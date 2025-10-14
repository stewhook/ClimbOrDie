local function TNTFunction(hitbox)
	print("TNT Function Running On TNT Spawn")
end

local functionKey = {
	TNT = TNTFunction,
}

local function handler(hitbox, functionType: string)
	if not functionKey[functionType] then
		return
	end
	functionKey[functionType](hitbox)
end

return {
	Handler = handler,
}

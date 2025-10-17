local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function grabPlayerTag()
	local char = player.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local playerTag: BillboardGui = hrp:FindFirstChild("PlayerTag")
	if not playerTag then
		return
	end

	return playerTag
end

local function firstPersonStart()
	local tag: BillboardGui = grabPlayerTag()
	if tag then
		tag.Enabled = false
	end
end

local function firstPersonEnd()
	local tag: BillboardGui = grabPlayerTag()
	if tag then
		tag.Enabled = true
	end
end

return {
	OnFirstPerson = firstPersonStart,
	OnThirdPerson = firstPersonEnd,
}

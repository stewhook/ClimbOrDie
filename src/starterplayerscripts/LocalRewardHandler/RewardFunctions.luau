local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = {}

local function createAttachment(parent)
	local preAttachment = parent:FindFirstChild("VFXAttachment")
	if preAttachment then
		return preAttachment
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "VFXAttachment"
	attachment.Parent = parent
	return attachment
end

local function propagateAttachment(attachment: Attachment, VFXFolder: Folder)
	local VFXList = {}
	for _, VFX in VFXFolder:GetChildren() do
		local clone = VFX:Clone()
		table.insert(VFXList, clone)
		clone.Parent = attachment
	end
	return VFXList
end

local function playVFX(list, amount)
	for _, VFX in list do
		VFX:Emit(amount)
		Debris:AddItem(VFX, 2)
	end
end

function module.playVFX(character: Model, amount: number)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local rewardVFXFolder = ReplicatedStorage:WaitForChild("VFX").OnPlayer.RoundReward
	local attachment = createAttachment(hrp)
	local list = propagateAttachment(attachment, rewardVFXFolder)
	playVFX(list, amount)
end

return module

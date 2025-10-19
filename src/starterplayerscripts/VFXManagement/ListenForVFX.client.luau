local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TNTTempPart = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("TempParts"):WaitForChild("TNTExplodeTempPart")
local VFXBurstEvent: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("RoundManagement"):WaitForChild("PlayVFXBurst")

local function playVFX(explodePos: Vector3)
	local clone = TNTTempPart:Clone()
	clone.Position = explodePos
	clone.Parent = workspace.TempParts
    Debris:AddItem(clone, 3)

	local VFXAttachment = clone:FindFirstChildOfClass("Attachment")
	if not VFXAttachment then
		return
	end

	for _, particle: ParticleEmitter in VFXAttachment:GetChildren() do
		local emitCount = particle:GetAttribute("Emit")
		if not emitCount then
			continue
		end
		particle:Emit(emitCount)
	end
end

VFXBurstEvent.OnClientEvent:Connect(playVFX)

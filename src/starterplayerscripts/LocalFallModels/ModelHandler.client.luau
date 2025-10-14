local Workspace = game:GetService("Workspace")
local ModelKey = require(script.Parent.ModelKey)

local fallPartFolder: Folder = Workspace.FallingParts
local localModels: Folder = Workspace.LocalModels

local modelIndex = {}

fallPartFolder.ChildRemoved:Connect(function(hitbox)
	if modelIndex[hitbox] then
		modelIndex[hitbox]:Destroy()
	end
end)

local function weldParts(part0, part1)
	local weld: WeldConstraint = Instance.new("WeldConstraint")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part0
	return weld
end

local function weldToModel(hitbox, model) end

local function buildModelAtHitbox(hitbox: Part, model)
	if not hitbox then
		warn("Hitbox missing")
		return
	end
	if not model then
		warn("Model missing")
		return
	end

	-- Clone the model/part
	local clone = model:Clone()
	if hitbox:GetAttribute("Custom") then
		clone:SetAttribute("Custom", hitbox:GetAttribute("Custom"))
	end
	if hitbox:GetAttribute("Function") then
		clone:SetAttribute("Function", hitbox:GetAttribute("Function"))
	end
	clone.Parent = localModels

	-- Determine target CFrame and the anchor part to weld to
	local targetCFrame
	local anchorPart: BasePart? = nil
	if hitbox:IsA("BasePart") then
		targetCFrame = hitbox.CFrame
		anchorPart = hitbox
	elseif hitbox:IsA("Model") then
		targetCFrame = hitbox:GetPivot()
		anchorPart = hitbox.PrimaryPart
		if not anchorPart then
			for _, d in hitbox:GetDescendants() do
				if d:IsA("BasePart") then
					anchorPart = d
					break
				end
			end
		end
	else
		warn("Unsupported hitbox type")
		return
	end

	-- Handle different model types
	if clone:IsA("BasePart") then
		-- If it's a BasePart/MeshPart, position it directly and weld it
		clone.CFrame = targetCFrame
		clone.Anchored = false
		if anchorPart then
			weldParts(anchorPart, clone)
		end
	elseif clone:IsA("Model") then
		-- If it's a Model, position it and weld all its parts
		clone:PivotTo(targetCFrame)
		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = false
				if anchorPart then
					weldParts(anchorPart, descendant)
				end
			end
		end
	else
		warn("Unsupported model type:", clone.ClassName)
	end

	modelIndex[hitbox] = clone
end

local function initParts()
	for _, hitbox in fallPartFolder:GetChildren() do
		local ID = hitbox:GetAttribute("ID")
		if not ID then
			warn("Invalid ID")
			continue
		end
		local model = ModelKey[ID]
		if not model then
			warn("No model found for ID:", ID)
		else
			buildModelAtHitbox(hitbox, model)
		end
	end
end

initParts()

fallPartFolder.ChildAdded:Connect(function(hitbox)
	local ID = hitbox:GetAttribute("ID")
	if not ID then
		warn("Invalid ID")
		return
	end
	local model = ModelKey[ID]
	if not model then
		warn("No model found for ID:", ID)
		return
	end
	buildModelAtHitbox(hitbox, model)
end)

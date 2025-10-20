local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local gearCache = nil

local startFunctions = {
	XRay = function()
		if not player then
			return
		end
        local tweenTime = 3 - (.5 * (ReplicatedStorage.RoundInfo.CurrentRound.Value - 1))
		local tweenDetails = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

		local function buildHighlight(part: Instance)
			local highlight = ReplicatedStorage.RoundUtils.Highlights.XRayHighlight:Clone()
			highlight.Parent = part
			return highlight
		end

		local function buildTween(highlight: Highlight)
			return TweenService:Create(highlight, tweenDetails, {
				FillTransparency = 1,
				OutlineTransparency = 1,
			})
		end

		local modelFolder: Folder = workspace.LocalModels
		local connection = modelFolder.ChildAdded:Connect(function(child: Instance)
			if child:GetAttribute("AlertID") then
				return
			end
			local highlight = buildHighlight(child)
			local tween = buildTween(highlight)
			tween:Play()
			tween.Completed:Wait()
			highlight:Destroy()
		end)
		gearCache = {
			Connection = connection,
		}
	end,
}

local endFunctions = {
	XRay = function()
		if not player then
			return
		end
		if gearCache then
			gearCache.Connection:Disconnect()
			gearCache = nil
		end
	end,
}

local function startFunction(gearID: string)
	if not endFunctions[gearID] then
		return
	end
	startFunctions[gearID]()
end

local function endFunction(gearID: string)
	if not endFunctions[gearID] then
		return
	end
	endFunctions[gearID]()
end

return {
	Start = startFunction,
	End = endFunction,
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tweenDetails = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local function createTween(highlight: Instance)
	return TweenService:Create(highlight, tweenDetails, { FillTransparency = 1, OutlineTransparency = 1 })
end

local function createHighlight(model: Instance)
	local highlight = ReplicatedStorage:WaitForChild("LobbyUtils"):WaitForChild("Highlights"):WaitForChild("CustomHighlight"):Clone()
	local tween: Tween = createTween(highlight)
	highlight.Parent = model
	tween:Play()
	tween.Completed:Wait()
	highlight:Destroy()
end

return {
	CreateHighlight = createHighlight,
}

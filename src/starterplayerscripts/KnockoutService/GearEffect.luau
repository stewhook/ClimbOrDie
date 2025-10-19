local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local function selectItem(gearID: string)
	if not gearID then
		return
	end
	local roundGui = player.PlayerGui:FindFirstChild("RoundGui")
	if not roundGui then
		return
	end
	local gearUseUI = roundGui:FindFirstChild("GearUseUI")
	if not gearUseUI then
		return
	end

	local selectedImage = gearUseUI.ImageFrame:FindFirstChild(gearID)
	if not selectedImage then
		return
	end

	return selectedImage
end

local tweenDetails = TweenInfo.new(.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local function playEffect(gearID: string)
	local image: ImageLabel = selectItem(gearID)
	image.ImageTransparency = .5
	local tween = TweenService:Create(image, tweenDetails, { ImageTransparency = 1 })
	tween:Play()
end

return {
	PlayEffect = playEffect,
}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local activeIdleAnimation = {}

local UIAnimationLibrary = {}
UIAnimationLibrary.OnLoad = {}
UIAnimationLibrary.OnClose = {}
UIAnimationLibrary.Hover = {}
UIAnimationLibrary.Idle = {}
UIAnimationLibrary.ForceRun = {}

local defaultHoverSound = SoundService.UI.Actions.Hover.UIHover_Pop
function UIAnimationLibrary.OnLoad.PlaySound(sound, volume)
	volume = volume or sound:GetAttribute("Volume") or sound.Volume
	local originalSoundPos = sound.Parent

	local clonedSound = sound:Clone()
	clonedSound.Parent = originalSoundPos
	clonedSound.Volume = volume
	Debris:AddItem(clonedSound, clonedSound.TimeLength)
	clonedSound:Play()
end

function UIAnimationLibrary.ForceRun.FlyToBottom(item: Frame, deletePart, duration: number)
	deletePart = deletePart or nil
	duration = duration or 0.2
	local flyAwayTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local flyTween = TweenService:Create(item, flyAwayTweenDetails, { Position = UDim2.new(0.5, 0, 1, 0) })
	flyTween:Play()
	flyTween.Completed:Wait()
	if deletePart then
		deletePart:Destroy()
	end
end

function UIAnimationLibrary.OnClose.FlyToBottom(item: Frame, fireButton: GuiButton, deletePart, duration: number)
	deletePart = deletePart or nil
	duration = duration or 0.2
	local flyAwayTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local flyTween = TweenService:Create(item, flyAwayTweenDetails, { Position = UDim2.new(0.5, 0, 1, 0) })
	fireButton.MouseButton1Click:Connect(function()
		flyTween:Play()
		flyTween.Completed:Wait()
		if deletePart then
			deletePart:Destroy()
		end
	end)
end

function UIAnimationLibrary.OnClose.ScaleToZero(item, fireButton: GuiButton, deletePart: GuiBase, duration: number)
	duration = duration or 0.2

	local UIScale: UIScale = item:FindFirstChild("UIScale")

	local scaleTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local scaleTween = TweenService:Create(UIScale, scaleTweenDetails, { Scale = 0 })
	fireButton.MouseButton1Click:Connect(function()
		scaleTween:Play()
		scaleTween.Completed:Wait()
		deletePart:Destroy()
	end)
end

function UIAnimationLibrary.OnLoad.FlyFromBottom(item: Frame, duration: number)
	duration = duration or 0.2
	local ORIGINAL_POSITION = item.Position
	item.Position = UDim2.new(0.5, 0, 1, 0)

	local flyTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local flyTween = TweenService:Create(item, flyTweenDetails, { Position = ORIGINAL_POSITION })
	flyTween:Play()
end

function UIAnimationLibrary.OnLoad.ScaleFromAmount(item, startingScale: number, duration: number)
	startingScale = startingScale or item:GetAttribute("StartScale") or 0.1
	duration = duration or 0.2

	local UIScale: UIScale = item:FindFirstChild("UIScale")
	local ORIGINAL_SIZE = UIScale.Scale
	UIScale.Scale = startingScale

	local scaleTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local scaleTween = TweenService:Create(UIScale, scaleTweenDetails, { Scale = ORIGINAL_SIZE })
	scaleTween:Play()
end

function UIAnimationLibrary.Hover.ScaleTilt(item, scale: number, rotation: number, duration: number)
	scale = scale or item:GetAttribute("Scale") or 10
	rotation = rotation or item:GetAttribute("Rotation") or 10
	duration = duration or item:GetAttribute("Duration") or 0.2

	local itemScale: UIScale = item:FindFirstChildOfClass("UIScale")
	local buttonImage: ImageLabel = item:FindFirstChild("ButtonImage")
	local ORIGINAL_ROTATION = buttonImage.Rotation
	local ORIGINAL_SCALE = itemScale.Scale

	local scale = ((ORIGINAL_SCALE * 100) + scale) / 100
	local scaleTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local leanTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	item.MouseEnter:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = scale })
		local buttonLeanTween =
			TweenService:Create(buttonImage, leanTweenDetails, { Rotation = ORIGINAL_ROTATION + rotation })
		buttonScaleTween:Play()
		buttonLeanTween:Play()
	end)

	item.MouseLeave:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = ORIGINAL_SCALE })
		local buttonLeanTween = TweenService:Create(buttonImage, leanTweenDetails, { Rotation = ORIGINAL_ROTATION })
		buttonScaleTween:Play()
		buttonLeanTween:Play()
	end)

	item.MouseButton1Down:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = ORIGINAL_SCALE })
		local buttonLeanTween = TweenService:Create(buttonImage, leanTweenDetails, { Rotation = ORIGINAL_ROTATION })
		buttonScaleTween:Play()
		buttonLeanTween:Play()
	end)

	item.MouseButton1Up:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = scale })
		local buttonLeanTween =
			TweenService:Create(buttonImage, leanTweenDetails, { Rotation = ORIGINAL_ROTATION + rotation })
		buttonScaleTween:Play()
		buttonLeanTween:Play()
	end)
end

function UIAnimationLibrary.Hover.ScaleSpin(item, scale: number, duration: number)
	scale = scale or item:GetAttribute("Scale") or 10
	duration = duration or item:GetAttribute("Duration") or 0.2

	local itemScale: UIScale = item:FindFirstChildOfClass("UIScale")
	local buttonImage: ImageLabel = item:FindFirstChild("ButtonImage")
	local ORIGINAL_ROTATION = buttonImage.Rotation
	local ORIGINAL_SCALE = itemScale.Scale

	local scale = ((ORIGINAL_SCALE * 100) + scale) / 100
	local scaleTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local spinTweenDetails = TweenInfo.new(duration * 3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	local activeSpeenTween = nil

	item.MouseEnter:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = scale })
		local spinTween = TweenService:Create(buttonImage, spinTweenDetails, { Rotation = ORIGINAL_ROTATION + 360 })
		buttonScaleTween:Play()
		if activeSpeenTween then
			return
		end
		spinTween:Play()
		activeSpeenTween = spinTween
		spinTween.Completed:Wait()
		buttonImage.Rotation = ORIGINAL_ROTATION
		activeSpeenTween = nil
	end)

	item.MouseLeave:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = ORIGINAL_SCALE })
		buttonScaleTween:Play()
	end)
end

function UIAnimationLibrary.Hover.ButtonScale(item, scale: number, duration: number)
	scale = scale or item:GetAttribute("Scale") or 10
	duration = duration or item:GetAttribute("Duration") or 0.2

	local itemScale: UIScale = item:FindFirstChildOfClass("UIScale")
	local ORIGINAL_SCALE = itemScale.Scale

	local scale = ((ORIGINAL_SCALE * 100) + scale) / 100
	local scaleTweenDetails = TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	item.MouseEnter:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = scale })
		buttonScaleTween:Play()
	end)

	item.MouseLeave:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = ORIGINAL_SCALE })
		buttonScaleTween:Play()
	end)

	item.MouseButton1Down:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = ORIGINAL_SCALE })
		buttonScaleTween:Play()
	end)

	item.MouseButton1Up:Connect(function()
		if activeIdleAnimation[item] then
			activeIdleAnimation[item]:Stop()
		end
		local buttonScaleTween = TweenService:Create(itemScale, scaleTweenDetails, { Scale = scale })
		buttonScaleTween:Play()
	end)
end

function UIAnimationLibrary.Hover.PlaySound(item: GuiButton, volume: number)
	volume = volume or item:GetAttribute("Volume") or defaultHoverSound.Volume
	local originalSoundPos = defaultHoverSound.Parent

	item.MouseEnter:Connect(function()
		local hoverSound = defaultHoverSound:Clone()
		hoverSound.Parent = originalSoundPos
		hoverSound.Volume = volume
		Debris:AddItem(hoverSound, hoverSound.TimeLength)
		hoverSound:Play()
	end)
end

return UIAnimationLibrary

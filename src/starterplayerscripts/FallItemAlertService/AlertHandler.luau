local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local BasicUtils = require(StarterPlayer.StarterPlayerScripts.BasicUtilities.BasicUtils)
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)

local activeCooldowns = {}
local activeAlerts = {} -- Track active alerts for limit management
local MAX_ALERTS = 4
local alertTweenDetails = TweenInfo.new(.33, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local function buildAlertAnimation(frame: Frame)
	-- Set initial size to 0 and animate to full size
	local originalY = frame.Size.Y.Scale
	frame.Size = UDim2.fromScale(frame.Size.X.Scale, 0)
	return TweenService:Create(frame, alertTweenDetails, { Size = UDim2.fromScale(frame.Size.X.Scale, originalY) })
end

local alertRemoveTweenDetails = TweenInfo.new(0.33, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local function buildRemoveAnimation(frame: Frame)
	-- Animate from current size to 0
	return TweenService:Create(frame, alertRemoveTweenDetails, { Size = UDim2.fromScale(frame.Size.X.Scale, 0) })
end

local function startCooldown(frame: Frame, cooldown: number)
	activeCooldowns[frame] = tick() + cooldown
end

local function endCooldown(frame: Frame)
	print("Ending cooldown for frame")
	activeCooldowns[frame] = nil
	-- Remove from active alerts tracking
	local index = table.find(activeAlerts, frame)
	if index then
		table.remove(activeAlerts, index)
	end
	local endTween: Tween = buildRemoveAnimation(frame)
	endTween:Play()
	endTween.Completed:Wait()
	frame:Destroy()
end

local function buildAlert(title: string, soundID: string)
	-- Check if we need to remove the oldest alert
	if #activeAlerts >= MAX_ALERTS then
		local oldestAlert = activeAlerts[1] -- First in the list is oldest
		if oldestAlert and oldestAlert.Parent then
			endCooldown(oldestAlert)
		end
	end

	local clone = ReplicatedStorage.UIComponents.RoundUtils.PartAlerts.AlertTemplate:Clone()
	clone.AlertText.Text = tostring(title)

	-- Set up animation before parenting to ensure initial size is set correctly
	BasicUtils.strokeSync(clone)
	clone.Parent = player.PlayerGui.RoundGui.PartAlerts.Alerts
	local anim: Tween = buildAlertAnimation(clone)

	-- Add to active alerts tracking (newest at the end)
	table.insert(activeAlerts, clone)

	startCooldown(clone, 3)
	SoundHandler.PlayUISound(soundID)
	anim:Play()
end

local highlightAnimDetails = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local function buildHighlightAnim(highlight)
	local fillTween = TweenService:Create(highlight, highlightAnimDetails, { FillTransparency = 1 })
	local borderTween = TweenService:Create(highlight, highlightAnimDetails, { OutlineTransparency = 1 })
	return fillTween, borderTween
end

local function playHighlight(part)
	local clone: Highlight = ReplicatedStorage.RoundUtils.Highlights.AlertHighlight:Clone()
	clone.Parent = part
	local anim1, anim2 = buildHighlightAnim(clone)
	anim1:Play()
	anim2:Play()
	anim2.Completed:Wait()
	clone:Destroy()
end

task.spawn(function()
	while script.Parent do
		if not next(activeCooldowns) then
			task.wait(0.1)
		else
			-- Collect frames that need cooldown ended to avoid modifying table while iterating
			local framesToEnd = {}
			for frame, coolTime in activeCooldowns do
				if tick() >= coolTime then
					table.insert(framesToEnd, frame)
				end
			end

			-- End cooldowns for collected frames
			for _, frame in framesToEnd do
				endCooldown(frame)
			end

			task.wait(0.1)
		end
	end
end)

return {
	BuildAlert = buildAlert,
	HighlightAlert = playHighlight,
}

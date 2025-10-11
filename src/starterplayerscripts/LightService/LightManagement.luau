local AccountService = game:GetService("AccountService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local BasicUtils = require(StarterPlayer.StarterPlayerScripts.BasicUtilities.BasicUtils)
local SoundHandler = require(StarterPlayer.StarterPlayerScripts.SoundHandler.SoundHandler)
local activeWarning = false
local activeTweens = {}

local function initLights()
	local sendTable = {}
	for _, light in workspace:WaitForChild("Map"):WaitForChild("Lights"):GetChildren() do
		if not light:IsA("Model") then
			continue
		end

		local base = light:FindFirstChild("Base")
		local bulb = light:FindFirstChild("Bulb")
		local pLight = bulb:FindFirstChildOfClass("PointLight")
		local sLight = bulb:FindFirstChildOfClass("SpotLight")

		if not base or not bulb or not pLight or not sLight then
			continue
		end

		local payload = {
			Base = base,
			Bulb = bulb,
			OriginalColor = bulb.Color,
			PointLight = pLight,
			SpotLight = sLight,
		}

		table.insert(sendTable, payload)
	end
	return sendTable
end

local lightTable = initLights()

local function resetLights()
	if not lightTable then
		return
	end
end

local function lightPulse() end

local pulseTime = 1
local warningColor = Color3.new(1, 0.4, 0.4)
local pulseTweenDetails = TweenInfo.new(pulseTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local function startWarning()
	if not lightTable then
		return
	end

	activeWarning = true

	while activeWarning do
		if BasicUtils.IsInGame() then
			SoundHandler.PlayUISound("WARNINGSEQUENCE")
		end
		for _, data in lightTable do
			local originalColor = data.OriginalColor

			data.PointLight.Color = warningColor
			data.SpotLight.Color = warningColor
			data.Bulb.Color = warningColor
			local pointTween = TweenService:Create(data.PointLight, pulseTweenDetails, { Color = originalColor })
			local spotTween = TweenService:Create(data.SpotLight, pulseTweenDetails, { Color = originalColor })
			local bulbTween: Tween = TweenService:Create(data.Bulb, pulseTweenDetails, { Color = originalColor })
			pointTween:Play()
			spotTween:Play()
			bulbTween:Play()
			table.insert(activeTweens, pointTween)
			table.insert(activeTweens, spotTween)
			table.insert(activeTweens, bulbTween)
		end
		task.wait(pulseTime)
	end
end

local function stopWarning()
	if not lightTable then
		return
	end
	activeWarning = false
	for index, tweens: Tween in activeTweens do
		tweens:Cancel()
		activeTweens[index] = nil
	end

	for _, data in lightTable do
		data.PointLight.Color = data.OriginalColor
		data.SpotLight.Color = data.OriginalColor
	end
	print(activeTweens)
end

return {
	ResetLights = resetLights,
	StartWarning = startWarning,
	StopWarning = stopWarning,
}

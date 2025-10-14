local StarterPlayer = game:GetService("StarterPlayer")
local BasicUtils = require(StarterPlayer.StarterPlayerScripts.BasicUtilities.BasicUtils)
local ButtonFunctions = require(script.Parent.ButtonFunctions)
local buttonFolder = workspace:WaitForChild("Lobby"):WaitForChild("Buttons")

local function runInit()
	for _, button in buttonFolder:GetChildren() do
		ButtonFunctions.connectButton(button)
		ButtonFunctions.promptDisplayHandler(button)
	end
end

local function roundToOneDecimal(number: number): string
	return string.format("%.1f", number)
end

local function startDelayCountdown(button, nextUse: number)
	while nextUse > BasicUtils.GetServerTime() do
		button.Base.TimerUI.TimeLeft.Text = roundToOneDecimal(nextUse - BasicUtils.GetServerTime())
		task.wait(0.1)
	end
	button.Base.TimerUI.TimeLeft.Text = ""
end

local function startDelayUI()
	for _, button in buttonFolder:GetChildren() do
		if button:GetAttribute("NextUse") == nil then
			continue
		end
		local nextUseTime = button:GetAttribute("NextUse")
		if nextUseTime > BasicUtils.GetServerTime() then
			startDelayCountdown(button, nextUseTime)
		end
		button:GetAttributeChangedSignal("NextUse"):Connect(function()
			local nextUse = button:GetAttribute("NextUse")
			if nextUse > BasicUtils.GetServerTime() then
				startDelayCountdown(button, nextUse)
			end
		end)
	end
end

runInit()
startDelayUI()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local BasicUtils = require(StarterPlayer.StarterPlayerScripts.BasicUtilities.BasicUtils)
local module = {}

local activeTweens = {}

local buttonPressEvent: RemoteEvent =
	ReplicatedStorage:WaitForChild("Events"):WaitForChild("Lobby"):WaitForChild("ButtonPress")
local buttonHighlight: Highlight =
	ReplicatedStorage:WaitForChild("LobbyUtils"):WaitForChild("Highlights"):WaitForChild("ButtonHighlight")

local highlightTweenDetails = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function createHighlight(model: Model)
	if activeTweens[model] then
		activeTweens[model].Tween:Cancel()
		activeTweens[model].Highlight:Destroy()
		activeTweens[model] = nil
	end
	local highlight = buttonHighlight:Clone()
	local startFill = highlight.FillTransparency
	local startOutline = highlight.OutlineTransparency
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = model
	local tween = TweenService:Create(
		highlight,
		highlightTweenDetails,
		{ FillTransparency = startFill, OutlineTransparency = startOutline }
	)
	activeTweens[model] = {
		Tween = tween,
		Highlight = highlight,
	}
	tween:Play()
end

local function removeHighlight(model: Model)
	local promptPart = model:FindFirstChild("PromptPart")
	if not promptPart then
		return
	end
	local highlight = model:FindFirstChildOfClass("Highlight")
	if not highlight then
		return
	end

	local tween =
		TweenService:Create(highlight, highlightTweenDetails, { FillTransparency = 1, OutlineTransparency = 1 })
	tween:Play()
	tween.Completed:Wait()
	if activeTweens[model] then
		activeTweens[model].Tween:Cancel()
		activeTweens[model].Highlight:Destroy()
		activeTweens[model] = nil
	end
end

function module.connectButton(model: Model)
	local promptPart = model:WaitForChild("PromptPart", 3)
	if not promptPart then
		return
	end
	local prompt: ProximityPrompt = promptPart:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		return
	end

	local buttonType = model:GetAttribute("Type")
	if not buttonType then
		return
	end

	print("Creating Event Triggers")

	prompt.Triggered:Connect(function(player: Player)
		local lastUse = model:GetAttribute("LastUse")
		if not lastUse then
			return
		end

		local nextUse = model:GetAttribute("NextUse")
		if not nextUse then
			return
		end

		local cooldown = model:GetAttribute("Cooldown")
		if not cooldown then
			return
		end

		if BasicUtils.GetServerTime() >= nextUse then
			buttonPressEvent:FireServer(model, buttonType)
		else
			print("Cooldown")
		end
	end)

	prompt.PromptShown:Connect(function()
		createHighlight(model)
	end)

	prompt.PromptHidden:Connect(function()
		removeHighlight(model)
	end)
end

function module.promptDisplayHandler(model: Model)
	local promptPart = model:WaitForChild("PromptPart", 3)
	if not promptPart then
		return
	end
	local prompt: ProximityPrompt = promptPart:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		return
	end

	local isActive = model:GetAttribute("Active")
	if isActive then
		prompt.Enabled = true
	else
		prompt.Enabled = false
	end

	model:GetAttributeChangedSignal("Active"):Connect(function()
		local value = model:GetAttribute("Active")
		if value == true then
			prompt.Enabled = true
		elseif value == false then
			prompt.Enabled = false
		end
	end)
end

return module

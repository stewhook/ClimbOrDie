local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ButtonFunctions = require(script.Parent.ButtonFunctions)

local buttonPressEvent: RemoteEvent = ReplicatedStorage.Events.Lobby.ButtonPress
local roundInfoFolder = ReplicatedStorage.RoundInfo
local roundActiveObj: BoolValue = roundInfoFolder.RoundActive

local buttonFolder = workspace.Lobby.Buttons

local function resetButton(button: Model, active: boolean)
	button:SetAttribute("Active", active)
	button:SetAttribute("LastUse", 0)
	button:SetAttribute("NextUse", 0)
end

local function cooldownOver(button: Model)
	local nextUse = button:GetAttribute("NextUse")
	return Workspace:GetServerTimeNow() >= nextUse
end

local function createButtonCooldown(button: Model)
	local lastUse = button:GetAttribute("LastUse")
	if not lastUse then
		return
	end
	local nextUse = button:GetAttribute("NextUse")
	if not nextUse then
		return
	end
	local cooldown = button:GetAttribute("Cooldown")
	if not cooldown then
		return
	end

	local currentTime = Workspace:GetServerTimeNow()
	local nextUseTime = currentTime + cooldown

	button:SetAttribute("Active", false)
	button:SetAttribute("LastUse", currentTime)
	button:SetAttribute("NextUse", nextUseTime)
end

local function synchronizeCooldowns()
	for _, button in buttonFolder:GetChildren() do
		if cooldownOver(button) then
			resetButton(button, true)
		end
	end
end

local function buttonPress(player: Player, button: Model, typeOf: string)
	if not player then
		return
	end
	if not button then
		return
	end
	local active = button:GetAttribute("Active")
	if active == false then
		return
	end
	if not typeOf then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp or humanoid.Health <= 0 then
		return
	end

	local nextUse = button:GetAttribute("NextUse")
	if not nextUse then
		return
	end

	if cooldownOver(button) then
		createButtonCooldown(button)
		ButtonFunctions.Handler(typeOf, player)
	end
end

local function resetButtons()
	for _, button in buttonFolder:GetChildren() do
		resetButton(button, false)
	end
end

local function startButtons()
	for _, button in buttonFolder:GetChildren() do
		resetButton(button, true)
	end	
end

local activeSync = false
local function startSyncing()
	activeSync = true
	task.spawn(function()
		while activeSync do
			synchronizeCooldowns()
			task.wait(0.1)
		end
	end)
end

local function endSync()
	activeSync = false
end

local function RoundEnd()
	endSync()
	resetButtons()
end

local function RoundStart()
	startButtons()
	startSyncing()
end

buttonPressEvent.OnServerEvent:Connect(buttonPress)

roundActiveObj:GetPropertyChangedSignal("Value"):Connect(function()
	local value = roundActiveObj.Value

	if value == true then
		RoundStart()
	else
		RoundEnd()
	end
end)

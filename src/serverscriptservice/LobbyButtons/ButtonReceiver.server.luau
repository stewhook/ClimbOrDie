local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ButtonCooldowns = require(script.Parent.ButtonCooldowns)
local ButtonFunctions = require(script.Parent.ButtonFunctions)

local buttonPressEvent: RemoteEvent = ReplicatedStorage.Events.Lobby.ButtonPress

local activeCooldowns = {}

local function createButtonCooldown(button: Model)
	local active = button:GetAttribute("Active")
	if not active then
		return
	end

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

	local nextUseTime = Workspace:GetServerTimeNow() + cooldown

	activeCooldowns[button] = nextUseTime
	button:SetAttribute("Active", false)
	button:SetAttribute("LastUse", Workspace:GetServerTimeNow())
	button:SetAttribute("NextUse", nextUseTime)
end

local function synchronizeCooldowns()
	if next(activeCooldowns) == nil then
		return
	end
	for button, cooldownTime in activeCooldowns do
		if Workspace:GetServerTimeNow() >= cooldownTime then
			button:SetAttribute("Active", true)
			activeCooldowns[button] = nil
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
	if ButtonCooldowns[button] then
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
	print("Event Received and passed")
	createButtonCooldown(button)
	ButtonFunctions.Handler(typeOf)
end

buttonPressEvent.OnServerEvent:Connect(buttonPress)

task.spawn(function()
	while script.Parent do
		synchronizeCooldowns()
		task.wait(0.1)
	end
end)

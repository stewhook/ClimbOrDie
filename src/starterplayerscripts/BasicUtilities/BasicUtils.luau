local Players = game:GetService("Players")
local player = Players.LocalPlayer

local baseServerTime = workspace:GetServerTimeNow()
local baseLocalClock = os.clock()

local module = {}

local function syncTimeManager()
	while script.Parent do
		task.wait(45)
		baseServerTime = workspace:GetServerTimeNow()
		baseLocalClock = os.clock()
	end
end

function module.GetServerTime()
	task.spawn(syncTimeManager)
	return baseServerTime + (os.clock() - baseLocalClock)
end

function module.IsInGame()
	local gameObj = player:FindFirstChild("SessionData"):WaitForChild("InGame")
	if not gameObj then
		return nil
	end
	return gameObj.Value
end

local function calcStroke()
	return workspace.CurrentCamera.ViewportSize.X / 1920
end

function module.strokeSync(father: Instance)
	local val = calcStroke()
	for _, item in father:GetDescendants() do
		if not item:IsA("UIStroke") then
			continue
		end
		item.Thickness = item.Thickness * val
	end
end

return module

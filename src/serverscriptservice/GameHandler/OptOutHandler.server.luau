local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataStore.DataManager)

local optDataEvent: RemoteEvent = ReplicatedStorage.Events.PlayerManagement.OptData

local function adjustTag(player: Player, optedOut)
	if not player then
		return
	end
	local char = player.Character
	if not char then
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	local tag = hrp:FindFirstChildOfClass("BillboardGui")
	if not tag then
		return
	end

	if optedOut then
		tag.BaseFrame.OptOutStatusFrame.Visible = true
	else
		tag.BaseFrame.OptOutStatusFrame.Visible = false
	end
end

local function manageOptOut(player: Player, optedOut)
	if not player then
		return
	end
	DataManager.setValue(player, "OptedOut", optedOut)
	adjustTag(player, optedOut)
end

optDataEvent.OnServerEvent:Connect(manageOptOut)

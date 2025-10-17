local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataStore.DataManager)
local GroupDataCache = require(ServerScriptService.GroupHandler.GroupDataCache)
local module = {}

function module.CollisionGroup(char: Model)
	for _, part in char:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end
		part.CollisionGroup = "Player"
	end
end

local function getTagDetail(groupRank: number)
	if groupRank == 255 then
		return ReplicatedStorage.UIComponents.Utils.Tag.TagDetails.OwnerDetail:Clone()
	elseif groupRank >= 254 then
		return ReplicatedStorage.UIComponents.Utils.Tag.TagDetails.AdminDetail:Clone()
	elseif groupRank > 0 then
		return ReplicatedStorage.UIComponents.Utils.Tag.TagDetails.MemberDetail:Clone()
	else
		return nil
	end
end

function module.BuildTag(player: Player, char: Model)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local profile = DataManager.verifyProfile(player)
	if not profile then
		return
	end

	local groupRank = GroupDataCache.SafeRetrieve(player)
	local tag = ReplicatedStorage.UIComponents.Utils.Tag.PlayerTag:Clone()
	tag.BaseFrame.NameFrame.NameText.Text = player.Name
	local tagDetail = getTagDetail(groupRank)
	if tagDetail then
		tagDetail.Parent = tag.BaseFrame.DetailFrame
	end

	local optedOut = profile.Data.OptedOut

	if optedOut ~= true then
		tag.BaseFrame.OptOutStatusFrame.Visible = false
	end

	tag.Parent = hrp
end

function module.DetectFall(char: Model)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local ragdolling = false

	humanoid.StateChanged:Connect(function(_, newState)
		if
			newState == Enum.HumanoidStateType.FallingDown
		then
			if not ragdolling then
				ragdolling = true
				char:SetAttribute("Ragdolled", true)
			end
		elseif
			ragdolling
			and (
				newState == Enum.HumanoidStateType.GettingUp
				or newState == Enum.HumanoidStateType.Landed
				or newState == Enum.HumanoidStateType.Running
				or newState == Enum.HumanoidStateType.RunningNoPhysics
				or newState == Enum.HumanoidStateType.Swimming
			)
		then
			ragdolling = false
			char:SetAttribute("Ragdolled", false)
		end
	end)
end

function module.HumanoidSetup(char: Model)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid.BreakJointsOnDeath = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
end

return module

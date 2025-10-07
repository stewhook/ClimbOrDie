local module = {}

function module.CollisionGroup(char: Model)
    for _, part in char:GetDescendants() do
        if not part:IsA("BasePart") then continue end
        part.CollisionGroup = "Player"
    end
end

function module.BuildTag(char: Model)
    
end

function module.DetectFall(char: Model)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local ragdolling = false

	humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Ragdoll
		or newState == Enum.HumanoidStateType.FallingDown
		or newState == Enum.HumanoidStateType.PlatformStanding then
			if not ragdolling then
				ragdolling = true
				char:SetAttribute("Ragdolled", true)
			end
		elseif ragdolling and (
			newState == Enum.HumanoidStateType.GettingUp
			or newState == Enum.HumanoidStateType.Landed
			or newState == Enum.HumanoidStateType.Running
			or newState == Enum.HumanoidStateType.RunningNoPhysics
			or newState == Enum.HumanoidStateType.Swimming
		) then
			ragdolling = false
			char:SetAttribute("Ragdolled", false)
		end
	end)
end

return module
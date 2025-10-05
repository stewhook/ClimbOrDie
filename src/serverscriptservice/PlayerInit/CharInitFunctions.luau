local module = {}

function module.CollisionGroup(char: Model)
    for _, part in char:GetDescendants() do
        if not part:IsA("BasePart") then continue end
        part.CollisionGroup = "Player"
    end
end

function module.BuildTag(char: Model)
    
end

return module
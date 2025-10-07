local Workspace = game:GetService("Workspace")
local ImpactFunctions = require(script.Parent.ImpactFunctions)

local fallPartFolder = Workspace:WaitForChild("FallingParts")
local connectionCache = {}

local function createDetection(item: Part)
    print("Creating connection for", item.Name)
    local connection = item:GetAttributeChangedSignal("LastImpact"):Connect(function()
        local impactTime = item:GetAttribute("LastImpact")
        if impactTime > 0 then
            --impact functions go here
            ImpactFunctions.PlaySound(item)
        end
    end)
    connectionCache[item] = connection
end

local function removeDetection(item: Part)
    if connectionCache[item] then
        connectionCache[item]:Disconnect()
        connectionCache[item] = nil
    end
end

local function initializeDetectors()
    for _, item in fallPartFolder:GetChildren() do
        if connectionCache[item] then continue end
        createDetection(item)
    end
end

fallPartFolder.ChildAdded:Connect(createDetection)

fallPartFolder.ChildRemoved:Connect(removeDetection)

initializeDetectors()
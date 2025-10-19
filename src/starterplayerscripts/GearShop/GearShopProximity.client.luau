local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local proxDetection: ProximityPrompt = workspace:WaitForChild("Lobby"):WaitForChild("GearShop"):WaitForChild("GearShopModel"):WaitForChild("ProximityDetection"):WaitForChild("DistanceCheck")

local function getGearUI()
    return player.PlayerGui:FindFirstChild("GearShopUI")
end

proxDetection.PromptShown:Connect(function()
    local gearUI = getGearUI()
    if gearUI then
        return
    end
    local clone = ReplicatedStorage:WaitForChild("UIComponents"):WaitForChild("Utils"):WaitForChild("Gear"):WaitForChild("GearShop"):WaitForChild("GearShopUI"):Clone()
    clone.Parent = player.PlayerGui
end)

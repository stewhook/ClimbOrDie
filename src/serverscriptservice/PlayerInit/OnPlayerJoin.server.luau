local Players = game:GetService("Players")
local CharInitFunctions = require(script.Parent.CharInitFunctions)

local function characterInit(char: Model)
    CharInitFunctions.CollisionGroup(char)
    CharInitFunctions.BuildTag(char) -- not implemented
end

local function playerInit(player: Player)
    player.CharacterAdded:Connect(characterInit)
    -- player functions go below

    

end

Players.PlayerAdded:Connect(playerInit)
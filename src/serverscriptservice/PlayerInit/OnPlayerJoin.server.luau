local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local TimeTracking = require(ServerScriptService.TimeService.TimeTracking)
local CharInitFunctions = require(script.Parent.CharInitFunctions)

local function characterInit(char: Model)
	CharInitFunctions.CollisionGroup(char)
	CharInitFunctions.BuildTag(char) -- not implemented
	CharInitFunctions.DetectFall(char)
end

local function playerInit(player: Player)
	player.CharacterAdded:Connect(characterInit)
	-- player functions go below
	TimeTracking.AddPlayer(player)
end

Players.PlayerAdded:Connect(playerInit)

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local TimeTracking = require(ServerScriptService.TimeService.TimeTracking)
local CharInitFunctions = require(script.Parent.CharInitFunctions)
local PlayerInitFunctions = require(script.Parent.PlayerInitFunctions)

local function characterInit(char: Model, player)
	CharInitFunctions.CollisionGroup(char)
	CharInitFunctions.BuildTag(player, char)
	CharInitFunctions.DetectFall(char)
	PlayerInitFunctions.createSettingsCache(player)
end

local function playerInit(player: Player)
	player.CharacterAdded:Connect(function(char: Model)
		characterInit(char, player)
	end)
	-- player functions go below
	TimeTracking.AddPlayer(player)
end

Players.PlayerAdded:Connect(playerInit)

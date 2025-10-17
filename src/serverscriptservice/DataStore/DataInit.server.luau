local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local DataManager = require(script.Parent.DataManager)
local Template = require(script.Parent.Template)

local function GetStoreName()
	return RunService:IsStudio() and "Test" or "Live"
end


local currentStore = GetStoreName()

local PlayerStore = ProfileStore.New(currentStore, Template)

local function declareLoaded(player: Player)
	local declaration = Instance.new("BoolValue")
	declaration.Name = player.UserId
	declaration.Parent = ReplicatedStorage.Caches.LoadedPlayers
end

-- Add leaderstats and synchronize data locally.
local function initialize(player: Player)
    -- create cache and leaderstats.
    DataManager.isFirstJoin(player)
    DataManager.createLeaderstats(player)
    DataManager.createPlayerCache(player)
    DataManager.createSessionData(player)
	DataManager.createItemCache(player)
    DataManager.updateSessionData(player, "JoinTime", os.time())
	print(DataManager.Profiles[player].Data)
end

-- Creates and stores profile
local function playerAdded(player:Player)
	local profile = PlayerStore:StartSessionAsync("Player_"..player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	
	if profile then
		
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		
		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data Error Occured, Please Rejoin")
		end)
		
		if player.Parent == Players then
			
			DataManager.Profiles[player] = profile
			initialize(player)
			declareLoaded(player)

		else
			profile:EndSession()
		end
		
	else
		player:Kick("Data Error On Load: Please Rejoin")
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(playerAdded, player)
end

Players.PlayerAdded:Connect(playerAdded)

Players.PlayerRemoving:Connect(function(player: Player)
	
	local profile = DataManager.verifyProfile(player)
	if not profile then return end
		
	profile:EndSession()
	DataManager.Profiles[player] = nil
	
end)
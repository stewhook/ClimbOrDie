local ReplicatedStorage = game:GetService("ReplicatedStorage")
local settingsEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Settings")
local settingsSyncEvent: RemoteEvent = settingsEvents:WaitForChild("SettingsSync")

local module = {}

module.Settings = {}

function module.syncSettings()
    settingsSyncEvent:FireServer(module.Settings)
end

return module
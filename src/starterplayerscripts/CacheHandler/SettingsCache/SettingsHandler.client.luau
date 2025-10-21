local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Settings = require(script.Parent.Settings)

local settingsEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Settings")
local settingsInitEvent: RemoteEvent = settingsEvents:WaitForChild("SettingsInit")

settingsInitEvent.OnClientEvent:Connect(function(payload)
	for name, value in payload do
		Settings.Settings[name] = value
	end
end)
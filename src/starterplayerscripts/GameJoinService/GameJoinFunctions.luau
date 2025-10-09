local StarterPlayer = game:GetService("StarterPlayer")
local AlertHandler = require(StarterPlayer.StarterPlayerScripts.FallItemAlertService.AlertHandler)
local ItemAlertKey = require(StarterPlayer.StarterPlayerScripts.FallItemAlertService.ItemAlertKey)
local module = {}

local connection = nil
function module.beginAlertListener()
	if connection then
		return
	end

	local localModelsFolder: Folder = workspace.LocalModels

	local conn = localModelsFolder.ChildAdded:Connect(function(child)
		local alertID = child:GetAttribute("AlertID")
		if not ItemAlertKey[alertID] then
			return
		end
		local alertDetails = ItemAlertKey[alertID]
		AlertHandler.BuildAlert(alertDetails.Title, alertDetails.Sound)
        AlertHandler.HighlightAlert(child)
	end)

	connection = conn
end

function module.closeAlertListener()
	if not connection then
		return
	end
	connection:Disconnect()
	connection = nil
end

return module

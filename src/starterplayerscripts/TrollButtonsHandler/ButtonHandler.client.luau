local ButtonFunctions = require(script.Parent.ButtonFunctions)
local buttonFolder = workspace:WaitForChild("Lobby"):WaitForChild("Buttons")

local function runInit()
	for _, button in buttonFolder:GetChildren() do
		ButtonFunctions.connectButton(button)
		ButtonFunctions.promptDisplayHandler(button)
	end
end

runInit()

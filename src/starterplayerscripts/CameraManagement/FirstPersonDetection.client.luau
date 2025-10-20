local run = game:GetService("RunService")
local players = game:GetService("Players")
local FirstPersonFunctions = require(script.Parent.FirstPersonFunctions)
local player = players.LocalPlayer
local camera = workspace.CurrentCamera

-- State tracking
local isInFirstPerson = false
local currentRenderConnection = nil
local _currentCharacter = nil
local currentHead = nil

local function startFirstPersonDetection(character)
	-- Clean up any existing connection
	if currentRenderConnection then
		currentRenderConnection:Disconnect()
		currentRenderConnection = nil
	end

	-- Update references
	_currentCharacter = character
	currentHead = character:WaitForChild("Head")

	-- Reset state
	isInFirstPerson = false

	-- Start new detection loop
	currentRenderConnection = run.RenderStepped:Connect(function()
		if not currentHead or not currentHead.Parent then
			return -- Character was removed
		end

		local distance = (currentHead.Position - camera.CFrame.Position).Magnitude
		local currentlyInFirstPerson = distance < 1.5

		-- Only call functions when state changes
		if currentlyInFirstPerson ~= isInFirstPerson then
			isInFirstPerson = currentlyInFirstPerson

			if isInFirstPerson then
				FirstPersonFunctions.OnFirstPerson()
			else
				FirstPersonFunctions.OnThirdPerson()
			end
		end
	end)
end

-- Handle initial character spawn
if player.Character then
	startFirstPersonDetection(player.Character)
end

-- Handle respawning
player.CharacterAdded:Connect(function(character)
	startFirstPersonDetection(character)
end)

-- Clean up when player leaves
player.AncestryChanged:Connect(function()
	if not player.Parent then
		if currentRenderConnection then
			currentRenderConnection:Disconnect()
			currentRenderConnection = nil
		end
	end
end)

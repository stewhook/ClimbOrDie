local run = game:GetService("RunService")
local players = game:GetService("Players")
local FirstPersonFunctions = require(script.Parent.FirstPersonFunctions)
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")
local camera = workspace.CurrentCamera

-- State tracking to prevent calling functions every frame
local isInFirstPerson = false

run.RenderStepped:Connect(function()
	local distance = (head.Position - camera.CFrame.Position).Magnitude
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

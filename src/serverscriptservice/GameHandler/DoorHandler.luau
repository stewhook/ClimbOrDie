local ReplicatedStorage = game:GetService("ReplicatedStorage")
TweenService = game:GetService("TweenService")

local doorFolder = workspace.Map.Doors
local doorSounds = ReplicatedStorage.Sounds.AreaSounds.DoorSounds

local function playSoundAtPart(sound, part)
	local clone = sound:Clone()
	if clone.PlayOnRemove == false then
		clone.PlayOnRemove = true
	end
	clone.Parent = part
	clone:Destroy()
end

local function changeCollide(door, value: boolean)
	for _, item in door:GetDescendants() do
		if not item:IsA("BasePart") then
			continue
		end
		item.CanCollide = value
	end
end

local function initializeDoorData()
	local doorData = {}
	for _, door in pairs(workspace.Map.Doors:GetChildren()) do
		doorData[door] = {
			LeftDoorStartPosition = door.LeftDoor.PrimaryPart.CFrame,
			RightDoorStartPosition = door.RightDoor.PrimaryPart.CFrame,
			LeftDoorEndPosition = door.LeftDoor.PrimaryPart.CFrame * CFrame.new(0, 0, -13.5),
			RightDoorEndPosition = door.RightDoor.PrimaryPart.CFrame * CFrame.new(0, 0, 13.5),
			LeftDoorOpen = false,
			RightDoorOpen = false,
		}
	end
	return doorData
end

local doorData = initializeDoorData()

local openTweenDetails = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
local function openDoor(door, halts)
	halts = halts or nil

	if not doorData[door] then
		return
	end

	if doorData[door].LeftDoorOpen == true or doorData[door].RightDoorOpen == true then
		return
	end

	doorData[door].LeftDoorOpen = true
	doorData[door].RightDoorOpen = true
	local leftDoorTween = TweenService:Create(
		door.LeftDoor.PrimaryPart,
		openTweenDetails,
		{ CFrame = doorData[door].LeftDoorEndPosition }
	)
	local rightDoorTween = TweenService:Create(
		door.RightDoor.PrimaryPart,
		openTweenDetails,
		{ CFrame = doorData[door].RightDoorEndPosition }
	)
	playSoundAtPart(doorSounds.HydraulicStart, door.LeftDoor.PrimaryPart)
	playSoundAtPart(doorSounds.HydraulicStart, door.RightDoor.PrimaryPart)
	leftDoorTween:Play()
	rightDoorTween:Play()

	if halts then
		leftDoorTween.Completed:Wait()
		playSoundAtPart(doorSounds.HydraulicStop, door.LeftDoor.PrimaryPart)
		playSoundAtPart(doorSounds.HydraulicStop, door.RightDoor.PrimaryPart)
		changeCollide(door, false)
	else
		changeCollide(door, false)
	end
end

local closeTweenDetails = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local function closeDoor(door, halts)
	halts = halts or nil

	if not doorData[door] then
		return
	end

	if doorData[door].LeftDoorOpen == false or doorData[door].RightDoorOpen == false then
		return
	end
	doorData[door].LeftDoorOpen = false
	doorData[door].RightDoorOpen = false
	local leftDoorTween = TweenService:Create(
		door.LeftDoor.PrimaryPart,
		closeTweenDetails,
		{ CFrame = doorData[door].LeftDoorStartPosition }
	)
	local rightDoorTween = TweenService:Create(
		door.RightDoor.PrimaryPart,
		closeTweenDetails,
		{ CFrame = doorData[door].RightDoorStartPosition }
	)
	playSoundAtPart(doorSounds.HydraulicStart, door.LeftDoor.PrimaryPart)
	playSoundAtPart(doorSounds.HydraulicStart, door.RightDoor.PrimaryPart)
	leftDoorTween:Play()
	rightDoorTween:Play()
	changeCollide(door, true)
	if halts then
		leftDoorTween.Completed:Wait()
		playSoundAtPart(doorSounds.HydraulicStop, door.LeftDoor.PrimaryPart)
		playSoundAtPart(doorSounds.HydraulicStop, door.RightDoor.PrimaryPart)
	end
end

local function initDoorKey()
	local doorKey = {}
	for _, door in pairs(doorFolder:GetChildren()) do
		doorKey[door:GetAttribute("ID")] = door
	end
	return doorKey
end

return {
	DoorKey = initDoorKey(),
	OpenDoor = openDoor,
	CloseDoor = closeDoor,
}

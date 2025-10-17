local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a table to store models with their IDs as keys
local modelDictionary = {}

-- Get the Models folder from ReplicatedStorage
local modelsFolder = ReplicatedStorage:WaitForChild("Models")

if modelsFolder then
	-- Loop through all children in the Models folder
	for _, model in pairs(modelsFolder:GetChildren()) do
		-- Check if the child is a Model and has an ID attribute
		if model then
			local id = model:GetAttribute("ID")
			if id then
				-- Use the ID as the key and the model as the value
				modelDictionary[id] = model
			else
				warn("Model", model.Name, "does not have an ID attribute")
			end
		end
	end
else
	warn("Models folder not found in ReplicatedStorage")
end

-- Export the modelDictionary for use in other scripts
return modelDictionary

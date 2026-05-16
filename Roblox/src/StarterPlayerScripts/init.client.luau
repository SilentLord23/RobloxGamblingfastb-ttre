local Workspace = game:GetService("Workspace")
local physicalButton = Workspace:WaitForChild("PhysicalSpinButton")

-- Debounce ensures the button doesn't trigger multiple times while the player is standing on it
local debounce = false

-- This function handles the logic for the slot machine's duration
local function rollSlots()
	print("Rolling slots...")
end

local function performSpecialTask(otherPart)
	-- Prevents the code from running multiple times during one jump
	if debounce then
		return
	end

	local character = otherPart.Parent
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		debounce = true

		-- Visual feedback: change color and sink the button
		physicalButton.Color = Color3.fromRGB(255, 0, 0)
		physicalButton.Position = physicalButton.Position - Vector3.new(0, 0.2, 0)

		rollSlots()

		-- Reset the button after the buttons function is completed
		physicalButton.Color = Color3.fromRGB(255, 255, 255)
		physicalButton.Position = physicalButton.Position + Vector3.new(0, 0.2, 0)

		debounce = false
	end
end

-- Connect the Touched event to the function
physicalButton.Touched:Connect(performSpecialTask)

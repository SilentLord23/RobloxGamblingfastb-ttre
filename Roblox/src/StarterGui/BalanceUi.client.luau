local ReplicatedStorage = game:GetService("ReplicatedStorage")

local balance = ReplicatedStorage:WaitForChild("GlobalBalance")
local label = script.Parent

local function update()
	print("UI script running")
	label.Text = "Balance: $" .. tostring(balance.Value)
	print(balance.Value)
end

update()

balance.Changed:Connect(update)
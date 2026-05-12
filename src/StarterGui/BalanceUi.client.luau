local ReplicatedStorage = game:GetService("ReplicatedStorage")

local balance = ReplicatedStorage:WaitForChild("GlobalBalance")

local label = script.Parent:WaitForChild("BalanceLabel")

local function update()
	label.Text = "Balance: $" .. balance.Value
end

update()

-- When balance changes call update()
balance:GetPropertyChangedSignal("Value"):Connect(update)

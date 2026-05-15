local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bet = ReplicatedStorage:WaitForChild("GlobalBet")
local label = script.Parent

local function update()
	label.Text = "Bet: $" .. tostring(bet.Value)
end

update()

bet.Changed:Connect(update)
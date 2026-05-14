local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create balance object
local balance = Instance.new("IntValue")
balance.Name = "GlobalBalance"
balance.Value = 1000

balance.Parent = ReplicatedStorage
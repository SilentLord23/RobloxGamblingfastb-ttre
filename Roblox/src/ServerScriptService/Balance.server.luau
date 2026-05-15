local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create balance object
local Balance = Instance.new("IntValue")
Balance.Name = "GlobalBalance"
Balance.Value = 1000

Balance.Parent = ReplicatedStorage

-- Create bet object
local Bet = Instance.new("IntValue")
Bet.Name = "GlobalBet"
Bet.Value = 10

Bet.Parent = ReplicatedStorage

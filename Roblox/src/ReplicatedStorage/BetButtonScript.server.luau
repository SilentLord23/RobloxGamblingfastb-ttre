local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bet = ReplicatedStorage:WaitForChild("GlobalBet")

script.Parent.ProximityPrompt.Triggered:Connect(function(player)
	Bet.Value = script.Parent.Name
end)

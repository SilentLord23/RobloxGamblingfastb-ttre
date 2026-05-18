local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local WinLabel = PlayerGui:WaitForChild("WinGui"):WaitForChild("WinLabel")
local BonusLabel = PlayerGui:WaitForChild("BonusGui"):WaitForChild("BonusLabel")


-- Recieve remoteevent from spinbutton
ReplicatedStorage.ShowWinScreen.OnClientEvent:Connect(function()
	WinLabel.Visible = true
end)

ReplicatedStorage.ShowBonusScreen.OnClientEvent:Connect(function()
	BonusLabel.Visible = true
	task.wait(3)
	BonusLabel.Visible = false
end)

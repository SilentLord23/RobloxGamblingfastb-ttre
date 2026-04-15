local ReplicatedStorage = game:GetService("ReplicatedStorage")
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("SlotMachineGui")

local balanceLabel = screenGui:WaitForChild("BalanceLabel")
local betLabel = screenGui:WaitForChild("CurrentBetLabel")

local function updateUI(balance, bet)
    if balance then
        balanceLabel.Text = string.format("Balance: $%.2f", balance)
    end
    if bet then
        betLabel.Text = string.format("Current Bet: $%.2f", bet)
    end
end

spinRemote.OnClientEvent:Connect(function(action, balance, bet)
    if action == "UpdateDisplay" then
        updateUI(balance, bet)
    end
end)

local initialBalance, initialBet = spinRemote:InvokeServer("GetInit")
if initialBalance and initialBet then
    updateUI(initialBalance, initialBet)
end
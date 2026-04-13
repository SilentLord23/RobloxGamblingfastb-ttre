local ReplicatedStorage = game:GetService("ReplicatedStorage")
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("SlotMachineGui")

local betFrame = screenGui:WaitForChild("BetButtons")
local spinButton = screenGui:WaitForChild("SpinButton")
local balanceLabel = screenGui:WaitForChild("BalanceLabel")
local betLabel = screenGui:WaitForChild("CurrentBetLabel")

local currentBet = 5 
local isSpinning = false

local function updateUI(balance, bet)
    if balance then
        balanceLabel.Text = string.format("Balance: $%.2f", balance)
    end
    if bet then
        betLabel.Text = string.format("Current Bet: $%.2f", bet)
    end
end

local function setButtonsLocked(locked)
    spinButton.Active = not locked
    spinButton.ImageTransparency = locked and 0.5 or 0
    for _, btn in ipairs(betFrame:GetChildren()) do
        if btn:IsA("GuiButton") then
            btn.Active = not locked
            btn.ImageTransparency = locked and 0.5 or 0
        end
    end
end

for _, button in ipairs(betFrame:GetChildren()) do
    if button:IsA("GuiButton") then
        button.MouseButton1Click:Connect(function()
            if isSpinning then return end
            
            currentBet = tonumber(button.Name)
            
            updateUI(nil, currentBet)
            
            spinRemote:InvokeServer("UpdateBet", currentBet)
        end)
    end
end

spinButton.MouseButton1Click:Connect(function()
	if isSpinning or currentBet <= 0 then return end
	
	isSpinning = true
	setButtonsLocked(true)
	
	local board, winnings, newBalance = spinRemote:InvokeServer("Spin", currentBet)
	
	if newBalance then
		updateUI(newBalance, currentBet)
	end
	
	setButtonsLocked(false)
	isSpinning = false
end)

local initialBalance = spinRemote:InvokeServer("GetBalance")
updateUI(initialBalance, currentBet)
spinRemote:InvokeServer("UpdateBet", currentBet)
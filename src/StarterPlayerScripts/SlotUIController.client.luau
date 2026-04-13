local ReplicatedStorage = game:GetService("ReplicatedStorage")
local spinRemote = ReplicatedStorage:WaitForChild("SpinRequest")

local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("SlotMachineGui")
local spinButton = screenGui:WaitForChild("SpinButton")

local isSpinning = false

spinButton.MouseButton1Click:Connect(function()
    if isSpinning then return end
    
    isSpinning = true
    spinButton.AutoButtonColor = false -- Lock the button visually
    spinButton.ImageTransparency = 0.5

    -- Ask the server to run the logic
    local bet = 10 -- Or your selected bet
    local board, winnings = spinRemote:InvokeServer(bet)

    -- Result is back! (Wait for animation to finish)
    task.wait(3) 

    spinButton.ImageTransparency = 0
    spinButton.AutoButtonColor = true
    isSpinning = false
end)
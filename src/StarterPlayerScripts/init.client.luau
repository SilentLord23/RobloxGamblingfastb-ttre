local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("SlotMachineGui")

local spinButton = screenGui.MainFrame.SpinButton

local function performSpecialTask()
    print("Button was pressed")

    spinButton.BackgroundColor3 = Color3.fromRGB(255, 0 , 0)
    task.wait(0.5)
    spinButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
end

spinButton.MouseButton1Click:Connect(performSpecialTask)


print("Hello world, from client!")

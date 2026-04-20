local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local loadingScreen = ReplicatedFirst:FindFirstChild("LoadingScreen")
if loadingScreen then
    loadingScreen = loadingScreen:Clone()
	loadingScreen.IgnoreGuiInset = true
	loadingScreen.Parent = playerGui

	-- Remove the default loading screen
	ReplicatedFirst:RemoveDefaultLoadingScreen()

    -- Find the dots on the loading screen
    local frame = loadingScreen:WaitForChild("Frame")

    local Dot1 = frame:WaitForChild("Dot1")
    local Dot2 = frame:WaitForChild("Dot2")
    local Dot3 = frame:WaitForChild("Dot3")

    -- The styling and duration
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, -1, true)

    -- This code can be refactored for easier reading
    local goal1 = {
        Position = Dot1.Position + UDim2.new(0, 0, 0, -50) -- move up 50 pixels
    }
    local goal2 = {
        Position = Dot2.Position + UDim2.new(0, 0, 0, -50) -- move up 50 pixels
    }
    local goal3 = {
        Position = Dot3.Position + UDim2.new(0, 0, 0, -50) -- move up 50 pixels
    }


    local tweenDot1 = TweenService:Create(Dot1, tweenInfo, goal1)
    local tweenDot2 = TweenService:Create(Dot2, tweenInfo, goal2)
    local tweenDot3 = TweenService:Create(Dot3, tweenInfo, goal3)
    tweenDot1:Play()
    task.wait(0.5)
    tweenDot2:Play()
    task.wait(0.15)
    tweenDot3:Play()

	task.wait(8)  -- Force screen to appear for a minimum number of seconds

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	loadingScreen:Destroy()


    local playButton = player:WaitForChild("PlayerGui"):WaitForChild("MainMenu"):WaitForChild("Play")
    local logo = player:WaitForChild("PlayerGui"):WaitForChild("MainMenu"):WaitForChild("Freddan")
    playButton.Visible = true
    logo.Visible = true
end
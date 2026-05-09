local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local mainMenuCam = game.Workspace:FindFirstChild("mainMenuCamera")
local TimerModule = require(script.Parent:WaitForChild("TimerModule"))

script.Parent.MouseButton1Click:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	script.Parent.Parent.Enabled = false
	TimerModule.startTimer(120)
end)

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local TimerModule = require(player.PlayerScripts:WaitForChild("TimerModule"))


script.Parent.MouseButton1Click:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	script.Parent.Parent.Enabled = false
	TimerModule.startTimer(120)
end)

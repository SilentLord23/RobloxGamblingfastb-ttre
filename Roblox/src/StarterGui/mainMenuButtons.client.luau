local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local TimerModule = require(player.PlayerScripts:WaitForChild("TimerModule"))
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local player = game.Players.LocalPlayer

script.Parent.MouseButton1Click:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	script.Parent.Parent.Enabled = false
	TimerModule.startTimer(5, player)
end)

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local mainMenuCam = game.Workspace:FindFirstChild("mainMenuCamera")

script.Parent.MouseButton1Down:Connect(function()
    
    camera.CameraType = Enum.CameraType.Custom
    script.Parent.Parent.Enabled = false
end)
local camera = game.Workspace.CurrentCamera
local mainMenuCam = game.Workspace:WaitForChild("mainMenuCamera")

if mainMenuCam then
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = mainMenuCam.CFrame
else
    warn("mainMenuCamera not found in Workspace")
end
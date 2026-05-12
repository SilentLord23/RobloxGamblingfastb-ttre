local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FadeModule = require(ReplicatedStorage:WaitForChild("FadeModule"))

local StarterGui = game.StarterGui
local BlackScreen = StarterGui:WaitForChild("FadeGui"):WaitForChild("BlackScreen")
local Ladok = StarterGui:WaitForChild("LadokGui"):WaitForChild("Ladok")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local JumpscareModule = {}

function JumpscareModule.startJumpscare()
	-- play some sound?

	-- fade the screen and teleport the player around in Fnaf
	-- fades mutiple times like fading in and out of consoiuscness
	FadeModule.fadeIn(BlackScreen, 1)
	humanoidRootPart.CFrame = CFrame.new(-207.593, 4.556, 152.364)
	FadeModule.fadeOut(BlackScreen, 0.5)
	task.wait(7)

	FadeModule.fadeIn(BlackScreen, 1.5)
	humanoidRootPart.CFrame = CFrame.new(-155.057, 4.429, 127.462)
	FadeModule.fadeOut(BlackScreen, 3)
	task.wait(5)

	FadeModule.fadeIn(BlackScreen, 1.5)
	humanoidRootPart.CFrame = CFrame.new(-222.115, 4.512, 184.454)
	FadeModule.fadeOut(BlackScreen, 5)
	task.wait(2)

	FadeModule.fadeIn(BlackScreen, 1.5)
	humanoidRootPart.CFrame = CFrame.new(-211.115, 4.555, 184.454)
	FadeModule.fadeOut(BlackScreen, 5)
	task.wait(2)

	for i = 1, 3 do
		FadeModule.fadeIn(BlackScreen, 0.3)
		FadeModule.fadeOut(BlackScreen, 0.3)
	end
	for i = 1, 2 do
		FadeModule.fadeIn(BlackScreen, 0.2)
		FadeModule.fadeOut(BlackScreen, 0.2)
	end
	for i = 1, 5 do
		FadeModule.fadeIn(BlackScreen, 0.1)
		FadeModule.fadeOut(BlackScreen, 0.1)
	end

    -- jumpscare part
    FadeModule.fadeIn(BlackScreen, 0.1)
    Ladok.visible = true
    humanoidRootPart.CFrame = CFrame.new(75.259, 23.759, 150.713)
    task.wait(5)
    FadeModule.fadeOut(Ladok, 1)
    task.wait(0.25)
    FadeModule.fadeOut(BlackScreen, 3)
end

return JumpscareModule
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FadeModule = require(ReplicatedStorage:WaitForChild("FadeModule"))

local JumpscareModule = {}

function JumpscareModule.startJumpscare(player)
	local PlayerGui = player:WaitForChild("PlayerGui")
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local BlackScreen = PlayerGui:WaitForChild("FadeGui"):WaitForChild("BlackScreen")
	local Ladok = PlayerGui:WaitForChild("LadokGui"):WaitForChild("Ladok")
	local BalanceLabel = PlayerGui:WaitForChild("BalanceGui"):WaitForChild("BalanceLabel")
	-- play some sound?

	-- fade the screen and teleport the player around in Fnaf
	-- fades mutiple times like fading in and out of consoiuscness
	FadeModule.fadeIn(BlackScreen, 1)
	task.wait(1)
	humanoidRootPart.CFrame = CFrame.new(-207.593, 4.556, 152.364)
	FadeModule.fadeOut(BlackScreen, 0.5)
	task.wait(7.5)

	FadeModule.fadeIn(BlackScreen, 1.5)
	task.wait(1.5)
	humanoidRootPart.CFrame = CFrame.new(-155.057, 4.429, 127.462)
	FadeModule.fadeOut(BlackScreen, 3)
	task.wait(5)

	FadeModule.fadeIn(BlackScreen, 1.5)
	task.wait(1.5)
	humanoidRootPart.CFrame = CFrame.new(-222.115, 4.512, 184.454)
	FadeModule.fadeOut(BlackScreen, 5)
	task.wait(7)

	FadeModule.fadeIn(BlackScreen, 1.5)
	task.wait(1.5)
	humanoidRootPart.CFrame = CFrame.new(-211.115, 4.555, 184.454)
	FadeModule.fadeOut(BlackScreen, 5)
	task.wait(7)

	for i = 1, 3 do
		FadeModule.fadeIn(BlackScreen, 0.3)
		task.wait(0.3)
		FadeModule.fadeOut(BlackScreen, 0.3)
		task.wait(0.3)
	end
	for i = 1, 2 do
		FadeModule.fadeIn(BlackScreen, 0.2)
		task.wait(0.2)
		FadeModule.fadeOut(BlackScreen, 0.2)
		task.wait(0.2)
	end
	for i = 1, 5 do
		FadeModule.fadeIn(BlackScreen, 0.1)
		task.wait(0.1)
		FadeModule.fadeOut(BlackScreen, 0.1)
		task.wait(0.1)
	end

	-- jumpscare part
	FadeModule.fadeIn(BlackScreen, 0.05)
	task.wait(0.05)
	Ladok.Visible = true
	task.wait(1)
	humanoidRootPart.CFrame = CFrame.new(75.259, 23.759, 150.713)
	task.wait(5)
	Ladok.Visible = false
	task.wait(0.5)
	FadeModule.fadeOut(BlackScreen, 3)
	task.wait(3)
	BalanceLabel.Visible = true
end

return JumpscareModule
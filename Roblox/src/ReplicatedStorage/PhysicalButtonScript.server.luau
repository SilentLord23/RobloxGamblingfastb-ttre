local SlotMachine = require(game.ServerScriptService.SlotMachineModule)
local SlotWinnings = require(game.ServerScriptService.SlotWinningsModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FadeModule = require(ReplicatedStorage:WaitForChild("FadeModule"))
local Balance = ReplicatedStorage:WaitForChild("GlobalBalance")
local Bet = ReplicatedStorage:WaitForChild("GlobalBet")

local isSpinning = false

script.Parent.ProximityPrompt.Triggered:Connect(function(player)
	if isSpinning then
		return
	end
	isSpinning = true

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local PlayerGui = player.PlayerGui
	local BlackScreen = PlayerGui:WaitForChild("FadeGui"):WaitForChild("BlackScreen")

	print("Triggered started")

	if Balance.Value < Bet.Value then
		isSpinning = false
		return
	end

	print("Bet placed")
	Balance.Value -= Bet.Value

	local Board = SlotMachine.GenerateBoard()
	print("Board generated")

	SlotMachine.ShowBoard(Board)
	print("Board shown")

	local WonAmount = SlotWinnings.CalculateWinnings(Board, Bet.Value)

	Balance.Value += WonAmount

	local BonusBoard = nil

	if SlotMachine.CheckBonusSymbol(Board) then
		ReplicatedStorage.ShowBonusScreen:FireClient(player)
		BonusBoard = SlotMachine.AutoBonusSpin()
	end

	if BonusBoard then
		Balance.Value += SlotWinnings.CalculateWinnings(BonusBoard, Bet.Value)
	end

	isSpinning = false

	-- After spin check win/lose conditions.
	if Balance.Value < 5 then
		FadeModule.fadeIn(BlackScreen, 3)
		task.wait(3)
		humanoidRootPart.CFrame = CFrame.new(5, 23.759, 150)
		FadeModule.fadeOut(BlackScreen, 0.5)
		task.wait(0.5)
		-- timer so player can talk to npc, could be remoteevent i think but i don't know how it's 1 am
		task.wait(30)
		player:Kick("You lost! Mr. Kidney collector was done playing with you. Don't gamble.")
	end
	if Balance.Value > 10000 then
		ReplicatedStorage.ShowWinScreen:FireClient(player)
		task.wait(5)
		player:Kick("Thank you for playing, don't fail your courses again!")
	end
end)

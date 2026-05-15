local SlotMachine = require(game.ServerScriptService.SlotMachineModule)
local SlotWinnings = require(game.ServerScriptService.SlotWinningsModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Balance = ReplicatedStorage:WaitForChild("GlobalBalance")
local Bet = ReplicatedStorage:WaitForChild("GlobalBet")

local isSpinning = false

script.Parent.ProximityPrompt.Triggered:Connect(function(player)
	-- lock from spinning during a spin
	if isSpinning then return end
	isSpinning = true

	print("Triggered started")

	if Balance.Value < Bet.Value then
		isSpinning = false
		return
	end

	print("Bet placed")
	Balance.Value -= Bet.Value

	-- spin
	local Board = SlotMachine.GenerateBoard()
	print("Board generated")
	SlotMachine.ShowBoard(Board)
	print("Board shown")

	-- update balance
	Balance.Value += SlotWinnings.CalculateWinnings(Board, Bet.Value)

	local BonusBoard = nil
	if SlotMachine.CheckBonusSymbol(Board) then
		BonusBoard = SlotMachine.AutoBonusSpin()
	end

	if BonusBoard then
		Balance.Value += SlotWinnings.CalculateWinnings(BonusBoard, Bet.Value)
	end

	isSpinning = false
end)
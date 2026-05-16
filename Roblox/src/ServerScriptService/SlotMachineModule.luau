local SlotMachineModule = {}

local gridFolder = workspace:WaitForChild("Grid")

type Symbol = {
	id: number,
	weight: number,
}
local row = 3
local col = 5
type SymbolList = { Symbol }
type Matrix = { { number } }

-- All possible symbols in the slot machine
-- Higher weight = higher probability of being selected so 1 is most common and 9 least common
-- For Fredrik. This is an array with objects, i was just stupid and drunk...
local symbolsList: SymbolList = {
	{ id = 1, weight = 6 },
	{ id = 2, weight = 6 },
	{ id = 3, weight = 5 },
	{ id = 4, weight = 5 },
	{ id = 5, weight = 4 },
	{ id = 6, weight = 4 },
	{ id = 7, weight = 3 },
	{ id = 8, weight = 3 },
	{ id = 9, weight = 2 },
	{ id = 10, weight = 1 }, -- bonus symbol
}

local bonusSymbolsList: SymbolList = {
	{ id = 9, weight = 3 },
	{ id = 10, weight = 1 },
	{ id = 11, weight = 25 },
}

function SlotMachineModule.GenerateBoard()
	-- comments for you Fredrik, some may be unnecessary.
	-- Edgar ask fredrik for context
	local Board = { {} }

	-- get the total weight of all symbols
	local totalWeight = 0
	for _, symbol in ipairs(symbolsList) do
		totalWeight += symbol.weight
	end

	-- For each grid spot
	for i = 1, row do
		Board[i] = {}

		for j = 1, col do
			local pickedSymbol = 0
			-- Generate a float between 0 and 1 and multply with totalweight
			-- This gives us a number between 0 and totalweight
			-- ex. 0.45 * 200 = 90
			local randomSymbol = math.random() * totalWeight
			local symbolSum = 0

			-- Go trough our list of symbols and for each add it to sum
			-- then check if sum is greater than or equal
			-- ex first weight 40, sum 40 < 90
			-- second weight 30, sum 70 < 90
			-- third weight 20, sum 90 = 90
			-- therefore we have reached our symbol no 3

			-- This can be made in a similiar system by creating an array
			-- with 40 of first symbol, 30 of next, 20 and so on and then
			-- choosing a random symbol in that array
			-- Hopefully you understand now
			for _, symbol in ipairs(symbolsList) do
				symbolSum += symbol.weight
				if randomSymbol <= symbolSum then
					pickedSymbol = symbol.id
					break
				end
			end

			Board[i][j] = pickedSymbol
		end
	end

	return Board
end

function SlotMachineModule.GenerateBonusBoard()
	-- comments for you Fredrik, some may be unnecessary.
	-- Edgar ask fredrik for context
	local Board = { {} }

	-- get the total weight of all symbols
	local totalWeight = 0
	for _, symbol in ipairs(bonusSymbolsList) do
		totalWeight += symbol.weight
	end

	-- For each grid spot
	for i = 1, row do
		Board[i] = {}

		for j = 1, col do
			local pickedSymbol = ""
			-- Generate a float between 0 and 1 and multply with totalweight
			-- This gives us a number between 0 and totalweight
			-- ex. 0.45 * 200 = 90
			local randomSymbol = math.random() * totalWeight
			local symbolSum = 0

			-- Go trough our list of symbols and for each add it to sum
			-- then check if sum is greater than or equal
			-- ex first weight 40, sum 40 < 90
			-- second weight 30, sum 70 < 90
			-- third weight 20, sum 90 = 90
			-- therefore we have reached our symbol no 3

			-- This can be made in a similiar system by creating an array
			-- with 40 of first symbol, 30 of next, 20 and so on and then
			-- choosing a random symbol in that array
			-- Hopefully you understand now
			for _, symbol in ipairs(bonusSymbolsList) do
				symbolSum += symbol.weight
				if randomSymbol <= symbolSum then
					pickedSymbol = symbol.id
					break
				end
			end

			Board[i][j] = pickedSymbol
		end
	end

	return Board
end

function SlotMachineModule.ShowBoard(board)
	for i = 1, row do
		for j = 1, col do
			local value = board[i][j]

			local partName = "Cell_" .. i .. "_" .. j
			local part = gridFolder:FindFirstChild(partName)

			if part then
				-- Change color depending on number
				part.Color = Color3.fromHSV(value / 9, 1, 1)
				-- Show number on the part
				local surfaceGui = part:FindFirstChild("SurfaceGui")
				if surfaceGui then
					local label = surfaceGui:FindFirstChild("TextLabel")
					if label then
						label.Text = tostring(value)
					end
				end
			end
		end
	end
end

function SlotMachineModule.CheckBonusSymbol(board)
	local BonusCounter = 0
	for i = 1, row do
		for j = 1, col do
			if board[i][j] == 10 then
				BonusCounter += 1
			end
		end
	end
	if BonusCounter >= 3 then
		return true
	else
		return false
	end
end

function SlotMachineModule.AutoBonusSpin()
	local bonusSpins = 5

	-- do 1 spin with the bonus spin symbols
	local board = SlotMachineModule.GenerateBonusBoard()
	-- show the board
	SlotMachineModule.ShowBoard(board)
	task.wait(3)
	-- give bonus spins for bonus symbol
	-- remove bonus symbols before next spin
	for i = 1, row do
		for j = 1, col do
			if board[i][j] == 10 then
				bonusSpins += 1
				board[i][j] = 11
			end
		end
	end

	bonusSpins -= 1

	-- do another spin but this time compare the symbols given
	-- if a better symbol update the position
	while bonusSpins > 0 do
		local newBoard = SlotMachineModule.GenerateBonusBoard()
		for i = 1, row do
			for j = 1, col do
				if newBoard[i][j] < board[i][j] then
					if newBoard[i][j] == 10 then
						bonusSpins += 1
						board[i][j] = 11
					end
					board[i][j] = newBoard[i][j]
				end
			end
		end
		SlotMachineModule.ShowBoard(board)
		task.wait(3)
		bonusSpins -= 1
	end
	return board
end

return SlotMachineModule

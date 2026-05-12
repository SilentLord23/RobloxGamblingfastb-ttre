local ServerScriptService = game:GetService("ServerScriptService")
local symbVal = require(ServerScriptService:WaitForChild("symbVal"))
type Matrix = { { number } }

local function unweightedSpin(arr: Matrix)
	for i = 1, 3 do
		arr[i] = {}

		for j = 1, 5 do
			arr[i][j] = Random.NextInteger(1, 9)
		end
	end
end

local function GenerateBoard(symbols)
	local Board = { {} }

	local totalWeight = 0

	for _, symbol in ipairs(symbols) do
		totalWeight += symbols.weight
	end

	for i = 1, 3 do
		Board[i] = {}

		for j = 1, 5 do
			local pickedSymbol = ""
			local rng = math.random() * totalWeight
			local sum = 0

			for _, symbol in ipairs(symbols) do
				sum += symbol.weight
				if rng <= sum then
					pickedSymbol = symbol.id
					return
				end
			end

			Board[i][j] = pickedSymbol
		end
	end

	return Board
end

local function autoBonusSpin()
	local bonusSpins = 5

	-- do 1 spin with the bonus spin symbols
	local board = GenerateBoard(symbVal.bonusSymbols)
	-- show the board
	showBoard()
	-- give bonus spins for bonus symbol
    -- remove bonus symbols before next spin
	for i = 1, 3 do
        for j = 1,5 do
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
        local newBoard = GenerateBoard(symbVal.bonusSymbols)
        for i = 1, 3 do
        for j = 1,5 do
            if board[i][j] > newBoard[i][j] then
                if newBoard[i][j] == 10 then
                    bonusSpins += 1
                    board[i][j] = 11
                end
                else
                    board[i][j] = newBoard[i][j]
                end
            end
	    end
        showBoard()
        bonusSpins -= 1
    end

end

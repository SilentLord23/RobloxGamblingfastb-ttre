local gridFolder = workspace.Grid

type Symbol = {
	id: number,
	weight: number,
}
type SymbolList = { Symbol }

-- All possible symbols in the slot machine
-- Higher weight = higher probability of being selected so 1 is most common and 9 least common
-- For Fredrik. This is an array with objects, i was just stupid and drunk...
local symbolsList: SymbolList = {
	{ id = 1, weight = 40 },
	{ id = 2, weight = 40 },
	{ id = 3, weight = 40 },
	{ id = 4, weight = 30 },
	{ id = 5, weight = 30 },
	{ id = 6, weight = 7 },
	{ id = 7, weight = 7 },
	{ id = 8, weight = 5 },
	{ id = 9, weight = 2 },
}

local bonusSymbolsList: SymbolList = {
	{ id = 9, weight = 5 },
	{ id = 10, weight = 1 }, -- bonus symbol
	{ id = 11, weight = 19 }, -- nothing
}


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
	-- comments for you Fredrik, some may be unnecessary. 
	-- Edgar ask fredrik for context
	local Board = { {} }

	-- get the total weight of all symbols
	local totalWeight = 0
	for _, symbol in ipairs(symbols) do
		totalWeight += symbol.weight
	end

	-- For each grid spot
	for i = 1, 3 do
		Board[i] = {}

		for j = 1, 5 do
			local pickedSymbol = ""
			-- Generate a float between 0 and 1 and multply with totalweight
			-- This gives us a number between 0 and totalweight
			-- ex. 0.45 * 200 = 90
			local rng = math.random() * totalWeight
			local sum = 0

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

local function showBoard(board)
	for i = 1, 3 do
		for j = 1, 5 do
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

showBoard(GenerateBoard(symbolsList))
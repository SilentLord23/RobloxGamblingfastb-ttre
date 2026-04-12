type Matrix = {{number}}

local function unweightedSpin (arr: Matrix)
    
    for i = 1, 3 do
        arr[i] = {}

        for j = 1, 5 do
            arr[i][j] = Random.NextInteger(1, 9)
        end
    end

end

local function GenerateBoard (symbols: SymbolList)
    local Board = {{}}

    local totalWeight = 0

    for _, symbol in ipairs(symbols) do
        totalWeight += symbols.weight
    end

    for i = 1, 3 do
        Board[i] = {}

        for j = 1, 5 do
            local pickedSymbol = string
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

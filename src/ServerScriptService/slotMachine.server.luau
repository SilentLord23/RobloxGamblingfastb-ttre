type Matrix = {{number}}

local function unweightedSpin (arr: Matrix)
    
    for i = 1, 3 do
        arr[i] = {}

        for j = 1, 5 do
            arr[i][j] = Random.NextInteger(1, 9)
        end
    end

end
    
-- TODO
-- Define a symbollist

local function weightedSpin (arr: Matrix, symbols: SymbolList)
    
    local totalWeight = 0

    for _, symbol in ipairs(symbols) do
        totalWeight += symbols.weight
    end

    local rng = math.random() * totalWeight
    local sum = 0

    for _, symbol in ipairs(symbols) do
        sum += symbol.weight
        if rng <= sum then
            return symbol.id
        end
    end

end
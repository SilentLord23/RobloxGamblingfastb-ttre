type Symbol = {
	id: number,
	weight: number,
}

-- An array of Symbol objects
type SymbolList = { Symbol }

-- All possible symbols in the slot machine
-- Higher weight = higher probability of being selected
local symbols: SymbolList = {
	{ id = 1, weight = 40 },
	{ id = 2, weight = 30 },
	{ id = 3, weight = 25 },
	{ id = 4, weight = 25 },
	{ id = 5, weight = 20 },
	{ id = 6, weight = 20 },
	{ id = 7, weight = 15 },
	{ id = 8, weight = 10 },
	{ id = 9, weight = 5 },
}

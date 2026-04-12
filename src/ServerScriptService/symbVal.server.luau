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
	{ id = 2, weight = 40 },
	{ id = 3, weight = 40 },
	{ id = 4, weight = 30 },
	{ id = 5, weight = 30 },
	{ id = 6, weight = 7 },
	{ id = 7, weight = 7 },
	{ id = 8, weight = 5 },
	{ id = 9, weight = 2 },
}

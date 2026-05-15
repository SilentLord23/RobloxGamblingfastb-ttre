// slotWinnings.cpp
// Purpose: compute winnings for a slot machine board using predefined paylines and a paytable.
// Notes:
//  - payLines: defines which positions (col,row) form each winning line across the 5 reels.
//  - payTable: multipliers for symbol IDs based on number of consecutive matches (3..5).
//  - calculateWinnings scans each payline from the left-most reel and counts consecutive
//    matching symbols; only runs of length >= 3 are paid according to the payTable.
//  - For extendability, consider making SlotWinnings an instance that takes payLines/payTable
//    as constructor parameters rather than hardcoding here.

#include <vector>
#include <map>
#include "window.h"
#include "slotWinnings.hpp"

// Coordinate pair representing a reel column and row within a 3x5 board.
struct Coord {
    int col; // reel index (0..4)
    int row; // row index (0..2)
};

// Engine that knows paylines and paytable and can compute winnings for a given board.
class SlotWinnings {
    
public:
    // Each payline is a vector of 5 coordinates (one per reel). Coordinates are {col, row}.
    // The order in the vector represents the left-to-right order of reels for matching.
    std::vector<std::vector<Coord>> payLines = {
        {{0,0}, {1,0}, {2,0}, {3,0}, {4,0}},
        {{0,1}, {1,1}, {2,1}, {3,1}, {4,1}},
        {{0,2}, {1,2}, {2,2}, {3,2}, {4,2}},
        {{0,0}, {1,1}, {2,2}, {3,1}, {4,0}},
        {{2,0}, {1,1}, {0,2}, {3,1}, {4,0}},
        {{0,1}, {1,0}, {2,0}, {3,0}, {4,1}},
        {{0,1}, {1,2}, {2,2}, {3,2}, {4,1}},
        {{0,0}, {1,0}, {2,1}, {3,2}, {4,2}},
        {{0,2}, {1,2}, {2,1}, {3,0}, {4,0}},
        {{0,1}, {1,2}, {2,1}, {3,0}, {4,1}},
        {{0,1}, {1,0}, {2,1}, {3,2}, {4,1}}
    };

    // Paytable mapping: symbol ID -> (matchCount -> multiplier)
    // Example: payTable[9][5] == 100.0 means symbol 9 with 5 matches pays 100x the bet.
    std::map<int, std::map<int, double>> payTable = {
        {1, {{3, 0.1}, {4, 0.5}, {5, 2.0}}},
        {2, {{3, 0.1}, {4, 0.5}, {5, 2.0}}},
        {3, {{3, 0.1}, {4, 0.5}, {5, 2.0}}},
        {4, {{3, 0.1}, {4, 0.8}, {5, 3.0}}},
        {5, {{3, 0.1}, {4, 0.8}, {5, 3.0}}},
        {6, {{3, 0.6}, {4, 2.0}, {5, 15.0}}},
        {7, {{3, 0.6}, {4, 2.0}, {5, 15.0}}},
        {8, {{3, 0.8}, {4, 8.0}, {5, 40.0}}},
        {9, {{3, 2.0}, {4, 20.0}, {5, 100.0}}}
    };

    // Calculate winnings for a given 3x5 board and current bet.
    // Algorithm:
    //  - For each payline, take the symbol at the first coordinate as the reference (leftmost reel).
    //  - Count how many consecutive positions along that line match the reference symbol.
    //  - If the run length is >= 3 and an entry exists in payTable for that symbol and run length,
    //    add currentBet * multiplier to totalWinnings.
    // Returns the total winnings (sum across all paylines) as a double.
    double calculateWinnings(const std::vector<std::vector<int>>& board, double currentBet) {
        double totalWinnings = 0;

        for (const auto& line : payLines) {
            int firstSymbol = board[line[0].row][line[0].col];
            int matchCount = 1;

            for (size_t i = 1; i < line.size(); ++i) {
                if (board[line[i].row][line[i].col] == firstSymbol) {
                    matchCount++;
                } else {
                    break; // stop counting on first mismatch (only consecutive left-to-right matches pay)
                }
            }

            // Only pay when 3 or more consecutive symbols match from the left.
            if (matchCount >= 3) {
                if (payTable.count(firstSymbol) && payTable[firstSymbol].count(matchCount)) {
                    totalWinnings += (currentBet * payTable[firstSymbol][matchCount]);
                }
            }
        }

        return totalWinnings;
    }
};

// Thin wrapper used by the rest of the native code to compute winnings.
// Constructs a SlotWinnings engine (stateless) and delegates the calculation.
// Note: constructing the engine per-call is inexpensive here, but if payLines/payTable become large
// or configurable at runtime, consider reusing a single engine instance.

double calculate(const std::vector<std::vector<int>>& board, double bet) {
    SlotWinnings engine;
    return engine.calculateWinnings(board, bet);
}
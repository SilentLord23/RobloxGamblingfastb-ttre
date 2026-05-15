// bonusFunction.cpp
// Purpose: helper routines for a bonus/feature mechanic used by the slot machine.
// Expected constants (defined in bonusFunction.hpp):
//  - BONUS_SYMBOL : symbol id used to mark bonus-triggering symbols
//  - HIGH_SYMBOL  : symbol id representing a high-value (locked) symbol
//  - EMPTY_SYMBOL : symbol id for an empty/low-value result
// Notes:
//  - The RNG is seeded once using the current time via a static mt19937 generator. For
//    reproducible testing, consider providing a seed or exposing the generator.
//  - These functions operate on a 3x5 board (rows x cols) and a 'locked' boolean matrix
//    that indicates which positions have been locked in the bonus feature.
//  - Thread-safety: functions are not synchronized. If called from multiple threads,
//    protect shared data externally.

#include "bonusFunction.hpp"
#include <random>
#include <ctime>

int countBonusSymbols(const std::vector<std::vector<int>>& board) {
    int count = 0;
    for (const auto& row : board) {
        for (int symbol : row) {
            // Count how many BONUS_SYMBOLs are present on the board.
            if (symbol == BONUS_SYMBOL) {
                count++;
            }
        }
    }
    return count;
}

// Perform a single bonus roll that updates the board and locked matrix, and increments
// the available spins when new bonus symbols are found.
// Parameters:
//  - board: mutable 3x5 board to be updated in-place
//  - locked: 3x5 boolean matrix; positions set to true remain locked and are forced to HIGH_SYMBOL
//  - spins: reference to an int representing remaining bonus spins; increments when BONUS_SYMBOL occurs
// Behavior details:
//  - For each unlocked position, a random roll decides whether it becomes HIGH_SYMBOL (15%),
//    BONUS_SYMBOL (5%), or EMPTY_SYMBOL (the remainder).
//  - When a position becomes HIGH_SYMBOL it is marked locked so future rolls keep it as HIGH_SYMBOL.
void performBonusRoll(std::vector<std::vector<int>>& board, bool locked[3][5], int& spins) {
    // Static generator seeded once. Using time-based seeding means non-deterministic runs.
    static std::mt19937 gen(static_cast<unsigned int>(std::time(nullptr)));
    std::uniform_int_distribution<> dis(1, 100);

    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 5; j++) {
            if (locked[i][j]) {
                // Locked positions remain high-value symbols.
                board[i][j] = HIGH_SYMBOL;
                continue;
            }

            int rng = dis(gen);
            
            if (rng <= 15) {
                // 15% chance: becomes a high-value symbol and gets locked.
                board[i][j] = HIGH_SYMBOL;
                locked[i][j] = true;
            } else if (rng <= 20) {
                // Next 5% chance: becomes a bonus symbol and awards an extra spin.
                board[i][j] = BONUS_SYMBOL;
                spins++;
            } else {
                // Remaining chance: empty/low-value symbol.
                board[i][j] = EMPTY_SYMBOL;
            }
        }
    }
}

// Check whether all positions are locked — typically used to determine jackpot conditions.
// Returns true if every entry in the locked matrix is true.
bool checkJackpot(bool locked[3][5]) {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 5; j++) {
            if (!locked[i][j]) {
                return false;
            }
        }
    }
    return true;
}
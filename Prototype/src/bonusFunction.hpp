// bonusFunction.hpp
// Purpose: Declarations for helper routines used by the slot machine bonus feature.
// Expectations:
//  - The board argument used throughout is a 3x5 grid represented as a vector of rows,
//    indexed as board[row][col] where row in [0..2] and col in [0..4].
//  - Constants below represent special symbol IDs used during bonus mechanics.
// Threading/Determinism:
//  - The corresponding implementation uses a time-seeded RNG by default; for deterministic
//    behavior in tests, consider seeding the RNG explicitly or exposing a seed parameter.

#ifndef BONUS_FUNCTION_HPP
#define BONUS_FUNCTION_HPP

#include <vector>

// Symbol IDs used by bonus logic:
// BONUS_SYMBOL: when present on the board, it typically awards extra bonus spins.
// HIGH_SYMBOL: used to represent a locked/high-value symbol during the bonus rounds.
// EMPTY_SYMBOL: placeholder or low-value symbol when neither bonus nor high symbol occurs.
const int BONUS_SYMBOL = 10;
const int HIGH_SYMBOL = 9;
const int EMPTY_SYMBOL = 0;

// Count how many bonus symbols are present on the board.
// board: 3x5 grid (board[row][col])
// returns: number of entries equal to BONUS_SYMBOL
int countBonusSymbols(const std::vector<std::vector<int>>& board);

// Perform a bonus roll that updates the board and locked positions in-place.
// Parameters:
//  - board: mutable 3x5 board to be updated by the roll
//  - locked: 3x5 boolean matrix indicating which positions are locked; locked positions
//            will be forced to HIGH_SYMBOL and remain locked across rolls
//  - spins: reference to an int tracking remaining bonus spins; incremented when
//           new BONUS_SYMBOLs are generated
// Behavior:
//  - The implementation will typically randomize unlocked positions, setting them to
//    HIGH_SYMBOL, BONUS_SYMBOL (and incrementing spins), or EMPTY_SYMBOL based on
//    configured probabilities.
void performBonusRoll(std::vector<std::vector<int>>& board, bool locked[3][5], int& spins);

// Check whether all positions are locked (e.g., jackpot condition).
// Returns true if every entry in `locked` is true.
bool checkJackpot(bool locked[3][5]);

#endif
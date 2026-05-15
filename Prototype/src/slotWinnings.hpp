// slotWinnings.hpp
// Purpose: Declare the winnings calculation function used by the native slot engine.
// Notes:
//  - The board argument is expected to be a 3x5 grid represented as a vector of rows,
//    indexed as board[row][col] where row in [0..2] and col in [0..4].
//  - The bet argument is the current bet amount; the returned value is the total payout
//    (can be 0.0 if no winning combinations are present).
//  - The implementation is provided in slotWinnings.cpp. The function is stateless and
//    safe to call concurrently as long as the board passed in is not being modified.

#ifndef SLOT_WINNINGS_HPP
#define SLOT_WINNINGS_HPP

#include <vector>

// Calculate total winnings for a given slot board and bet.
// board: 3x5 grid indexed as board[row][col]
// bet: current bet amount; return value is total payout amount (may be 0.0)
// Implemented in slotWinnings.cpp
double calculate(const std::vector<std::vector<int>>& board, double bet);

#endif
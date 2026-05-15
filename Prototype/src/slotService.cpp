// slotService.cpp
// JNI bridge implementing the native slot machine backend exposed to Java.
// Purpose: handle spins, bets, balance, and a bonus feature; expose a simple API to slotLogic.java.
// Important notes:
//  - This module uses process-global state for simplicity. If multiple independent games are
//    required, refactor to an instance-based approach.
//  - Access to global state is NOT synchronized. If Java code may call these methods from
//    multiple threads, add synchronization to avoid races.
//  - RNG is seeded once using the current time (see generator below). For deterministic
//    behavior in tests, provide an explicit seed mechanism.

#include <jni.h>
#include <vector>
#include <random>
#include <ctime>
#include "slotLogic.h"
#include "bonusFunction.hpp"

// External declarations for other parts of the engine
bool loadInternalAssets();
double calculate(const std::vector<std::vector<int>>& board, double bet);

// Global native state. These variables persist for the lifetime of the native library.
// NOTE: Because these are global and unsynchronized, concurrent access from multiple threads
// may produce data races. Protect with mutexes if you intend to call from multiple threads.
static double g_balance = 1000.0;
static int g_betIndex = 1;
static std::vector<int> g_bets = {5, 10, 15, 20, 25, 50, 75, 100, 250, 500};
static std::vector<std::vector<int>> g_lastBoard(3, std::vector<int>(5, 0));

// Bonus-related state:
//  - g_inBonusMode: whether a bonus session is active
//  - g_bonusSpins: remaining bonus spin count
//  - g_locked: matrix marking positions locked during the bonus (true => locked/high-symbol)
// Initialize locked to false for all positions by default.
static bool g_inBonusMode = false;
static int g_bonusSpins = 0;
static bool g_locked[3][5] = {false};

extern "C" {

// Loads native assets via loadInternalAssets().
// Returns JNI_TRUE if assets loaded successfully, JNI_FALSE otherwise.
JNIEXPORT jboolean JNICALL Java_slotLogic_loadAssets(JNIEnv *env, jobject obj) {
    return (jboolean)loadInternalAssets();
}

// Return the current player balance as a double.
// This is a quick accessor; callers should not assume atomicity across multiple calls.
JNIEXPORT jdouble JNICALL Java_slotLogic_getBalance(JNIEnv *env, jobject obj) {
    return (jdouble)g_balance;
}

// Return the current bet amount (from g_bets at g_betIndex).
JNIEXPORT jdouble JNICALL Java_slotLogic_getCurrentBet(JNIEnv *env, jobject obj) {
    return (jdouble)g_bets[g_betIndex];
}

// Advance to next bet option. Betting is locked while in a bonus session to avoid
// inconsistencies between spins and bonus resolution.
JNIEXPORT void JNICALL Java_slotLogic_nextBet(JNIEnv *env, jobject obj) {
    if (!g_inBonusMode) { // Lock betting during bonus
        g_betIndex = (g_betIndex + 1) % g_bets.size();
    }
}

// Perform a spin. Behavior depends on whether a bonus session is active:
//  - Normal play: deducts bet from balance, randomizes g_lastBoard, checks bonus trigger,
//    computes line wins via calculate(), updates balance, and returns win amount.
//    Returns -1.0 if balance is insufficient to place the bet.
//  - Bonus play: consumes one bonus spin, runs performBonusRoll() to update board and locked
//    positions, and returns 0.0 because bonus payout is deferred until finalizeBonus().
JNIEXPORT jdouble JNICALL Java_slotLogic_spin(JNIEnv *env, jobject obj) {
    static std::mt19937 gen(static_cast<unsigned int>(std::time(nullptr)));
    double currentBet = (double)g_bets[g_betIndex];

    if (!g_inBonusMode) {
        // --- NORMAL SPIN LOGIC ---
        if (g_balance < currentBet) return -1.0;
        g_balance -= currentBet;

        std::uniform_int_distribution<> dis(1, 100);
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 5; j++) {
                int rng = dis(gen);
                // 5% chance to land a bonus symbol in normal play
                if (rng <= 5) g_lastBoard[i][j] = BONUS_SYMBOL;
                else g_lastBoard[i][j] = (rng % 9) + 1;
            }
        }

        // Check for Bonus Trigger
        int triggerCount = countBonusSymbols(g_lastBoard);
        if (triggerCount >= 3) {
            g_inBonusMode = true;
            g_bonusSpins = 5 + (triggerCount - 3); // 3=5, 4=6, 5=7...
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 5; j++) g_locked[i][j] = false;
            }
        }

        double win = calculate(g_lastBoard, currentBet);
        g_balance += win;
        return (jdouble)win;

    } else {
        // --- BONUS SPIN LOGIC ---
        // Consume a bonus spin and update board/locked positions. Bonus payouts are
        // awarded when the Java side calls finalizeBonus().
        g_bonusSpins--;
        performBonusRoll(g_lastBoard, g_locked, g_bonusSpins);
        return 0.0; // Bonus spins don't pay out until finalized
    }
}

// Finalize the bonus session and compute the total bonus payout.
// If all positions become locked (jackpot), a large fixed payout is awarded; otherwise
// winnings are computed using the normal calculate() routine. This clears the bonus flag.
JNIEXPORT jdouble JNICALL Java_slotLogic_finalizeBonus(JNIEnv *env, jobject obj) {
    double currentBet = (double)g_bets[g_betIndex];
    double totalWin = 0;

    if (checkJackpot(g_locked)) {
        totalWin = currentBet * 1000.0;
    } else {
        totalWin = calculate(g_lastBoard, currentBet);
    }

    g_balance += totalWin;
    g_inBonusMode = false;
    return (jdouble)totalWin;
}

// Query whether a bonus session is currently active.
JNIEXPORT jboolean JNICALL Java_slotLogic_isBonusActive(JNIEnv *env, jobject obj) {
    return (jboolean)g_inBonusMode;
}

// Return remaining bonus spins (0 if none).
JNIEXPORT jint JNICALL Java_slotLogic_getBonusSpins(JNIEnv *env, jobject obj) {
    return (jint)g_bonusSpins;
}

// Return the last board as a Java 2D int array. The native code creates new Java arrays
// and copies values from g_lastBoard. Local references (row arrays) are deleted after use
// to avoid exhausting the local reference table.
JNIEXPORT jobjectArray JNICALL Java_slotLogic_getLastBoard(JNIEnv *env, jobject obj) {
    jclass intArrayClass = env->FindClass("[I");
    jobjectArray board = env->NewObjectArray(3, intArrayClass, nullptr);
    for (int i = 0; i < 3; i++) {
        jintArray row = env->NewIntArray(5);
        jint temp[5];
        for (int j = 0; j < 5; j++) temp[j] = (jint)g_lastBoard[i][j];
        env->SetIntArrayRegion(row, 0, 5, temp);
        env->SetObjectArrayElement(board, i, row);
        env->DeleteLocalRef(row);
    }
    return board;
}

// Force entry into bonus mode (used for testing or special events). This resets the bonus
// structures and sets a preset number of bonus spins.
JNIEXPORT void JNICALL Java_slotLogic_forceBonus(JNIEnv *env, jobject obj) {
    g_inBonusMode = true;
    g_bonusSpins = 8;
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 5; j++) {
            g_locked[i][j] = false;
            g_lastBoard[i][j] = 0;
        }
    }
}

}
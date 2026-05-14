// slotService.cpp
// JNI bridge: implements native methods declared by slotLogic.java
// Purpose: provide a simple native slot machine backend and expose it to Java.
// Important notes:
//  - This file contains process-global state (balance, bet index, last board). If the
//    library is used from multiple Java threads, access should be synchronized.
//  - RNG is seeded once using current time; for reproducible behavior provide an explicit seed.
//  - JNI functions must manage local references and check for exceptions after JNI calls.
//  - Return values use simple conventions (e.g., spin returns -1.0 when balance is insufficient).

#include <jni.h>
#include <vector>
#include <random>
#include <ctime>
#include "slotLogic.h"

// Forward declarations from other compilation units
// loadInternalAssets: loads textures/assets required by the native code.
// calculate: computes the payout given the board and bet.
bool loadInternalAssets();
double calculate(const std::vector<std::vector<int>>& board, double bet);

// Global native state. These are process-wide and persist for the lifetime of the native library.
// If you need multiple independent game instances, refactor to use an instance-based design.
static double g_balance = 1000.0; // Current player balance
static int g_betIndex = 1;        // Index into bet table
static std::vector<int> g_bets = {5, 10, 15, 20, 25, 50, 75, 100, 250, 500};
// Last board is a 3x5 grid of symbol IDs (values 1..9)
static std::vector<std::vector<int>> g_lastBoard(3, std::vector<int>(5));

extern "C" {

// JNI wrapper: loads internal assets. Returns JNI_TRUE on success, JNI_FALSE on failure.
// Behavior: delegates to loadInternalAssets() implemented elsewhere.
JNIEXPORT jboolean JNICALL Java_slotLogic_loadAssets(JNIEnv *env, jobject obj) {
    // If loadInternalAssets throws/captures errors, consider translating them to Java exceptions.
    return (jboolean)loadInternalAssets();
}

// Returns the current balance as a double.
// Note: no synchronization is performed; if multiple threads can change balance, protect access.
JNIEXPORT jdouble JNICALL Java_slotLogic_getBalance(JNIEnv *env, jobject obj) {
    return (jdouble)g_balance;
}

// Returns the current bet value (from g_bets) as a double.
JNIEXPORT jdouble JNICALL Java_slotLogic_getCurrentBet(JNIEnv *env, jobject obj) {
    return (jdouble)g_bets[g_betIndex];
}

// Advances to the next bet index in a circular fashion.
// No return value. Caller should update any UI to reflect new bet size.
JNIEXPORT void JNICALL Java_slotLogic_nextBet(JNIEnv *env, jobject obj) {
    g_betIndex = (g_betIndex + 1) % g_bets.size();
}

// Performs a spin. Returns the amount won (>= 0). If balance is insufficient, returns -1.0.
// Side effects: updates g_balance and g_lastBoard.
// Thread-safety: this function is not synchronized. If invoked concurrently, state races may occur.
JNIEXPORT jdouble JNICALL Java_slotLogic_spin(JNIEnv *env, jobject obj) {
    double currentBet = (double)g_bets[g_betIndex];
    if (g_balance < currentBet) return -1.0; // indicate insufficient funds
    g_balance -= currentBet;

    // RNG: seeded once using current time. Using a static generator avoids re-seeding on each call.
    static std::mt19937 gen(static_cast<unsigned int>(std::time(nullptr)));
    std::uniform_int_distribution<> dis(1, 9);

    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 5; j++) {
            g_lastBoard[i][j] = dis(gen);
        }
    }

    double win = calculate(g_lastBoard, currentBet);
    g_balance += win;
    return (jdouble)win;
}

// Returns a 2D int array (jobjectArray of jintArray) representing the last board.
// JNI responsibility: create proper Java arrays and manage local references.
// The caller (Java side) receives its own copy of the data; modifying the returned arrays
// on the Java side is allowed and will not affect native g_lastBoard.
JNIEXPORT jobjectArray JNICALL Java_slotLogic_getLastBoard(JNIEnv *env, jobject obj) {
    jclass intArrayClass = env->FindClass("[I");
    if (intArrayClass == nullptr) {
        // If class lookup failed, an exception is pending. Return nullptr to propagate to Java.
        return nullptr;
    }

    jobjectArray board = env->NewObjectArray(3, intArrayClass, nullptr);
    if (board == nullptr) {
        // OutOfMemoryError will be pending; return to let Java handle it.
        return nullptr;
    }

    for (int i = 0; i < 3; i++) {
        jintArray row = env->NewIntArray(5);
        if (row == nullptr) {
            // Clean up and return if allocation failed. Local refs will be freed when native method returns,
            // but explicitly returning nullptr lets Java see the pending exception.
            return nullptr;
        }

        jint temp[5];
        for (int j = 0; j < 5; j++) {
            temp[j] = g_lastBoard[i][j];
        }
        env->SetIntArrayRegion(row, 0, 5, temp);
        env->SetObjectArrayElement(board, i, row);
        // Delete the local reference to the row since we've stored it in the parent array.
        env->DeleteLocalRef(row);
    }
    return board;
}

}
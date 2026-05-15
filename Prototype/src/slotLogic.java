// slotLogic.java
// JNI wrapper for the native slot game implementation.
// Purpose: provide a thin Java interface to native code contained in the "slotgame" library.
// Notes:
//  - The native library must be available on java.library.path (or loaded explicitly before use).
//  - Native methods are thin bridges: validate return values and handle exceptional cases on Java side.
//  - Be careful with threading: the native library may not be thread-safe. Synchronize access
//    if multiple threads interact with these methods.

public class slotLogic {
    static {
        // Loads the native library named 'slotgame'.
        // If this fails, ensure the library file (e.g. libslotgame.so, slotgame.dll) is on the
        // platform's library path or set via -Djava.library.path.
        System.loadLibrary("slotgame");
    }

    // Loads required native assets and performs any native initialization.
    // Returns true if initialization and asset loading succeeded, false on failure.
    public native boolean loadAssets();

    // Returns the current balance from native state. Expect a non-negative value on success.
    // If the native side encounters an error, it may throw an exception that will propagate to Java.
    public native double getBalance();

    // Returns the currently selected bet amount.
    public native double getCurrentBet();

    // Advance to the next bet option. This modifies native state; no return value provided.
    public native void nextBet();

    // Perform a spin. Returns the payout amount (0 if no payout).
    // Note: calling spin may change native state (balance, last board); observe call ordering.
    public native double spin();

    // Retrieve the last board produced by a spin as a 2D int array of symbol IDs.
    // Contract: array indices represent [rows][cols]. The returned array is a copy on the Java side.
    public native int[][] getLastBoard();

    // Check whether a bonus feature is currently active for the player.
    // Returns true if a bonus round is in progress on the native side.
    public native boolean isBonusActive();

    // If a bonus is active, returns the number of remaining bonus spins.
    // Returns 0 if no bonus is active.
    public native int getBonusSpins();

    // Finalize the bonus session and return the total payout awarded by the bonus.
    // Calling this will typically clear bonus state on the native side.
    public native double finalizeBonus();

    // Force-entry into the bonus feature for testing or special events. Use with care.
    // This will modify native game state and may require follow-up calls to finalizeBonus().
    public native void forceBonus();
}
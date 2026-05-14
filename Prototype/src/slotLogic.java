// slotLogic.java
// JNI wrapper for the native slot game implementation.
// Purpose: provide a thin Java interface to native code contained in the "slotgame" library.
// Notes:
//  - The native library must be available on java.library.path (or loaded explicitly before use).
//  - Methods map to native functions; any native-side errors may surface as RuntimeExceptions.
//  - Be careful with threading: the native library may not be thread-safe. Synchronize access
//    if multiple threads interact with these methods.
//  - Ensure native-owned resources (textures, buffers) remain valid for the lifetime of any
//    Java objects or arrays that reference them.

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
    // Contract: array indices represent [rows][cols]. Do not assume the array is immutable.
    // If the native implementation returns a direct reference to native memory, avoid modifying it.
    public native int[][] getLastBoard();
}
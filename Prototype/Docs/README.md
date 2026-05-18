**Project Documentation: Edgar's Torture Machine**
==================================================

**1\. Issue Progress & Resolutions**
------------------------------------

### **Make the window (#76)**

*   Developed the primary graphical user interface using Java Swing.
    
*   Implemented a seamless **3x5 grid** using GridLayout with zero-pixel spacing to create a connected reel aesthetic.
    
*   Created a custom BackgroundPanel class to handle high-resolution background image rendering.
    
*   Added dynamic UI scaling to ensure slot icons (160x160px) fully cover the grid interface.
    

### **Winnings (#77)**

*   Established a high-performance calculation engine in C++ (slotWinnings.cpp).
    
*   Implemented a JNI bridge to pass the generated game board from C++ back to the Java UI.
    
*   Added logic to calculate and return winnings based on symbol IDs and current bet multipliers.
    

### **ImportAssets (#78)**

*   Integrated **SFML** (Simple and Fast Multimedia Library) within the C++ backend to handle asset management.
    
*   Developed a staggered loading system in Java to import and scale 9 unique symbol images from the local /Assetsdirectory.
    
*   Implemented a "Shuffle" state using a 70ms high-frequency timer that cycles through these assets before revealing the final result.
    

### **Set bets and initial values (#79)**

*   Configured initial game state in slotService.cpp, including a starting balance of **$1000.00**.
    
*   Implemented a circular bet selection array (5, 10, 15, 20...500) with a native nextBet() function.
    
*   Synced the bet values between the C++ persistent state and the Java UI display.
    

### **Adding sound (#80)**

*   Implemented persistent background music using the javax.sound.sampled library.
    
*   Configured the track **FNHF.wav** to loop continuously upon application startup.
    
*   Established non-blocking audio triggers for game events (spins, wins, and bonus reveals).
    

**2\. Technical Architecture: The JNI Bridge**
----------------------------------------------

This project functions as a hybrid application, using **JNI (Java Native Interface)** to allow the Java frontend to communicate with the C++ backend.

### **Why we use multiple file types:**

File TypeRoleDescription**.javaFrontend**Declares native methods. It handles the "look and feel" and user input.**.hBridge**Automatically generated headers that translate Java method signatures into C-style functions.**.cppEngine**Contains the heavy-lifting logic: random number generation, memory management, and math.**.hppContract**Internal C++ headers that allow different .cpp files to share variables and function prototypes.Exportera till Kalkylark

### **How it works:**

1.  **Java** calls a method like spin().
    
2.  The **JVM** looks into the compiled **.dylib** (Dynamic Library) to find the matching C++ function.
    
3.  **C++** executes the logic and returns data (like an int\[\]\[\] array for the board) back to Java.
    

**3\. Project Configuration & JSON Updates**
--------------------------------------------

To support this multi-language environment and maintain compatibility with external projects (like Roblox), the following was necessary:

*   **Native Path Configuration**: The environment was configured to point to the library path (-Djava.library.path=.) so the Java Virtual Machine can find the compiled C++ code at runtime.
    
*   **Compilation Flags**: Updated the build process to include the -std=c++17 standard. This was required because modern libraries (like SFML) use std::optional and std::filesystem, which are not available in older C++ versions.
    
*   **Monorepo Isolation**: To prevent collisions with Roblox Lua scripts, all Java/C++ code and assets were isolated into a dedicated subdirectory. This ensures that GitHub actions and Roblox-specific JSON projects (like Rojo) do not attempt to process the JNI files.


### To run the code use the command

java --enable-native-access=ALL-UNNAMED -Djava.library.path=. window


**Project Milestone: Core & Bonus Implementation**
--------------------------------------------------

### **#86: Make the Logic**

This milestone focused on the mathematical and state-driven engine within the C++ backend.

*   **Bonus State Machine**: Developed a secondary game loop in slotService.cpp that triggers when the scatter count reaches ≥3.
    
*   **Hold & Win Mechanics**: Created the logic in bonusFunction.cpp to handle "Sticky" symbols. This ensures that the highest icon (ID 9) remains locked in the g\_locked matrix across multiple spins.
    
*   **Payout Calculations**: Integrated a terminal check for the **1000x Grand Jackpot**. The engine now calculates the final payout only after all bonus spins are exhausted or the grid is entirely filled with locked symbols.
    

### **#87: Update Window (window.java)**

The frontend was overhauled to handle the visual transitions and the unique flow of the bonus round.

*   **State-Aware UI**: Updated the runSpin method to detect when the engine enters "Bonus Mode," allowing the UI to switch from manual spins to an automated "Hold & Win" sequence.
    
*   **Transition Effects**: Implemented a flashing "Wave" animation using a high-speed Timer to signal the transition from the base game to the bonus round.
    
*   **Debug Integration**: Added a specialized **DEBUG: BONUS** button in the control panel. This calls the native forceBonus() method, allowing for immediate testing of the bonus logic and visual reveals without relying on RNG.
    

### **#88: Import Assets**

This issue covered the expansion of the resource management system to support the new "Bonus" symbol and high-resolution textures.

*   **Texture Array Expansion**: Refactored importAssets.cpp to increase the std::array size to 10.
    
*   **Path Routing**: Updated the loading logic to specifically map the 10th slot (index 9) to Assets/bonus.png, while keeping the sequential loading for standard symbols 1-9.
    
*   **Pre-flight Validation**: Enhanced the load() method to return a failure state if any single asset is missing, ensuring the JNI bridge does not initialize the game with corrupted or missing graphical data.

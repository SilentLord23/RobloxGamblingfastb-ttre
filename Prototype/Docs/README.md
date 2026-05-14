**Project Documentation: Edgar's Torture Machine**
==================================================

**1\. Issue Progress & Resolutions**
------------------------------------

The following tasks from the project roadmap (referencing **image\_8398bb.png**) have been successfully implemented:

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
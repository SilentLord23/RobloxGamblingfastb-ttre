// importAssest.cpp
// Purpose: helper to load textures used by the prototype.
// Notes:
//  - Expects an Assets/ directory next to the executable containing 1.png..9.png and ETM_Background.png
//  - Textures are loaded into SFML sf::Texture objects.

#include <SFML/Graphics.hpp>
#include <array>
#include <string>

class importAssets {
public:
    std::array<sf::Texture, 9> symbols; // Slot symbol array
    sf::Texture background; // Background

    // Load all required textures from disk.
    // Returns: true on success for all textures, false if any texture fails to load.
    // Important: sf::Texture cannot be copied; the textures are stored in this class and
    // must remain alive as long as any sprites use them.
    bool load() {
        for (size_t i = 0; i < symbols.size(); ++i) {
            // Construct the expected path for each symbol image.
            std::string path = "Assets/" + std::to_string(i + 1) + ".png";
            if (!symbols[i].loadFromFile(path)) {
                // Loading failed for this texture; return immediately.
                // Caller should handle the failure (e.g. log an error and exit or fall back).
                return false;
            }
        }
        
        // Load background texture and return its success state.
        return background.loadFromFile("Assets/ETM_Background.png");
    }
};

// Helper that demonstrates loading internal assets.
// WARNING: This creates a temporary importAssets instance and returns its load status.
// The textures inside the returned instance will be destroyed when this function exits,
// so do not rely on this function to provide long-lived textures. Instead, construct
// a persistent importAssets object at a higher scope and call load() on it.
bool loadInternalAssets() {
    importAssets assets;
    return assets.load();
}
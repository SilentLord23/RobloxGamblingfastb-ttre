// importAssest.cpp
// Purpose: load SFML textures used by the prototype (symbols and background).
// Expectations:
//  - Looks for an Assets/ directory containing 1.png .. 9.png, bonus.png, and ETM_Background.png
//  - The symbols array size was increased to 10 so index 9 (10th entry) holds the bonus symbol.
// Important: sf::Texture objects must remain alive as long as any sf::Sprite references them.

#include <SFML/Graphics.hpp>
#include <array>
#include <string>

class importAssets {
public:
    // Array holds symbol textures. Indices 0..8 map to Assets/1.png .. Assets/9.png.
    // Index 9 (the 10th element) is reserved for Assets/bonus.png.
    std::array<sf::Texture, 10> symbols; 
    // Background texture loaded from Assets/ETM_Background.png
    sf::Texture background;             

    // Load all symbol textures and the background. Returns true on success.
    // Failure at any point returns false so the caller can handle the error.
    bool load() {
        for (size_t i = 0; i < symbols.size(); ++i) {
            std::string path;
            
            // Special-case the 10th symbol as the bonus image.
            if (i == 9) {
                path = "Assets/bonus.png";
            } else {
                // Map indices 0..8 to 1.png .. 9.png
                path = "Assets/" + std::to_string(i + 1) + ".png";
            }

            // Attempt to load; return false immediately on failure.
            if (!symbols[i].loadFromFile(path)) {
                return false;
            }
        }
        
        // Load the background and return its success state.
        return background.loadFromFile("Assets/ETM_Background.png");
    }
};

// NOTE: This helper currently creates a temporary importAssets instance and calls load()
// as a validation step for JNI. Because the importAssets object is destroyed on return,
// the textures it contains will no longer be available. For persistent textures, construct
// an importAssets instance at a scope that outlives your UI and call load() on it.
bool loadInternalAssets() {
    // This currently serves as a validation check for JNI
    importAssets assets;
    return assets.load();
}
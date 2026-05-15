// importAssets.hpp
// Purpose: Declaration for loading textures used by the prototype.
// Notes:
//  - Expects an Assets/ directory with files 1.png .. 9.png, bonus.png and ETM_Background.png
//  - See importAssest.cpp for the implementation details and behavior
//  - Important: ensure textures remain alive as long as sprites use them (see warning below)

#ifndef IMPORT_ASSEST_HPP
#define IMPORT_ASSEST_HPP

// Loads internal textures used by the prototype.
// Returns true if all assets loaded successfully, false on any failure.
// WARNING: The implementation in importAssest.cpp may construct a temporary importAssets
// object when calling loadInternalAssets(). The textures are owned by that object and
// will be destroyed when the function returns. For persistent textures, create an
// importAssets instance at a higher scope and call its load() method directly.
bool loadInternalAssets();

#endif
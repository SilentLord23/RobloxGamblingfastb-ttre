// importAssets.hpp
// Purpose: Declaration for loading textures used by the prototype.
// Notes:
//  - Expects an Assets/ directory with files 1.png .. 9.png and ETM_Background.png
//  - See importAssest.cpp for the implementation details and behavior
//  - Important: ensure textures remain alive as long as sprites use them (see warning below)

#ifndef IMPORT_ASSETS_HPP
#define IMPORT_ASSETS_HPP

bool loadInternalAssets();

#endif
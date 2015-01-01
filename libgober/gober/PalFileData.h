/**
    Structures for reading a PAL (color palette definition) from binary data.
*/
#pragma once

#include <stdint.h>

namespace DF
{

/**
    PAL file color.
*/
struct __attribute__((packed)) PalFileColor
{
    uint8_t r, g, b;
};

/**
    Complete PAL file.
*/
struct __attribute__((packed)) PalFileData
{
    PalFileColor colors[256];
};

} // DF
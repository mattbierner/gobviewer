/**
    Structures for reading a PAL (color palette definition) from binary data.
*/
#pragma once

#include <stdint.h>

#include <gober/Common.h>

namespace DF
{

/**
    PAL file color.
*/
PACKED(struct PalFileColor
{
    uint8_t r, g, b;
});

/**
    Complete PAL file.
*/
PACKED(struct PalFileData
{
    PalFileColor colors[256];
});

} // DF
/**
    Structures for reading a PAL from binary data.
*/
#pragma once

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
    PAL file.
*/
struct __attribute__((packed)) PalFile
{
    PalFileColor colors[256];
};


} // DF
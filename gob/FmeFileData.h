/**
    Structures for reading a FME from binary data.
    
    FMEs contain one view sprites, they are rendered the same from all angles.
*/
#pragma once

#include <stdint.h>

namespace DF
{

/**
    Frame entry header.
*/
struct __attribute__((packed)) FmeFileHeader
{
    /** Inerstion point, x coordinate. */
    uint32_t insertX;
    
    /** Insertion point, y coordinate. */
    uint32_t insertY;
    
    /** 0 = not flipped, 1 = flipped horizontally. */
    uint32_t flipped;
    
    /** Pointer to a header2. */
    uint32_t header2;
    
    /** Unused. */
    uint32_t unitWidth;
    
    /** Unused. */
    uint32_t unitHeight;
    
     /** Unused. */
    uint32_t padding[2];
};

/**
    Second FME header entry.
*/
struct __attribute__((packed)) FmeFileHeader2
{
     /** Size of cell, x value. */
    uint32_t sizeX;
    
    /** Size of cell, y value. */
    uint32_t sizeY;
    
    /** 0 = not compressed, 1 = compressed. */
    uint32_t compressed;
    
    /** Size of a compressed cell. */
    uint32_t dataSize;
    
    /** Unused. Always 0 */
    uint32_t colOffset;
    
    /** Unused. */
    uint32_t padding;
};

} // DF
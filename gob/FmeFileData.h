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
    int32_t insertX;
    
    /** Insertion point, y coordinate. */
    int32_t insertY;
    
    /** 0 = not flipped, 1 = flipped horizontally. */
    int32_t flipped;
    
    /** Pointer to a header2. */
    int32_t header2;
    
    /** Unused. */
    int32_t unitWidth;
    
    /** Unused. */
    int32_t unitHeight;
    
     /** Unused. */
    int32_t pad3;
    
    /** Unused. */
    int32_t pad4;
};

/**
    Second  FME header entry.
*/
struct __attribute__((packed)) FmeFileHeader2
{
     /** Size of cell, x value. */
    int32_t sizeX;
    
    /** Size of cell, y value. */
    int32_t sizeY;
    
    /** 0 = not compressed, 1 = compressed. */
    int32_t compressed;
    
    /** Size of a compressed cell. */
    int32_t dataSize;
    
    /** Unused. */
    int32_t colOffset;
    
    /** Unused. */
    int32_t pad1;
};

} // DF
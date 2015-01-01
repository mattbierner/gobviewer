/**
    Structures for reading a WAX from binary data.
*/
#pragma once

#include "FmeFileData.h"

#include <stdint.h>

namespace DF
{

/**
    File header.
*/
struct __attribute__((packed)) WaxFileHeader
{
    /** Constant, file version. */
    uint32_t version;
    
    /** Number of sequences. */
    uint32_t nSeqs;
    
    /** Number of sequences. */
    uint32_t nFrames;
    
    /** Number of sequences. */
    uint32_t nCells;
    
    /** unused. */
    uint32_t xScale;
    
    /** unused. */
    uint32_t yScale;
    
    /** unused. */
    uint32_t xtraLight;
    
    /** unused. */
    uint32_t pad4;
    
    /** Pointers to Waxes. */
    uint32_t waxes[32];
};

/**
    Wax entry.
*/
struct __attribute__((packed)) Wax
{
    /** World width. */
    uint32_t worldWidth;
    
    /** World height. */
    uint32_t worldHeight;
    
    /** Frames per second. */
    uint32_t frameRate;
    
    /** unused. */
    uint32_t padding[4];
    
    /** Pointers to sequences. */
    uint32_t sequences[32];
};

/**
    Sequence entry.
*/
struct __attribute__((packed)) Sequence
{
    /** unused. */
    uint32_t padding[4];
    
    /** Pointers to frames. Frames are stored in `FmeHeaders`. */
    uint32_t frames[32];
};

} // DF
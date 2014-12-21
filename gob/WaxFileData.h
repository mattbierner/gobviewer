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
    int32_t version;
    
    /** Number of sequences. */
    int32_t nSeqs;
    
    /** Number of sequences. */
    int32_t nFrames;
    
    /** Number of sequences. */
    int32_t nCells;
    
    /** unused. */
    int32_t xScale;
    
    /** unused. */
    int32_t yScale;
    
    /** unused. */
    int32_t xtraLight;
    
    /** unused. */
    int32_t pad4;
    
    /** Pointers to Waxes. */
    int32_t waxes[32];
};

/**
    Wax entry.
*/
struct __attribute__((packed)) Wax
{
    /** World width. */
    int32_t worldWidth;
    
    /** World height. */
    int32_t worldHeight;
    
    /** Frames per second. */
    int32_t frameRate;
    
    /** unused. */
    int32_t nFrames;
    
    /** unused. */
    int32_t pad2;
    
    /** unused. */
    int32_t pad3;
    
    /** unused. */
    int32_t pad4;
    
    /** Pointers to sequences. */
    int32_t sequences[32];
};

/**
    Sequence entry.
*/
struct __attribute__((packed)) Sequence
{
    /** unused. */
    int32_t pad2;
    
    /** unused. */
    int32_t pad3;
    
    /** unused. */
    int32_t pad4;
    
    /** Pointers to frames. Frames are stored in `FmeHeaders`. */
    int32_t frames[32];
};

} // DF
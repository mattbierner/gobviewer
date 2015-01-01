/**
    Structures for reading a WAX from binary data.
    
    Waxs store animations for sprites. The sprites include views from different
    angles. The actual bitmap data is stored in a FME.
*/
#pragma once

#include <stdint.h>

#include <gober/FmeFileData.h>

namespace DF
{

/**
    Wax file header.
*/
struct __attribute__((packed)) WaxFileHeader
{
    /** Constant, file version. */
    uint32_t version;
    
    /** Number of sequences. */
    uint32_t nSeqs;
    
    /** Number of frames. */
    uint32_t nFrames;
    
    /** Number of cells. */
    uint32_t nCells;
    
    /** unused. */
    uint32_t xScale;
    
    /** unused. */
    uint32_t yScale;
    
    /** unused. */
    uint32_t xtraLight;
    
    /** unused. */
    uint32_t pad4;
    
    /** `WaxFileWaxEntry` pointers. */
    uint32_t waxes[32];
};

/**
    Wax entry.
    
    Wax entries store animations for different actions, e.g. walking, attacking, ...
*/
struct __attribute__((packed)) WaxFileWaxEntry
{
    /** World width. */
    uint32_t worldWidth;
    
    /** World height. */
    uint32_t worldHeight;
    
    /** Frames per second. */
    uint32_t frameRate;
    
    /** unused. */
    uint32_t padding[4];
    
    /** `WaxFileSequenceEntry` pointers. */
    uint32_t sequences[32];
};

/**
    Wax sequence entry.
    
    Sequences store views from different angles.
*/
struct __attribute__((packed)) WaxFileSequenceEntry
{
    /** unused. */
    uint32_t padding[4];
    
    /** Pointers to frames. Frames are stored in `FmeHeaders`. */
    uint32_t frames[32];
};

} // DF
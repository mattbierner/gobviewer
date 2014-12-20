/**
    Structures for reading a GOB from binary data.
*/
#pragma once

namespace DF
{

/**
    File header.
*/
struct __attribute__((packed)) GobFileHeader
{
    /** GOB header. */
    char magic[4];
    
    /** Absolute offset to index. */
    int32_t indexOffset;
};

/**
    Entry for a file in the container.
*/
struct __attribute__((packed)) GobFileEntry
{
    /** Absolute offset to start of file data. */
    int32_t offset;
    
    /** Size of file data. */
    int32_t size;
    
    /** Null terminated file name. */
    char filename[13];
};

/**
    List of files in the container.
*/
struct __attribute__((packed)) GobFileIndex
{
    /** Number of files in the container. */
    int32_t count;
    
    /** Array of `count` entries. */
    GobFileEntry entries[];
};

} // DF
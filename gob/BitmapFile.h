#pragma once

#include "BmFileData.h"
#include "DataProvider.h"
#include "Buffer.h"


namespace DF
{

/**
   */
class BitmapFileData
{
public:
    /**
        Get the width of the image.
    */
    virtual unsigned GetWidth() const = 0;
    
    /**
        Get the height of the image.
    */
    virtual unsigned GetHeight() const = 0;

    /**
        Size of the uncompressed BM.
    */
    size_t GetDataSize() const { return GetWidth() * GetHeight(); }
    
    /**
        Read at most `max` bytes of bitmap data into output.
        
        This reads uncompressed bitmap data.
        
        @param index Sub BM to read from.
        @param
    */
    size_t GetData(uint8_t* output, size_t max) const
    {
        switch (GetCompression())
        {
        case BmFileCompression::Rle:
            return ReadRleCompressedBmData(output, max);

        case BmFileCompression::Rle0:
            return ReadRle0CompressedBmData(output, max);

        case BmFileCompression::None:
        default:
            return ReadUncompressedBmData(output, max);
        }
    }

protected:
    virtual BmFileCompression GetCompression() const = 0;

    /**
        Is the file compressed?
    */
    bool IsCompressed() const { return (GetCompression() != BmFileCompression::None); }

    virtual size_t ReadFrom(uint8_t* output, const uint8_t* ptr, size_t max) const = 0;

    /**
    
    */
    size_t ReadUncompressedBmData(uint8_t* output, size_t max) const;
    
    /**
        Decompress a RLE compressed image.
        
        Compression of multiple BMs is not supported.
    */
    size_t ReadRleCompressedBmData(uint8_t* output, size_t max) const;
    
    /**
        Decompress a RLE0 compressed image.
        
        Compression of multiple BMs is not supported.
    */
    size_t ReadRle0CompressedBmData(uint8_t* output, size_t max) const;
    
    /**
    */
    virtual const uint8_t* GetColumnStart(size_t col) const = 0;
    
    /**
    */
    virtual const uint8_t* GetColumnEnd(size_t col) const = 0;
};

} // DF


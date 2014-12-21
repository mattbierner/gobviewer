#pragma once

#include "FmeFileData.h"
#include "DataProvider.h"
#include "Buffer.h"

#include <cassert>

namespace DF
{

/**
    Fme file view.
*/
class FmeFile
{
public:
    /**
        Create a BM file from data in a file stream.
    */
    static FmeFile CreateFromDataProvider(const IDataProvider& dataProvider)
    {
        return FmeFile(Buffer::CreateFromDataProvider(dataProvider));
    }
    
    FmeFile() { }
    
    FmeFile(Buffer&& data) :
        m_data(std::move(data))
    { }
    
    /**
        Get the width of the image.
    */
    unsigned GetWidth() const { return GetHeader2().sizeX; }
    
    /**
        Get the height of the image.
    */
    unsigned GetHeight() const { return GetHeader2().sizeY; }
 
    /**
        Size of the uncompressed image data.
    */
    size_t GetDataSize() const { return GetWidth() * GetHeight(); }
    
    /**
        Read at most `max` bytes of bitmap data into output.
        
        This reads uncompressed bitmap data.

    */
    size_t GetData(uint8_t* output, size_t max) const
    {
        if (IsCompressed())
            return ReadRle0CompressedBmData(output, max);
        else
            return ReadUncompressedBmData(output, max);
    }

private:
    Buffer m_data;
    
    /**
        Get the main file header.
    */
    FmeFileHeader GetHeader() const
    {
        FmeFileHeader header;
        (void)m_data.ReadObj<FmeFileHeader>(&header, 0);
        return header;
    }
    
    /**
        Get the second file header.
    */
    FmeFileHeader2 GetHeader2() const
    {
        auto header = GetHeader();
        FmeFileHeader2 header2;
        (void)m_data.ReadObj<FmeFileHeader2>(&header2, header.header2);
        return header2;
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    size_t Read(uint8_t* output, size_t offset, size_t max) const
    {
        return m_data.Read(output, offset, max);
    }
    
    size_t ReadUncompressedBmData(uint8_t* output, size_t max) const;
    
    /**
        Decompress a RLE0 compressed image.
        
        Compression of multiple BMs is not supported.
    */
    size_t ReadRle0CompressedBmData(uint8_t* output, size_t max) const;

    
    bool IsCompressed() const
    {
        return GetHeader2().compressed;
    }
    
     /**
    */
    const uint8_t* GetColumnStart(size_t col) const;
    
    /**
    */
    const uint8_t* GetColumnEnd(size_t col) const;

    
};

} // DF


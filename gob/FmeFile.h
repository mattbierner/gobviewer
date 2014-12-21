#pragma once

#include "FmeFileData.h"
#include "DataProvider.h"
#include "Buffer.h"
#include "CompressedBuffer.h"
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
        return CompressedBufferReader::ReadCompressedData(
            m_data,
            GetCompression(),
            output,
            GetColumnStart(0) - m_data.Get(),
            max);
    }

protected:
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
    
    bool IsCompressed() const
    {
        return GetHeader2().compressed;
    }
    
    BmFileCompression GetCompression() const
    {
        return GetHeader2().compressed ? BmFileCompression::Rle0 : BmFileCompression::None;
    }
    
    const uint8_t* GetColumnStart(size_t col) const;
};

} // DF


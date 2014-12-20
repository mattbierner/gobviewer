#pragma once

#include "BmFileData.h"
#include "DataProvider.h"
#include "Buffer.h"

namespace DF
{

/**
    Bitmap file view.
*/
class BmFile
{
public:
    /**
        Create a BM file from data in a file stream.
    */
    static BmFile CreateFromDataProvider(const IDataProvider& dataProvider)
    {
        return BmFile(Buffer::CreateFromDataProvider(dataProvider));
    }
    
    BmFile() { }
    
    BmFile(Buffer&& data) :
        m_data(std::move(data))
    { }
    
    unsigned GetWidth() { return GetHeader().sizeX; }
    unsigned GetHeight() { return GetHeader().sizeY; }
    
    unsigned GetCountSubBms() { return GetHeader().idemY; }
    
    BmFileTransparency GetTransparency() { return GetHeader().transparency; }
    
    /**
        Is the file compressed?
    */
    bool IsCompressed() { return (GetHeader().compression != BmFileCompression::None); }
    
    /**
        Size of the uncompressed BM.
        
        Returns the size of all BMs, including sub headers, for multiple BM.
    */
    size_t GetDataSize() { return GetWidth() * GetHeight(); }

    /**
        Does this file contain sub BMs?
    */
    bool IsMultipleBm()
    {
        auto header = GetHeader();
        return (header.idemX == 1 && header.idemY != 1);
    }
    
    /**
        Read at most `max` bytes of bitmap data into output.
        
        This reads uncompressed bitmap data.
    */
    size_t GetData(uint8_t* output, size_t max)
    {
        switch (GetHeader().compression)
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

private:
    Buffer m_data;
    
    BmFileHeader GetHeader() const
    {
        BmFileHeader header;
        (void)m_data.ReadObj<BmFileHeader>(&header, 0);
        return header;
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    size_t Read(uint8_t* output, size_t offset, size_t max) const
    {
        return m_data.Read(output, offset, max);
    }
    
    /**
    
    */
    size_t ReadUncompressedBmData(uint8_t* output, size_t max);
    
    /**
        Decompress a RLE compressed image.
    */
    size_t ReadRleCompressedBmData(uint8_t* output, size_t max);
    
    /**
        Decompress a RLE0 compressed image.
    */
    size_t ReadRle0CompressedBmData(uint8_t* output, size_t max);
    
    uint8_t* GetColumnStart(size_t col);
    
    uint8_t* GetColumnEnd(size_t col);
};

} // DF


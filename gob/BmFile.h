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
        Create a Bm file from data in a file stream.
    */
    static BmFile CreateFromFile(std::ifstream&& fs)
    {
        return BmFile(std::make_unique<FileDataProvider>(std::move(fs)));
    }
    
    /**
        Create a Bm file from a buffer
    */
    static BmFile CreateFromBuffer(uint8_t* data, size_t size)
    {
        return BmFile(std::make_unique<MemoryDataProvider>(data, size));
    }
    
    BmFile() { }
    
    unsigned GetSizeX() { return GetHeader().sizeX; }
    unsigned GetSizeY() { return GetHeader().sizeY; }
    
    unsigned GetCountSubBms() { return GetHeader().idemY; }
    
    BmFileTransparency GetTransparency() { return GetHeader().transparency; }
    
    /**
        Size of the uncompressed BM.
        
        Returns the size of all Bm for multiple Bms.
    */
    size_t GetDataSize() { return GetSizeX() * GetSizeY(); }

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
    
    BmFile(std::unique_ptr<IDataProvider>&& dataProvider) :
        m_data(Buffer::FromDataProvider(*dataProvider))
    { }
    
    BmFileHeader GetHeader()
    {
        BmFileHeader header;
        Read<BmFileHeader>(&header, 0);
        return header;
    }
    
    /**
        Read an object of type `T` from the Bm.
    */
    template <typename T>
    void Read(T* output, size_t offset)
    {
        Read(reinterpret_cast<uint8_t*>(output), offset, sizeof(T));
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    void Read(uint8_t* output, size_t offset, size_t max)
    {
        m_data.Read(output, offset, max);
    }
    
    size_t ReadUncompressedBmData(uint8_t* output, size_t max)
    {
        auto size = GetDataSize();
        
        size_t read = std::min(size, max);
        Read(output, sizeof(BmFileHeader), read);
        return read;
    }
    
    size_t ReadRleCompressedBmData(uint8_t* output, size_t max)
    {
        auto size = GetDataSize();
        
        size_t read = std::min(size, max);
        Read(output, sizeof(BmFileHeader), read);
        return read;
    }
    
    size_t ReadRle0CompressedBmData(uint8_t* output, size_t max)
    {
        auto size = GetDataSize();
        
        size_t read = std::min(size, max);
        Read(output, sizeof(BmFileHeader), read);
        return read;
    }
};

} // DF


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
    
    bool IsCompressed() { return (GetHeader().compression != BmFileCompression::None); }
    
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
        (void)ReadObj<BmFileHeader>(&header, 0);
        return header;
    }
    
    /**
        Read an object of type `T` from the Bm.
    */
    template <typename T>
    size_t ReadObj(T* output, size_t offset)
    {
        return Read(reinterpret_cast<uint8_t*>(output), offset, sizeof(T));
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    size_t Read(uint8_t* output, size_t offset, size_t max)
    {
        return m_data.Read(output, offset, max);
    }
    
    size_t ReadUncompressedBmData(uint8_t* output, size_t max)
    {
        auto size = GetDataSize();
        
        size_t read = std::min(size, max);
        Read(output, sizeof(BmFileHeader), read);
        return read;
    }
    
    /**
        Decompress a RLE compressed image.
    */
    size_t ReadRleCompressedBmData(uint8_t* output, size_t max)
    {
        size_t read = 0;
        uint8_t* start = GetColumnStart(0);
        for (unsigned col = 0; col < GetSizeX() && read < max; ++col)
        {
            uint8_t* end = GetColumnEnd(col);            
            while (start < end && read < max)
            {
                uint8_t n = *(start++);
                if (n <= 128)
                {
                    // copy `n` direct values
                    size_t offset = start - m_data.Get(0);
                    size_t numRead = Read(output + read, offset, n);
                    start += n;
                    read += numRead;
                }
                else
                {
                    // Repeat next byte `n - 128` times
                    auto next = *(start++);
                    uint8_t reps = n - 128;
                    size_t toRead = std::min(static_cast<size_t>(reps), max - read);
                    std::fill_n(output + read, toRead, next);
                    read += toRead;
                }
            }
        }
        return read;
    }
    
    /**
        Decompress a RLE0 compressed image.
    */
    size_t ReadRle0CompressedBmData(uint8_t* output, size_t max)
    {
        size_t read = 0;
        uint8_t* start = GetColumnStart(0);
        for (unsigned col = 0; col < GetSizeX() && read < max; ++col)
        {
            uint8_t* end = GetColumnEnd(col);
            while (start < end && read < max)
            {
                uint8_t n = *(start++);
                if (n <= 128)
                {
                    // copy `n` direct values
                    size_t offset = start - m_data.Get(0);
                    size_t numRead = Read(output + read, offset, n);
                    start += n;
                    read += numRead;
                }
                else
                {
                    // Create `n - 128` transparent pixels
                    uint8_t reps = n - 128;
                    size_t toRead = std::min(static_cast<size_t>(reps), max - read);
                    std::fill_n(output + read, toRead, 0);
                    read += toRead;
                }
            }
        }
        return read;
    }
    
    uint8_t* GetColumnStart(size_t col)
    {
        if (IsCompressed())
        {
            size_t tableOffset = sizeof(BmFileHeader) + GetHeader().dataSize + (col * sizeof(int32_t));
            int32_t* tableEntry = m_data.Get<int32_t>(tableOffset);
            if (tableEntry)
                return m_data.Get(sizeof(BmFileHeader) + *tableEntry);
        }
        else
        {
            size_t colOffset = col * GetSizeX();
            return m_data.Get(sizeof(BmFileHeader) + colOffset);
        }
        return nullptr;
    }
    
    uint8_t* GetColumnEnd(size_t col)
    {
        if (col == GetSizeX() - 1) // end
        {
            if (IsCompressed())
            {
                return m_data.Get(sizeof(BmFileHeader) + GetHeader().dataSize);
            }
            else
            {
                return m_data.Get(sizeof(BmFileHeader) + GetDataSize());
            }
        }
        else
        {
            return GetColumnStart(col + 1);
        }
    }
};

} // DF


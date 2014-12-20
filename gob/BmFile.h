#pragma once

#include "BmFileData.h"
#include "DataProvider.h"
#include "Buffer.h"

#include <cassert>

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
    
    /**
        Get the width of the image.
        
        @param index Sub BM to get width of. Only valid for multiple BMs.
    */
    unsigned GetWidth(size_t index = 0) const
    {
        return (IsMultipleBm() ? GetSubHeader(index).sizeX : GetHeader().sizeX);
    }
    
    /**
        Get the height of the image.
        
        @param index Sub BM to get height of. Only valid for multiple BMs.
    */
    unsigned GetHeight(size_t index = 0) const
    {
        return (IsMultipleBm() ? GetSubHeader(index).sizeY : GetHeader().sizeY);
    }
    
    /**
        Get the type of transparency of the image.
        
        @param index Sub BM to get ransparency of. Only valid for multiple BMs.
    */
    BmFileTransparency GetTransparency(size_t index = 0) const
    {
        return (IsMultipleBm() ? GetSubHeader(index).transparency : GetHeader().transparency);
    }

    /**
        Size of the uncompressed BM.
    */
    size_t GetDataSize(size_t index = 0) const { return GetWidth(index) * GetHeight(index); }

    /**
        Does this file contain sub BMs?
    */
    bool IsMultipleBm() const
    {
        auto header = GetHeader();
        return (header.sizeX == 1 && header.sizeY != 1);
    }
    
    /**
        Get the number of sub BM stored in this file.
        
        Returns 1 for non-multiple BMs.
    */
    unsigned GetCountSubBms() const
    {
        return (IsMultipleBm() ? GetHeader().idemY : 1);
    }
    
    /**
        Read at most `max` bytes of bitmap data into output.
        
        This reads uncompressed bitmap data.
        
        @param index Sub BM to read from.
        @param
    */
    size_t GetData(size_t index, uint8_t* output, size_t max) const
    {
        switch (GetCompression(index))
        {
        case BmFileCompression::Rle:
            return ReadRleCompressedBmData(output, max);

        case BmFileCompression::Rle0:
            return ReadRle0CompressedBmData(output, max);

        case BmFileCompression::None:
        default:
            return ReadUncompressedBmData(index, output, max);
        }
    }

private:
    Buffer m_data;
    
    /**
        Get the main file header.
    */
    BmFileHeader GetHeader() const
    {
        BmFileHeader header;
        (void)m_data.ReadObj<BmFileHeader>(&header, 0);
        return header;
    }
    
    /**
        Get the sub header for a multiple BM.
     
        Only valid for multiple BM.
    */
    BmFileSubHeader GetSubHeader(size_t index) const
    {
        assert(IsMultipleBm() && index < GetCountSubBms());
        
        int32_t offset = GetSubOffset(index);
        BmFileSubHeader header;
        (void)m_data.ReadObj<BmFileSubHeader>(&header, offset);
        return header;
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    size_t Read(uint8_t* output, size_t offset, size_t max) const
    {
        return m_data.Read(output, offset, max);
    }
    
    BmFileCompression GetCompression(size_t index = 0) const
    {
        return (IsMultipleBm() ? BmFileCompression::None : GetHeader().compression);
    }
    
    /**
        Is the file compressed?
    */
    bool IsCompressed(size_t index = 0) const { return (GetCompression(index) != BmFileCompression::None); }

    /**
        For a multiple BM, get the absolute offset to the start of the sub file.
    */
    int32_t GetSubOffset(size_t index) const
    {
        assert(IsMultipleBm() && index < GetCountSubBms());
    
        const int32_t* startTable = m_data.Get<int32_t>(sizeof(BmFileHeader) + 2);
        return startTable[index] + sizeof(BmFileHeader) + 2;
    }
    
    /**
    
    */
    size_t ReadUncompressedBmData(size_t index, uint8_t* output, size_t max) const;
    
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
    const uint8_t* GetColumnStart(size_t index, size_t col) const;
    
    /**
    */
    const uint8_t* GetColumnEnd(size_t index, size_t col) const;
};

} // DF


#pragma once

#include "BmFileData.h"
#include "DataProvider.h"
#include "Buffer.h"
#include "BitmapFile.h"

#include <cassert>

namespace DF
{

/**
    Bitmap file view.
*/
class BmFile : public BitmapFileData
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
    virtual unsigned GetWidth() const override { return GetWidth(0); }
    
    unsigned GetWidth(size_t index) const
    {
        return (IsMultipleBm() ? GetSubHeader(index).sizeX : GetHeader().sizeX);
    }
    
    /**
        Get the height of the image.
        
        @param index Sub BM to get height of. Only valid for multiple BMs.
    */
    virtual unsigned GetHeight() const override { return GetHeight(0); }
    
    unsigned GetHeight(size_t index) const
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
    using BitmapFileData::GetDataSize;
    size_t GetDataSize(size_t index) const { return GetWidth(index) * GetHeight(index); }

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
        Get th frame rate setting of a multiple BM.
        
        Returns 0 for non-multiple BMs.
    */
    uint8_t GetFrameRate() const
    {
        if (IsMultipleBm())
        {
            const uint8_t* frameRate = m_data.Get(sizeof(BmFileHeader));
            if (frameRate)
                return *frameRate;
        }
        
        return 0;
    }
    
    /**
        Read at most `max` bytes of bitmap data into output.
        
        This reads uncompressed bitmap data.
        
        @param index Sub BM to read from.
        @param
    */
    size_t GetData(size_t index, uint8_t* output, size_t max) const
    {
        switch (GetCompression())
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
     
        Only validx4 for multiple BM.
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
    
    virtual size_t ReadFrom(uint8_t* output, const uint8_t* ptr, size_t max) const override
    {
        return m_data.Read(output, (ptr - m_data.Get()), max);
    }
    
    size_t ReadUncompressedBmData(size_t index, uint8_t* output, size_t max) const;
    
    virtual BmFileCompression GetCompression() const override
    {
        return (IsMultipleBm() ? BmFileCompression::None : GetHeader().compression);
    }
    
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
    virtual const uint8_t* GetColumnStart(size_t col) const override;
    
    /**
    */
    virtual const uint8_t* GetColumnEnd(size_t col) const override;
};

} // DF


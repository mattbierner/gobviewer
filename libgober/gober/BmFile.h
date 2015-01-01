/**
    Bitmap file.
*/
#pragma once

#include <gober/BmFileData.h>
#include <gober/DataReader.h>
#include <gober/Buffer.h>

namespace DF
{

/**
    Bitmap file.
    
    May potentially contain multiple sub bitmaps.
*/
class BmFile :
    public IBuffer
{
public:
    /**
        Create a BM file from data in a file stream.
    */
    static BmFile CreateFromDataProvider(const IDataReader& dataProvider)
    {
        return BmFile(Buffer::CreateFromDataProvider(dataProvider));
    }
    
    BmFile() { }
    
    BmFile(Buffer&& data) :
        m_data(std::move(data))
    { }
    
    virtual bool IsReadable() const override { return m_data.IsReadable(); }
    
    /**
        Size of the uncompressed BM.
    */
    size_t GetDataSize(size_t index) const { return GetWidth(index) * GetHeight(index); }
    
    virtual size_t GetDataSize() const override { return GetCountSubBms() * (GetWidth(0) * GetHeight(0)); }

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
        Get the frame rate setting of a multiple BM.
        
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
        Is a multiple BM a switch?
        
        Returns false for non-multiple BMs.
    */
    bool IsSwitch() const
    {
        if (IsMultipleBm())
            return (GetFrameRate() == 0);
        return false;
    }
    
    /**
        Read at most `max` bytes of bitmap data into output.
        
        This reads uncompressed bitmap data.
        
        @param index Sub BM to read from.
        @param
    */
    size_t GetData(size_t index, uint8_t* output, size_t max) const;

    virtual size_t Read(uint8_t* output, size_t offset, size_t max) const override
    {
        return GetData(0, output, max);
    }
    
    virtual uint8_t* Get(size_t offset) override { return GetImageDataStart(0, 0) + offset; }

    virtual const uint8_t* Get(size_t offset) const override { return GetImageDataStart(0, 0) + offset; }

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
    BmFileSubHeader GetSubHeader(size_t index) const;
        
    BmFileCompression GetCompression() const
    {
        return (IsMultipleBm() ? BmFileCompression::None : GetHeader().compression);
    }
    
    bool IsCompressed() const
    {
        return (GetCompression() != BmFileCompression::None);
    }
    
    /**
        For a multiple BM, get the absolute offset to the start of the sub file.
    */
    int32_t GetSubOffset(size_t index) const;
    
    /**
    */
    uint8_t* GetImageDataStart(size_t index, size_t col) { return const_cast<uint8_t*>( GetImageDataStart(index, col)); }
    
    const uint8_t* GetImageDataStart(size_t index, size_t col) const;
};

} // DF


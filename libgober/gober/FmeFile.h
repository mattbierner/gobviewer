#pragma once

#include <gober/Bitmap.h>
#include <gober/BmFileData.h>
#include <gober/Buffer.h>
#include "Cell.h"
#include <gober/FmeFileData.h>

namespace DF
{

/**
    Fme file view.
*/
class FmeFile
{
public:
    static FmeFile CreateFromDataProvider(const IDataReader& dataProvider)
    {
        return FmeFile(Buffer::CreateFromDataProvider(dataProvider));
    }
    
    FmeFile() { }
    
    virtual ~FmeFile() { }
    
    FmeFile(const std::shared_ptr<IBuffer>& data) :
        m_data(data)
    { }

    FmeFile(Buffer&& data) :
        FmeFile(std::make_shared<Buffer>(std::move(data)))
    { }
    
    /**
        Get the X insertion point.
    */
    int32_t GetInsertX() const { return GetHeader().insertX; }
    
    /**
        Get the Y insertion point.
    */
    int32_t GetInsertY() const { return GetHeader().insertY; }
    
    /**
        Should the FME be rendered flipped?
    */
    bool IsFlipped() const { return GetHeader().flipped; }
    
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
        Opaquly identifies where the image data is being pulled from.
        
        This can be used to avoid generating data for the same bit map
        multiple times in a WAX.
     
        Only valid for comparison when two FMEs are in the same WAX.
    */
    size_t GetDataUid() const { return GetHeader().header2; }
    
    /**
        Get the uncompressed bitmap data.
    */
    Bitmap CreateBitmap() const;
    
    /**
        Get the uncompressed bitmap data.
    */
    Cell CreateCell() const;
    
protected:
    std::shared_ptr<IBuffer> m_data;
    
    /**
        Get the main file header.
    */
    FmeFileHeader GetHeader() const;
    
    /**
        Get the second file header.
    */
    FmeFileHeader2 GetHeader2() const;
    
    bool IsCompressed() const
    {
        return GetHeader2().compressed;
    }
    
    BmFileCompression GetCompression() const
    {
        return GetHeader2().compressed ? BmFileCompression::Rle0 : BmFileCompression::None;
    }
    
    /**
       Read and uncompress the bitmap data.
    */
    Buffer Uncompress() const;
    
    const size_t GetImageDataStart() const;
};

} // DF


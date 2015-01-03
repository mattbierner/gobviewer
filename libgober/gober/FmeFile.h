#pragma once

#include <gober/Bitmap.h>
#include <gober/BmFileData.h>
#include <gober/Buffer.h>
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
    
    bool IsReadable() const { return m_data->IsReadable(); }
    
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
        Get the uncompressed bitmap data.
    */
    Bitmap CreateBitmap() const;
    
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


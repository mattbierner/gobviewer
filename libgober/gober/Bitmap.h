#pragma once

#include <gober/Buffer.h>
#include <gober/BmFileData.h>

namespace DF
{

/**
    Bitmap data.
 
    Holds uncompressed bitmap data.
*/
class Bitmap :
    public IBuffer
{
public:
    Bitmap(unsigned width, unsigned height, BmFileTransparency transparency, std::unique_ptr<IBuffer>&& buffer) :
        m_width(width),
        m_height(height),
        m_transparency(transparency),
        m_data(std::move(buffer))
    { }

    Bitmap(unsigned width, unsigned height, BmFileTransparency transparency, Buffer&& buffer) :
        Bitmap(width, height, transparency, std::make_unique<Buffer>(std::move(buffer)))
    { }
    
    unsigned GetWidth() const { return m_width; }
    
    unsigned GetHeight() const { return m_height; }
    
    BmFileTransparency GetTransparency() const { return m_transparency; }

    virtual bool IsReadable() const override { return (m_data && m_data->IsReadable()); }
    
    virtual size_t GetDataSize() const override { return m_data->GetDataSize(); }
    
    virtual uint8_t* Get(size_t offset) override { return m_data->Get(offset); }
    
    virtual const uint8_t* Get(size_t offset) const override { return m_data->Get(offset); }
    
private:
    std::unique_ptr<IBuffer> m_data;
    unsigned m_width;
    unsigned m_height;
    BmFileTransparency m_transparency;
};

} // DF
#pragma once

#include <gober/Buffer.h>

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
    Bitmap(unsigned width, unsigned height, bool transparency, Buffer&& buffer) :
        m_width(width),
        m_height(height),
        m_transparency(transparency),
        m_data(std::move(buffer))
    { }
    
    virtual bool IsReadable() const override { return m_data.IsReadable(); }
    
    virtual size_t GetDataSize() const override { return m_data.GetDataSize(); }
    
    virtual uint8_t* Get(size_t offset) override { return m_data.Get(offset); }
    
    virtual const uint8_t* Get(size_t offset) const override { return m_data.Get(offset); }
    
private:
    Buffer m_data;
    unsigned m_width;
    unsigned m_height;
    bool m_transparency;
};

} // DF
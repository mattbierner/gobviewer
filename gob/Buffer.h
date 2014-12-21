#pragma once

#include "DataProvider.h"

#include <stdint.h>
#include <vector>

namespace DF
{

/**
    Managed block of memory.
*/
class Buffer : public std::vector<uint8_t>,
    public IDataProvider
{
    using Super = std::vector<uint8_t>;
    
public:
    /**
        Create a buffer from a data provider.
        
        Note that this always copies the data held by the Data provider.
    */
    static Buffer CreateFromDataProvider(const IDataProvider& provider)
    {
        size_t size = provider.GetDataSize();
        Buffer buf = Create(size);
        provider.Read(buf.Get(0), 0, size);
        return buf;
    }
    
    /**
        Create a new buffer of `size`.
    */
    static Buffer Create(size_t size)
    {
        return Buffer(size, 0);
    }
    
    Buffer() : Buffer(0, 0) { }
    
    Buffer(const Buffer& other) = delete;
    
    Buffer(Buffer&& other, size_t baseOffset = 0) :
        Super(std::move(other)),
        m_baseOffset(other.m_baseOffset + baseOffset)
    { }
    
    Buffer& operator=(const Buffer& other) = delete;
    
    Buffer& operator=(Buffer&& other)
    {
        Super::operator=(std::move(other));
        return *this;
    }

    virtual bool IsValid() const { return (GetDataSize() > 0);}

    virtual size_t GetDataSize() const override { return (this->size() - m_baseOffset); }

    /**
        Get direct access to memory in the buffer.
        
        No ownership of the memory is implied. Ptr is invalid once Buffer is 
        destroyed.
    */
    template <typename T = uint8_t>
    T* Get(size_t offset = 0)
    {
        if (CanRead<T>(m_baseOffset + offset))
            return reinterpret_cast<T*>(&((*this)[m_baseOffset + offset]));
        else
            return nullptr;
    }

    template <typename T = uint8_t>
    const T* Get(size_t offset = 0) const
    {
        if (CanRead<T>(m_baseOffset + offset))
            return reinterpret_cast<const T*>(&((*this)[m_baseOffset + offset]));
        else
            return nullptr;
    }

    /**
        Read an object of type `T` from the buffer.

        @param output Data to read to. Should be at least `sizeof(T)` bytes.
        @param offset Offset to read from in bytes.
    */
    template <typename T>
    size_t ReadObj(T* output, size_t offset) const
    {
        if (CanRead<T>(m_baseOffset + offset))
            return Read(reinterpret_cast<uint8_t*>(output), offset, sizeof(T));
        else
            return 0;
    }
    
    virtual size_t Read(uint8_t* output, size_t offset, size_t max) const override
    {
        if (!IsValid()) return 0;
        size_t read = std::min(GetDataSize() - (m_baseOffset + offset), max);
        const auto* start = Get(offset);
        std::copy(start, start + read, output);
        return read;
    }
    
private:
    size_t m_baseOffset;

    Buffer(size_t size, size_t baseOffset) :
        Super(size),
        m_baseOffset(baseOffset)
    { }
};

} // DF
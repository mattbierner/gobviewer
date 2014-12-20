#pragma once

#include "DataProvider.h"

namespace DF
{

/**
    Manages a block of memory.
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
    static Buffer FromDataProvider(const IDataProvider& provider)
    {
        size_t size = provider.GetDataSize();
        Buffer buf(size);
        provider.Read(buf.Get(0), 0, size);
        return buf;
    }
    
    Buffer() : Buffer(0) { }
    
    Buffer(const Buffer& other) = delete;
    
    Buffer(Buffer&& other) : Super(std::move(other)) { }
    
    Buffer& operator=(const Buffer& other) = delete;
    Buffer& operator=(Buffer&& other) = delete;

    virtual size_t GetDataSize() const override { return this->size(); }

    /**
        Get direct access to memory in the buffer.
        
        No ownership of the memory is implied. Ptr is invalid once Buffer is 
        destroyed.
    */
    template <typename T = uint8_t>
    T* Get(size_t offset) { return &((*this)[offset]); }

    template <typename T = uint8_t>
    const T* Get(size_t offset) const { return &((*this)[offset]); }

    /**
        Read an object of type `T` from the buffer.

        @param output Data to read to. Should be at least `sizeof(T)` bytes.
        @param offset Offset to read from in bytes.
    */
    template <typename T>
    size_t ReadObj(T* output, size_t offset) const
    {
        return Read(reinterpret_cast<uint8_t*>(output), offset, sizeof(T));
    }
    
    virtual size_t Read(uint8_t* output, size_t offset, size_t max) const override
    {
        size_t read = std::min(GetDataSize() - offset, max);
        auto start = Get(offset);
        std::copy(start, start + max, output);
        return read;
    }
    
private:
    Buffer(size_t size) : Super(size) { }
};

} // DF
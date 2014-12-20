#pragma once

#include <fstream>
#include <cassert>

namespace DF
{

/**
    Provides read access to memory.
*/
struct IDataProvider
{
    /**
        Get total data size.
    */
    virtual size_t GetDataSize() const = 0;
    
    /**
        Copy some data.
        
        @param output Byte buffer output of at least `max`.
        @param offset Place to start read.
        @param max Maximum number of bytes to read.
        
        @returns Size of data actually written.
    */
    virtual size_t Read(uint8_t* output, size_t offset, size_t max) const = 0;
};

/**
    Provides read access to a block of memory.
    
    Does not take ownership of memory.
*/
class MemoryDataProvider : public IDataProvider
{
public:
    MemoryDataProvider(uint8_t* buffer, size_t size) :
        m_buffer(buffer),
        m_size(size)
    { }
    
    virtual size_t GetDataSize() const override { return m_size; }

    virtual size_t Read(uint8_t* output, size_t offset, size_t max) const override
    {
        size_t read = std::min(GetDataSize() - offset, max);
        std::copy(m_buffer, m_buffer + read, output);
        return read;
    }
    
private:
    uint8_t* m_buffer;
    size_t m_size;
};

/**
    Provides read access to a file stream.
*/
class FileDataProvider : public IDataProvider
{
public:
    FileDataProvider(std::ifstream&& x) :
        m_stream(std::move(x))
    {
        m_stream.seekg(0, std::ifstream::end);
        m_size = m_stream.tellg();
    }

    virtual size_t GetDataSize() const override { return m_size; }

    virtual size_t Read(uint8_t* output, size_t offset, size_t count) const override
    {
        assert(offset + count <= m_size);
        m_stream.seekg(offset, std::ifstream::beg);
        m_stream.read(reinterpret_cast<char*>(output), count);
        return count;
    }
    
private:
    mutable std::ifstream m_stream;
    size_t m_size;
};

} // DF
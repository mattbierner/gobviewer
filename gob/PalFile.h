#pragma once

#include "PalFileData.h"
#include "DataProvider.h"
#include "Buffer.h"

namespace DF
{

/**
    Color palete defintion file.
*/
class PalFile
{
public:
    /**
        Create a Pal file from data in a file stream.
    */
    static PalFile CreateFromDataProvider(const IDataProvider& dataProvider)
    {
        return PalFile(Buffer::CreateFromDataProvider(dataProvider));
    }
    
    PalFile() { }
    
    PalFile(Buffer&& buffer) :
        m_data(std::move(buffer))
    { }
    
    size_t GetDataSize()
    {
        return sizeof(PalFileData);
    }
    
    size_t GetData(uint8_t* output, size_t max)
    {
        auto size = GetDataSize();
        
        size_t read = std::min(size, max);
        Read(output, 0, read);
        return read;
    }

private:
    Buffer m_data;
    
    /**
        Read an object of type `T` from the Pal.
    */
    template <typename T>
    size_t Read(T* output, size_t offset)
    {
        return Read(reinterpret_cast<uint8_t*>(output), offset, sizeof(T));
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    size_t Read(uint8_t* output, size_t offset, size_t max)
    {
        return m_data.Read(output, offset, max);
    }
};

} // DF


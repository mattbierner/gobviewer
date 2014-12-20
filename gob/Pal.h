#pragma once

#include "PalFileData.h"
#include "DataProvider.h"


namespace DF
{

class Pal
{
public:
    /**
        Create a Pal file from data in a file stream.
    */
    static Pal CreateFromFile(std::ifstream&& fs)
    {
        return Pal(std::make_unique<FileDataProvider>(std::move(fs)));
    }
    
    /**
        Create a Pal file from a buffer
    */
    static Pal CreateFromBuffer(uint8_t* data, size_t size)
    {
        return Pal(std::make_unique<MemoryDataProvider>(data, size));
    }
    
    Pal() { }
    
    size_t GetDataSize()
    {
        return sizeof(PalFile);
    }
    
    size_t GetData(uint8_t* output, size_t max)
    {
        auto size = GetDataSize();
        
        size_t read = std::min(size, max);
        Read(output, 0, read);
        return read;
    }

private:
    std::unique_ptr<IDataProvider> m_dataProvider;
    
    Pal(std::unique_ptr<IDataProvider>&& dataProvider) :
        m_dataProvider(std::move(dataProvider))
    { }
    
    /**
        Read an object of type `T` from the Pal.
    */
    template <typename T>
    void Read(T* output, size_t offset)
    {
        Read(reinterpret_cast<uint8_t*>(output), offset, sizeof(T));
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    void Read(uint8_t* output, size_t offset, size_t max)
    {
        m_dataProvider->Read(output, offset, max);
    }
};

} // DF


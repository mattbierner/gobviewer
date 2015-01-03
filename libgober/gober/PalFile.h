#pragma once

#include <gober/Buffer.h>
#include <gober/DataReader.h>
#include <gober/PalFileData.h>

namespace DF
{

/**
    Color palette defintion file.
*/
class PalFile :
    public IDataReader
{
public:
    /**
        Create a Pal file from data in a file stream.
    */
    static PalFile CreateFromDataProvider(const IDataReader& dataProvider)
    {
        return PalFile(Buffer::CreateFromDataProvider(dataProvider));
    }
    
    PalFile() { }
    
    PalFile(Buffer&& buffer) :
        m_data(std::move(buffer))
    { }
    
    virtual size_t GetDataSize() const override
    {
        return sizeof(PalFileData);
    }
    
    virtual bool IsReadable() const override
    {
        return m_data.IsReadable();
    }
    
    virtual size_t Read(uint8_t* output, size_t offset, size_t max) const override
    {
        return m_data.Read(output, offset, max);
    }

private:
    Buffer m_data;
};

} // DF


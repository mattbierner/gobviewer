#include "FmeFile.h"

namespace DF
{

const uint8_t* FmeFile::GetColumnStart(size_t col) const
{
    if (IsCompressed())
    {
        size_t tableOffset = GetHeader().header2 + sizeof(FmeFileHeader2) + (col * sizeof(int32_t));
        const int32_t* tableEntry = m_data.Get<int32_t>(tableOffset);
        if (tableEntry)
            return m_data.Get(sizeof(FmeFileHeader) + *tableEntry);
        else
            return nullptr;
    }
    else
    {
        size_t dataOffset = GetHeader().header2 + sizeof(FmeFileHeader2);
        size_t colOffset = col * GetWidth();
        return m_data.Get(dataOffset + colOffset);
    }
}

const uint8_t* FmeFile::GetColumnEnd(size_t col) const
{
    if (col == GetWidth() - 1) // end
    {
        
        return m_data.Get(GetHeader().header2 + sizeof(FmeFileHeader2) + (IsCompressed() ? GetHeader2().dataSize : GetDataSize()));
    }
    else
    {
        return GetColumnStart(col + 1);
    }
}


} // DF

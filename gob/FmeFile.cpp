#include "FmeFile.h"

namespace DF
{

const uint8_t* FmeFile::GetColumnStart(size_t col) const
{
    size_t dataOffset = GetHeader().header2 + sizeof(FmeFileHeader2);
    if (IsCompressed())
    {
        size_t tableOffset = dataOffset + (col * sizeof(int32_t));
        const int32_t* tableEntry = m_data.Get<int32_t>(tableOffset);
        if (tableEntry)
            return m_data.Get(sizeof(FmeFileHeader) + *tableEntry);
        else
            return nullptr;
    }
    else
    {
        size_t colOffset = col * GetWidth();
        return m_data.Get(dataOffset + colOffset);
    }
}

} // DF

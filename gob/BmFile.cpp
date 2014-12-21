#include "BmFile.h"

namespace DF
{

const uint8_t* BmFile::GetColumnStart(size_t col) const
{
    if (IsCompressed())
    {
        size_t tableOffset = sizeof(BmFileHeader) + GetHeader().dataSize + (col * sizeof(int32_t));
        const int32_t* tableEntry = m_data.Get<int32_t>(tableOffset);
        if (tableEntry)
            return m_data.Get(sizeof(BmFileHeader) + *tableEntry);
        else
            return nullptr;
    }
    else
    {
        size_t dataOffset = sizeof(BmFileHeader);
        size_t colOffset = col * GetWidth(0);
        return m_data.Get(dataOffset + colOffset);
    }
}

} // DF

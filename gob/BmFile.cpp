#include "BmFile.h"

namespace DF
{

const uint8_t* BmFile::GetImageDataStart(size_t index, size_t col) const
{
    if (IsCompressed())
    {
        size_t dataOffset = sizeof(BmFileHeader);
        size_t tableOffset = dataOffset + GetHeader().dataSize + (col * sizeof(int32_t));
        const int32_t* tableEntry = m_data.GetObj<int32_t>(tableOffset);
        if (tableEntry)
            return m_data.Get(dataOffset + *tableEntry);
        else
            return nullptr;
    }
    else
    {
        size_t dataOffset = (IsMultipleBm() ? GetSubOffset(index) + sizeof(BmFileSubHeader) : sizeof(BmFileHeader));
        size_t colOffset = col * GetWidth(0);
        return m_data.Get(dataOffset + colOffset);
    }
}

} // DF

#include "BmFile.h"

namespace DF
{

size_t BmFile::ReadUncompressedBmData(size_t index, uint8_t* output, size_t max) const
{
    auto size = GetDataSize(index);
    size_t read = std::min(size, max);
    size_t offset = (GetColumnStart(0) - m_data.Get());
    Read(output, offset, read);
    return read;
}


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
        size_t dataOffset = (IsMultipleBm() ? GetSubOffset(0) + sizeof(BmFileSubHeader) : sizeof(BmFileHeader));
        size_t colOffset = col * GetWidth(0);
        return m_data.Get(dataOffset + colOffset);
    }
}

const uint8_t* BmFile::GetColumnEnd(size_t col) const
{
    if (col == GetWidth() - 1) // end
    {
        return m_data.Get(sizeof(BmFileHeader) + (IsCompressed() ? GetHeader().dataSize : GetDataSize()));
    }
    else
    {
        return GetColumnStart(col + 1);
    }
}


} // DF

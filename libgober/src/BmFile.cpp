#include "BmFile.h"

#include "CompressedBuffer.h"

#include <cassert>

namespace DF
{

BmFileSubHeader BmFile::GetSubHeader(size_t index) const
{
    assert(IsMultipleBm() && index < GetCountSubBms());
    
    int32_t offset = GetSubOffset(index);
    BmFileSubHeader header;
    (void)m_data.ReadObj<BmFileSubHeader>(&header, offset);
    return header;
}

size_t BmFile::GetData(size_t index, uint8_t* output, size_t max) const
{
     return CompressedBufferReader::ReadCompressedData(
        m_data,
        GetCompression(),
        output,
        GetImageDataStart(index, 0) - m_data.Get(0),
        max);
}

int32_t BmFile::GetSubOffset(size_t index) const
{
    assert(IsMultipleBm() && index < GetCountSubBms());

    const int32_t* startTable = m_data.GetObj<int32_t>(sizeof(BmFileHeader) + 2);
    return startTable[index] + sizeof(BmFileHeader) + 2;
}

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

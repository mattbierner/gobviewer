#include "FmeFile.h"

#include "CompressedBuffer.h"

namespace DF
{

FmeFileHeader FmeFile::GetHeader() const
{
    FmeFileHeader header;
    (void)m_data->ReadObj<FmeFileHeader>(&header, 0);
    return header;
}

FmeFileHeader2 FmeFile::GetHeader2() const
{
    auto header = GetHeader();
    FmeFileHeader2 header2;
    (void)m_data->ReadObj<FmeFileHeader2>(&header2, m_data->ResolveOffset(header.header2));
    return header2;
}

size_t FmeFile::Read(uint8_t* output, size_t offset, size_t max) const
{
    const uint8_t* start = m_data->Get(0);
    return CompressedBufferReader::ReadCompressedData(
        *m_data,
        GetCompression(),
        output,
        (GetImageDataStart() - start) + offset,
        max);
}

const uint8_t* FmeFile::GetImageDataStart() const
{
    size_t header2Offset = m_data->ResolveOffset(GetHeader().header2);
    size_t dataOffset = header2Offset + sizeof(FmeFileHeader2);
    if (IsCompressed())
    {
        size_t imgDataOffset = dataOffset + sizeof(uint32_t) * GetWidth();
        return m_data->Get(imgDataOffset);
        /*
        // TODO: why is table offset not working here?
        const uint32_t* tableEntry = m_data->GetObj<uint32_t>(tableOffset);
        if (tableEntry)
            return m_data->Get(sizeof(FmeFileHeader) + *tableEntry);
        else
            return nullptr;
        */
    }
    else
    {
        return m_data->Get(dataOffset);
    }
}

} // DF

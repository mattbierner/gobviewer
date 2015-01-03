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

Buffer FmeFile::Uncompress() const
{
    size_t size = GetDataSize();
    DF::Buffer data = DF::Buffer::Create(size);

    CompressedBufferReader::ReadCompressedData(
        *m_data,
        GetCompression(),
        data.Get(0),
        GetImageDataStart(),
        size);
    return data;
}

Bitmap FmeFile::CreateBitmap() const
{
    unsigned width = GetWidth();
    unsigned height = GetHeight();
    BmFileTransparency transparent = BmFileTransparency::Transparent;
    if (IsCompressed())
    {
        // Uncompress data.
        return Bitmap(width, height, transparent, Uncompress());
    }
    else
    {
        return Bitmap(width, height, transparent, std::make_unique<RelativeOffsetBuffer>(m_data, GetImageDataStart()));
    }
}

const size_t FmeFile::GetImageDataStart() const
{
    size_t header2Offset = m_data->ResolveOffset(GetHeader().header2);
    size_t dataOffset = header2Offset + sizeof(FmeFileHeader2);
    if (IsCompressed())
    {
        size_t imgDataOffset = dataOffset + sizeof(uint32_t) * GetWidth();
        return imgDataOffset;
    }
    else
    {
        return dataOffset;
    }
}

} // DF

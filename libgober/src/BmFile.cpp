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
    (void)m_data->ReadObj<BmFileSubHeader>(&header, offset);
    return header;
}

Buffer BmFile::Uncompress(size_t index) const
{
    size_t size = GetDataSize(index);
    DF::Buffer data = DF::Buffer::Create(size);

    CompressedBufferReader::ReadCompressedData(
        *m_data,
        GetCompression(),
        data.Get(0),
        GetImageDataStart(index),
        size);
    return data;
}

Bitmap BmFile::CreateBitmap(size_t index) const
{
    unsigned width = GetWidth(index);
    unsigned height = GetHeight(index);
    BmFileTransparency transparency = GetTransparency();
    
    if (IsCompressed())
    {
        return Bitmap(width, height, transparency, Uncompress(index));
    }
    else
    {
        return Bitmap(
            width,
            height,
            transparency,
            std::make_unique<RelativeOffsetBuffer>(m_data, GetImageDataStart(index), GetDataSize(index)));
    }
}

Bm BmFile::CreateBm() const
{
    size_t count = GetCountSubBms();
    
    auto bitmaps = std::vector<std::shared_ptr<Bitmap>>();
    bitmaps.reserve(count);
    for (unsigned i = 0; i < count; ++i)
        bitmaps.push_back(std::make_shared<Bitmap>(std::move(CreateBitmap(i))));
    
    return Bm(
        GetFrameRate(),
        IsSwitch(),
        std::move(bitmaps));
}

int32_t BmFile::GetSubOffset(size_t index) const
{
    assert(IsMultipleBm() && index < GetCountSubBms());

    const uint32_t* startTable = m_data->GetObj<uint32_t>(sizeof(BmFileHeader) + 2);
    return startTable[index] + sizeof(BmFileHeader) + 2;
}

const size_t BmFile::GetImageDataStart(size_t index) const
{
    if (IsCompressed())
    {
        size_t dataOffset = sizeof(BmFileHeader);
        size_t tableOffset = dataOffset + GetHeader().dataSize;
        const uint32_t* tableEntry = m_data->GetObj<uint32_t>(tableOffset);
        if (tableEntry)
            return dataOffset + *tableEntry;
        else
            return 0;
    }
    else
    {
        return (IsMultipleBm() ? GetSubOffset(index) + sizeof(BmFileSubHeader) : sizeof(BmFileHeader));
    }
}

} // DF

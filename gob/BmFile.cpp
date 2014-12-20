#include "BmFile.h"

namespace DF
{

size_t BmFile::ReadUncompressedBmData(size_t index, uint8_t* output, size_t max) const
{
    auto size = GetDataSize();
    size_t read = std::min(size, max);
    size_t offset = (GetColumnStart(index, 0) - m_data.Get());
    Read(output, offset, read);
    return read;
}

size_t BmFile::ReadRleCompressedBmData(uint8_t* output, size_t max) const
{
    size_t read = 0;
    const uint8_t* start = GetColumnStart(0, 0);
    for (unsigned col = 0; col < GetWidth() && read < max; ++col)
    {
        const uint8_t* end = GetColumnEnd(0, col);
        while (start < end && read < max)
        {
            uint8_t n = *(start++);
            if (n <= 128)
            {
                // copy `n` direct values
                size_t offset = start - m_data.Get(0);
                size_t numRead = Read(output + read, offset, n);
                start += n;
                read += numRead;
            }
            else
            {
                // Repeat next byte `n - 128` times
                auto next = *(start++);
                uint8_t reps = n - 128;
                size_t toRead = std::min(static_cast<size_t>(reps), max - read);
                std::fill_n(output + read, toRead, next);
                read += toRead;
            }
        }
    }
    return read;
}

size_t BmFile::ReadRle0CompressedBmData(uint8_t* output, size_t max) const
{
    size_t read = 0;
    const uint8_t* start = GetColumnStart(0, 0);
    for (unsigned col = 0; col < GetWidth() && read < max; ++col)
    {
        const uint8_t* end = GetColumnEnd(0, col);
        while (start < end && read < max)
        {
            uint8_t n = *(start++);
            if (n <= 128)
            {
                // copy `n` direct values
                size_t offset = start - m_data.Get(0);
                size_t numRead = Read(output + read, offset, n);
                start += n;
                read += numRead;
            }
            else
            {
                // Create `n - 128` transparent pixels
                uint8_t reps = n - 128;
                size_t toRead = std::min(static_cast<size_t>(reps), max - read);
                std::fill_n(output + read, toRead, 0);
                read += toRead;
            }
        }
    }
    return read;
}

const uint8_t* BmFile::GetColumnStart(size_t index, size_t col) const
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
        size_t dataOffset = (IsMultipleBm() ? GetSubOffset(index) + sizeof(BmFileSubHeader) : sizeof(BmFileHeader));
        size_t colOffset = col * GetWidth(index);
        return m_data.Get(dataOffset + colOffset);
    }
}

const uint8_t* BmFile::GetColumnEnd(size_t index, size_t col) const
{
    if (col == GetWidth() - 1) // end
    {
        return m_data.Get(sizeof(BmFileHeader) + (IsCompressed() ? GetHeader().dataSize : GetDataSize(index)));
    }
    else
    {
        return GetColumnStart(index, col + 1);
    }
}


} // DF

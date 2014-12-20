#include "BmFile.h"

namespace DF
{

size_t BmFile::ReadUncompressedBmData(uint8_t* output, size_t max)
{
    auto size = GetDataSize();
    size_t read = std::min(size, max);
    Read(output, sizeof(BmFileHeader), read);
    return read;
}

size_t BmFile::ReadRleCompressedBmData(uint8_t* output, size_t max)
{
    size_t read = 0;
    uint8_t* start = GetColumnStart(0);
    for (unsigned col = 0; col < GetWidth() && read < max; ++col)
    {
        uint8_t* end = GetColumnEnd(col);
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

size_t BmFile::ReadRle0CompressedBmData(uint8_t* output, size_t max)
{
    size_t read = 0;
    uint8_t* start = GetColumnStart(0);
    for (unsigned col = 0; col < GetWidth() && read < max; ++col)
    {
        uint8_t* end = GetColumnEnd(col);
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

uint8_t* BmFile::GetColumnStart(size_t col)
{
    if (IsCompressed())
    {
        size_t tableOffset = sizeof(BmFileHeader) + GetHeader().dataSize + (col * sizeof(int32_t));
        int32_t* tableEntry = m_data.Get<int32_t>(tableOffset);
        if (tableEntry)
            return m_data.Get(sizeof(BmFileHeader) + *tableEntry);
        else
                return nullptr;
    }
    else
    {
        size_t colOffset = col * GetWidth();
        return m_data.Get(sizeof(BmFileHeader) + colOffset);
    }
}

uint8_t* BmFile::GetColumnEnd(size_t col)
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

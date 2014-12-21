#include "FmeFile.h"

namespace DF
{

size_t FmeFile::ReadUncompressedBmData(uint8_t* output, size_t max) const
{
    auto size = GetDataSize();
    size_t read = std::min(size, max);
    size_t offset = (GetColumnStart(0) - m_data.Get());
    Read(output, offset, read);
    return read;
}

size_t FmeFile::ReadRle0CompressedBmData(uint8_t* output, size_t max) const
{
    size_t read = 0;
    const uint8_t* start = GetColumnStart(0);
    for (unsigned col = 0; col < GetWidth() && read < max; ++col)
    {
        const uint8_t* end = GetColumnEnd(col);
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

const uint8_t* FmeFile::GetColumnStart(size_t col) const
{
    if (IsCompressed())
    {
        size_t tableOffset = GetHeader().header2 + sizeof(FmeFileHeader2) + (col * sizeof(int32_t));
        const int32_t* tableEntry = m_data.Get<int32_t>(tableOffset);
        if (tableEntry)
            return m_data.Get(sizeof(FmeFileHeader) + *tableEntry);
        else
            return nullptr;
    }
    else
    {
        size_t dataOffset = GetHeader().header2 + sizeof(FmeFileHeader2);
        size_t colOffset = col * GetWidth();
        return m_data.Get(dataOffset + colOffset);
    }
}

const uint8_t* FmeFile::GetColumnEnd(size_t col) const
{
    if (col == GetWidth() - 1) // end
    {
        
        return m_data.Get(GetHeader().header2 + sizeof(FmeFileHeader2) + (IsCompressed() ? GetHeader2().dataSize : GetDataSize()));
    }
    else
    {
        return GetColumnStart(col + 1);
    }
}


} // DF

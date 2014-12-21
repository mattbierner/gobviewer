#include "BitmapFile.h"

namespace DF
{

size_t BitmapFileData::ReadUncompressedBmData(uint8_t* output, size_t max) const
{
    auto size = GetDataSize();
    size_t read = std::min(size, max);
    ReadFrom(output, GetColumnStart(0), read);
    return read;
}

size_t BitmapFileData::ReadRleCompressedBmData(uint8_t* output, size_t max) const
{
    size_t read = 0;
    const uint8_t* start = GetColumnStart(0);
    while (read < max)
    {
        uint8_t n = *(start++);
        if (n <= 128)
        {
            // copy `n` direct values
            size_t numRead = ReadFrom(output + read, start, n);
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
    return read;
}

size_t BitmapFileData::ReadRle0CompressedBmData(uint8_t* output, size_t max) const
{
    size_t read = 0;
    const uint8_t* start = GetColumnStart(0);
    while (read < max)
    {
        uint8_t n = *(start++);
        if (n <= 128)
        {
            // copy `n` direct values
            size_t numRead = ReadFrom(output + read, start, n);
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
    return read;
}

} // DF

#include "CompressedBuffer.h"

namespace DF
{

/*static*/ size_t CompressedBufferReader::ReadCompressedData(
    const Buffer& buffer,
    BmFileCompression compression,
    uint8_t* output,
    size_t offset,
    size_t max)
{
    switch (compression)
    {
    case BmFileCompression::Rle:
        return ReadRleCompressedData(buffer, output, offset, max);

    case BmFileCompression::Rle0:
        return ReadRle0CompressedData(buffer, output, offset, max);

    case BmFileCompression::None:
    default:
        return buffer.Read(output, offset, max);
    }
}

/*static*/ size_t CompressedBufferReader::ReadRleCompressedData(const Buffer& buffer, uint8_t* output, size_t offset, size_t max)
{
    size_t read = 0;
    const uint8_t* start = buffer.Get(offset);
    while (read < max)
    {
        uint8_t n = *(start++);
        if (n <= 128)
        {
            // copy `n` direct values
            size_t numRead = buffer.ReadFrom(output + read, start, n);
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

/*static*/ size_t CompressedBufferReader::ReadRle0CompressedData(const Buffer& buffer, uint8_t* output,  size_t offset, size_t max)
{
    size_t read = 0;
    const uint8_t* start = buffer.Get(offset);
    while (read < max)
    {
        uint8_t n = *(start++);
        if (n <= 128)
        {
            // copy `n` direct values
            size_t numRead = buffer.ReadFrom(output + read, start, n);
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
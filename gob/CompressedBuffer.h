#pragma once

#include "Buffer.h"

#include "BmFileData.h"
#include "BufferWriter.h"

namespace DF
{

class CompressedBufferReader
{
public:
    static size_t ReadCompressedData(
        const Buffer& buffer,
        BmFileCompression compression,
        uint8_t* output,
        size_t offset,
        size_t max);

private:
    static BufferWriter ReadRleCompressedData(const Buffer& buffer, size_t offset, BufferWriter writer);
    
    static BufferWriter ReadRle0CompressedData(const Buffer& buffer, size_t offset, BufferWriter writer);
};

} // DF
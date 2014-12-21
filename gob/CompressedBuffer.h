#pragma once

#include "Buffer.h"

#include "BmFileData.h"

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
    static size_t ReadRleCompressedData(const Buffer& buffer, uint8_t* output, size_t offset, size_t max);
    
    static size_t ReadRle0CompressedData(const Buffer& buffer, uint8_t* output, size_t offset, size_t max);
};

} // DF
#include "GobFile.h"

namespace DF
{

void GobFile::Init()
{
    auto index = GetIndex();
    for (unsigned i = 0; i < index.count; ++i)
    {
        auto entry = GetEntry(i);
        std::string filename(entry.filename);
        m_files.push_back(filename);
        m_entries[filename] = {TypeForFileName(filename), entry.offset, entry.size};
    }
}

GobFileIndex GobFile::GetIndex()
{
    auto header = GetHeader();
    GobFileIndex index;
    Read<GobFileIndex>(&index, header.indexOffset);
    return index;
}

GobFileEntry GobFile::GetEntry(size_t i)
{
    auto header = GetHeader();
    size_t startOffset = header.indexOffset + offsetof(GobFileIndex, entries);
    size_t offset = startOffset + i * sizeof(GobFileEntry);

    GobFileEntry entry;
    Read<GobFileEntry>(&entry, offset);
    return entry;
}

void GobFile::Read(uint8_t* output, size_t offset, size_t max)
{
    m_dataProvider->Read(output, offset, max);
}

} // DF
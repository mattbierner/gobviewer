#include "WaxFile.h"

#include <cassert>

template <typename T, size_t N>
constexpr bool InExtent(const T(&)[N], size_t index)
{
    return (index < N);
}

namespace DF
{

unsigned WaxFileSequence::GetFramesCount() const
{
    auto header = GetHeader();
    return static_cast<unsigned>(
        std::count_if(
            std::begin(header.frames),
            std::end(header.frames),
            [](uint32_t offset) { return (offset > 0); }));
}

FmeFile WaxFileSequence::GetFrame(unsigned index) const
{
    assert(index < GetFramesCount());
    auto header = GetHeader();
    size_t dataOffset = header.frames[index];
    size_t offset = dataOffset;
    return FmeFile(std::make_shared<RelativeOffsetBuffer>(m_data, offset));
}

size_t WaxFileSequence::GetDataUid(unsigned index) const
{
    assert(index < GetFramesCount());
    auto header = GetHeader();
    
    return header.frames[index];
}

WaxFileSequence WaxFileWax::GetSequence(unsigned index) const
{
    assert(index < GetSequencesCount());
    auto header = GetHeader();
    size_t offset = header.sequences[index];
    
    return WaxFileSequence(m_data, offset);
}

std::vector<size_t> WaxFile::GetActions() const
{
    auto header = GetHeader();
    
    std::vector<size_t> indicies;
    for (unsigned i = 0; i < std::extent<decltype(header.waxes)>(); ++i)
        if (header.waxes[i])
            indicies.push_back(i);
    return indicies;
}

bool WaxFile::HasWax(size_t index) const
{
    auto header = GetHeader();
    return (InExtent(header.waxes, index) && header.waxes[index] > 0);
}

WaxFileWax WaxFile::GetAction(size_t index) const
{
    assert(HasWax(index));
    auto header = GetHeader();
    size_t offset = header.waxes[index];
    
    return WaxFileWax(m_data, offset);
}

} // DF

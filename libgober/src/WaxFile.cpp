#include "WaxFile.h"

#include <cassert>

template <typename T, size_t N>
constexpr bool InExtent(const T(&)[N], unsigned index)
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

unsigned WaxFileWax::GetSequencesCount() const
{
    auto header = GetHeader();
    return static_cast<unsigned>(
        std::count_if(
            std::begin(header.sequences),
            std::end(header.sequences),
            [](uint32_t offset) { return (offset > 0); }));
}

WaxFileSequence WaxFileWax::GetSequence(unsigned index) const
{
    assert(index < GetSequencesCount());
    auto header = GetHeader();
    size_t offset = header.sequences[index];
    
    return WaxFileSequence(m_data, offset);
}

unsigned WaxFile::GetWaxesCount() const
{
    auto header = GetHeader();
    return static_cast<unsigned>(
        std::count_if(
            std::begin(header.waxes),
            std::end(header.waxes),
            [](uint32_t offset) { return (offset > 0); }));
}

bool WaxFile::HasWax(unsigned index) const
{
    auto header = GetHeader();
    return (InExtent(header.waxes, index) && header.waxes[index] > 0);
}

WaxFileWax WaxFile::GetWax(unsigned index) const
{
    assert(HasWax(index));
    auto header = GetHeader();
    size_t offset = header.waxes[index];
    
    return WaxFileWax(m_data, offset);
}

} // DF

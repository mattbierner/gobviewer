#pragma once

#include "WaxFileData.h"
#include "DataReader.h"
#include "Buffer.h"

namespace DF
{

/**
*/
class WaxFileSequence
{
public:
    WaxFileSequence(std::shared_ptr<Buffer> data, size_t offset) :
        m_data(std::move(data)),
        m_offset(offset)
    { }
    
    /**
        Get the number of sequences in the wax stored.
    */
    unsigned GetFramesCount() const
    {
        auto header = GetHeader();
        for (unsigned i = 0; i < 32; ++i)
            if (header.frames[i] == 0)
                return i;
        return 32;
    }
    
    /**
    */
    FmeFile GetFrame(unsigned index) const
    {
        assert(index < GetFramesCount());
        auto header = GetHeader();
        size_t dataOffset = header.frames[index];
        size_t offset = dataOffset;
        return FmeFile(std::make_shared<RelativeOffsetBuffer>(m_data, offset));
    }

private:
    std::shared_ptr<IBuffer> m_data;
    size_t m_offset;
    
    /**
        Get the main file header.
    */
    Sequence GetHeader() const
    {
        Sequence header;
        (void)m_data->ReadObj<Sequence>(&header, m_offset);
        return header;
    }
};

/**
*/
class WaxFileWax
{
public:
    WaxFileWax(std::shared_ptr<Buffer> data, size_t offset) :
        m_data(std::move(data)),
        m_offset(offset)
    { }
    
    unsigned GetWorldWidth() const { return GetHeader().worldWidth; }
    
    unsigned GetWorldHeight() const { return GetHeader().worldHeight; }

    unsigned GetFrameRate() const { return GetHeader().frameRate; }

    /**
        Get the number of sequences in the wax stored.
    */
    unsigned GetSequencesCount() const
    {
        auto header = GetHeader();
        for (unsigned i = 0; i < 32; ++i)
            if (header.sequences[i] == 0)
                return i;
        return 32;
    }
    
    WaxFileSequence GetSequence(unsigned index) const
    {
        assert(index < GetSequencesCount());
        auto header = GetHeader();
        size_t offset = header.sequences[index];
        
        return WaxFileSequence(m_data, offset);
    }
    
private:
    std::shared_ptr<Buffer> m_data;
    size_t m_offset;
    
    /**
        Get the main file header.
    */
    Wax GetHeader() const
    {
        Wax header;
        (void)m_data->ReadObj<Wax>(&header, m_offset);
        return header;
    }
};


/**
    WaxFile file view.
*/
class WaxFile
{
public:
    /**
        Create a BM file from data in a file stream.
    */
    static WaxFile CreateFromDataProvider(const IDataReader& dataProvider)
    {
        return WaxFile(Buffer::CreateFromDataProvider(dataProvider));
    }
    
    WaxFile() { }
    
    WaxFile(Buffer&& data) :
        m_data(std::make_shared<Buffer>(std::move(data)))
    { }
    
    /**
        Get the number of waxes stored.
    */
    unsigned GetWaxesCount() const
    {
        auto header = GetHeader();
        for (unsigned i = 0; i < 32; ++i)
            if (header.waxes[i] == 0)
                return i;
        return 32;
    }
    
    WaxFileWax GetWax(unsigned index) const
    {
        assert(index < GetWaxesCount());
        auto header = GetHeader();
        size_t offset = header.waxes[index];
        
        return WaxFileWax(m_data, offset);
    }
    
private:
    std::shared_ptr<Buffer> m_data;
    
    /**
        Get the main file header.
    */
    WaxFileHeader GetHeader() const
    {
        WaxFileHeader header;
        (void)m_data->ReadObj<WaxFileHeader>(&header, 0);
        return header;
    }
    
};


} // DF


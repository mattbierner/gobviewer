#pragma once

#include <gober/Buffer.h>
#include <gober/DataReader.h>
#include <gober/FmeFile.h>
#include <gober/WaxFileData.h>

namespace DF
{

/**
*/
class WaxFileSequence
{
public:
    WaxFileSequence(const std::shared_ptr<Buffer>& data, size_t offset) :
        m_data(data),
        m_offset(offset)
    { }
    
    /**
        Get the number of frames in the sequence.
    */
    unsigned GetFramesCount() const;
    
    /**
    */
    FmeFile GetFrame(unsigned index) const;
    
    /**
        Get an id that uniquly identifies the image data with in single wax.
        
        Multiple frames may share the same image data but use FME headers.
    */
    size_t GetDataUid(unsigned index) const;

private:
    std::shared_ptr<IBuffer> m_data;
    size_t m_offset;
    
    /**
        Get the main file header.
    */
    WaxFileSequenceEntry GetHeader() const
    {
        WaxFileSequenceEntry header;
        (void)m_data->ReadObj<WaxFileSequenceEntry>(&header, m_offset);
        return header;
    }
};

/**
*/
class WaxFileWax
{
public:
    WaxFileWax(const std::shared_ptr<Buffer>& data, size_t offset) :
        m_data(data),
        m_offset(offset)
    { }
    
    unsigned GetWorldWidth() const { return GetHeader().worldWidth; }
    
    unsigned GetWorldHeight() const { return GetHeader().worldHeight; }

    unsigned GetFrameRate() const { return GetHeader().frameRate; }

    /**
        Get the number of views stored in the wax.
    */
    unsigned GetSequencesCount() const { return 32; }
    
    /**
        Get the animation for a specific view.
        
        This always returns a new WaxFileSequence, but it may be identical to
        other views.
    */
    WaxFileSequence GetSequence(unsigned index) const;
    
private:
    std::shared_ptr<Buffer> m_data;
    size_t m_offset;
    
    /**
        Get the main file header.
    */
    WaxFileWaxEntry GetHeader() const
    {
        WaxFileWaxEntry header;
        (void)m_data->ReadObj<WaxFileWaxEntry>(&header, m_offset);
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
        Get the indicies on the wax actions.
    */
    std::vector<size_t> GetActions() const;
    
    /**
        Does this wax file have a given wax animation entry?
    */
    bool HasWax(size_t index) const;
    
    /**
    */
    WaxFileWax GetAction(size_t index) const;
    
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


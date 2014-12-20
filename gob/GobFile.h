#pragma once

#include "GobFileData.h"
#include "DataProvider.h"

#include <cassert>
#include <map>

namespace DF
{

/**
    Gob file view.
    
    Allows reading from a Gob file.
*/
class GobFile
{
    struct Entry
    {
        int32_t offset;
        int32_t size;
    };
    
    using FileMap = std::map<std::string, Entry>;

public:
    /**
        Create a Gob file from data in a file stream.
    */
    static GobFile CreateFromFile(std::ifstream&& fs)
    {
        return GobFile(std::make_unique<FileDataProvider>(std::move(fs)));
    }

    GobFile() { };

    /**
        Get a list of all filenames in the Gob.
    */
    std::vector<std::string> GetFilenames() const
    {
        std::vector<std::string> names;
        std::transform(
            std::begin(m_entries),
            std::end(m_entries),
            std::back_inserter(names),
            [](const auto& entry) { return entry.first; });
        return names;
    }
    
    /**
       Does an entry for `filename` exist?
    */
    bool HasFile(const std::string& filename) const
    {
        return (m_entries.find(filename) != std::end(m_entries));
    }
    
    /**
        Get the size of a file in the Gob.
        
        Returns 0 if the file does not exist.
    */
    size_t GetFileSize(const std::string& filename)
    {
        if (HasFile(filename))
            return GetFile(filename).size;
        return 0;
    }
    
    /**
        Read part of a file into a buffer.
     
        @param filename Name of file to read.
        @param buffer Memory to write result to.
        @param offset Relative offset within the file.
        @param max Maximum number of bytes to read.
    */
    size_t ReadFile(const std::string& filename, uint8_t* buffer, size_t offset, size_t max)
    {
        if (!HasFile(filename))
            return 0;
        
        auto entry = GetFile(filename);
        if (offset > entry.size)
            return 0;
        
        size_t read = std::min(entry.size - offset, max);
        Read(buffer, entry.offset + offset, read);
        return read;
    }
    
private:
    std::unique_ptr<IDataProvider> m_dataProvider;

    FileMap m_entries;
    
    GobFile(std::unique_ptr<IDataProvider>&& dataProvider) :
        m_dataProvider(std::move(dataProvider))
    {
        m_entries = Init();
    }

    /**
        Initilize the internal data structures using the data provider.
    */
    FileMap Init()
    {
        FileMap fileMap;
        auto index = GetIndex();
        for (unsigned i = 0; i < index.count; ++i)
        {
            auto entry = GetEntry(i);
            fileMap[std::string(entry.filename)] = { entry.offset, entry.size };
        }
        return fileMap;
    }
    
    Entry GetFile(const std::string& filename)
    {
        return m_entries[filename];
    }
    
    /**
        Read the file header.
    */
    GobFileHeader GetHeader()
    {
        GobFileHeader header;
        Read<GobFileHeader>(&header, 0);
        return header;
    }
    
    /**
        Read the file index.
    */
    GobFileIndex GetIndex()
    {
        auto header = GetHeader();
        GobFileIndex index;
        Read<GobFileIndex>(&index, header.indexOffset);
        return index;
    }
    
    /**
        Read an entry in the file index.
    */
    GobFileEntry GetEntry(size_t i)
    {
        auto header = GetHeader();
        size_t startOffset = header.indexOffset + offsetof(GobFileIndex, entries);
        size_t offset = startOffset + i * sizeof(GobFileEntry);

        GobFileEntry entry;
        Read<GobFileEntry>(&entry, offset);
        return entry;
    }
    
    /**
        Read an object of type `T` from the Gob.
    */
    template <typename T>
    void Read(T* output, size_t offset)
    {
        Read(reinterpret_cast<uint8_t*>(output), offset, sizeof(T));
    }
    
    /**
        Read `max` bytes at absolute position `offset` from the gob.
    */
    void Read(uint8_t* output, size_t offset, size_t max)
    {
        m_dataProvider->Read(output, offset, max);
    }
};

} // DF


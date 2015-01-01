#pragma once

#include "GobFileData.h"
#include "DataReader.h"

#include <cassert>
#include <map>
#include <vector>

namespace DF
{

/**
    Type of a file stored in a Gob.
*/
enum class FileType
{
    Unknown,
    Bm,
    Fme,
    Wax
};

/**
    Maps file extensions used in dark forces to file types.
*/
static const std::map<std::string, FileType> fileTypeMap = {
    {"BM", FileType::Bm},
    {"FME", FileType::Fme},
    {"WAX", FileType::Wax}
};

/**
    Gob file view.
    
    Allows reading from a Gob file.
*/
class GobFile
{
    struct Entry
    {
        FileType type;
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
        return m_files;
    }
    
    /**
        Get a list of all filenames in the Gob.
    */
    std::vector<std::string> GetFilenamesOfType(FileType type) const
    {
        std::vector<std::string> list;
        for (const auto& mapping : m_entries)
            if (mapping.second.type == type)
                list.push_back(mapping.first);
        return m_files;
    }
    
    /**
       Does an entry for `filename` exist?
    */
    std::string GetFilename(size_t index) const
    {
        return m_files[index];
    }
    
    FileType GetFileType(const std::string& filename) const
    {
        return m_entries.at(filename).type;
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
    static FileType TypeForFileName(const std::string& filename)
    {
        auto extPos = filename.find(".");
        if (extPos != std::string::npos)
        {
            std::string ext = filename.substr(extPos + 1);
            auto type = fileTypeMap.find(ext);
            if (type != std::end(fileTypeMap))
            {
                return type->second;
            }
        }
        return FileType::Unknown;
    }

    std::unique_ptr<IDataReader> m_dataProvider;

    std::vector<std::string> m_files;
    FileMap m_entries;
    
    GobFile(std::unique_ptr<IDataReader>&& dataProvider) :
        m_dataProvider(std::move(dataProvider))
    {
        Init();
    }

    /**
        Initilize the internal data structures using the data provider.
    */
    void Init();
    
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
    GobFileIndex GetIndex();
    
    /**
        Read an entry in the file index.
    */
    GobFileEntry GetEntry(size_t i);
    
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
    void Read(uint8_t* output, size_t offset, size_t max);
};

} // DF


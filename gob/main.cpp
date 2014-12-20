#include <iostream>

#include <iostream>
#include <fstream>
#include <vector>
#include <iomanip>

#include "GobFileData.h"
#include "GobFile.h"
#include "BmFile.h"


DF::GobFileHeader parse(const char* file)
{
    std::ifstream fs;
    fs.open(file, std::ifstream::binary | std::ifstream::in);
    if (fs.is_open())
    {
        auto x = DF::GobFile::CreateFromFile(std::move(fs));
        
        //for (auto a : x.GetFilenames())
        //    std::cout << a <<" " << x.GetFileSize(a) << std::endl;

        std::string file("GPDIRTDK.BM");
        size_t size = x.GetFileSize(file);
        uint8_t* buffer = new uint8_t[size];
        x.ReadFile(file, buffer, 0, size);
        
        auto bm = DF::BmFile::CreateFromBuffer(buffer, size);
        return {};
    }
    return {};
}

int main(int argc, const char * argv[])
{
    parse("TEXTURES.GOB");
    return 0;
}

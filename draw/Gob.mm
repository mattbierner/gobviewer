#import "Gob.h"

#include <gob/Buffer.h>

@implementation Gob

+ (Gob*) createFromFile:(NSURL*)path
{
    std::string filename([path.path UTF8String]);
    
    std::ifstream fs;
    fs.open(filename, std::ifstream::binary | std::ifstream::in);
    auto gob = std::make_shared<Df::GobFile>(Df::GobFile::CreateFromFile(std::move(fs)));
    
    return [[Gob alloc] initWithGob:gob];
}

- (id) initWithGob:(std::shared_ptr<Df::GobFile>)gob
{
    if (self = [super init])
    {
        _gob = gob;
    }
    return self;
}

- (Df::FileType) getFileType:(NSString*)file
{
    return Df::GobFile::GetFileType([file UTF8String]);
}

- (NSString*) getFilename:(NSUInteger)index
{
    std::string filename = _gob->GetFilename(index);
    return [NSString stringWithUTF8String:filename.c_str()];
}

- (NSUInteger) getNumberOfFiles
{
    return _gob->GetFilenames().size();
}

- (NSData*) readFile:(NSString*)file
{
    auto buffer = [self readFileToBuffer:file];
    if (buffer.IsReadable())
        return [NSData dataWithBytes:buffer.GetR(0) length:buffer.GetDataSize()];
    return nil;
}

/**
    Read one of the files stored in the Gob and store the result in a buffer.
*/
- (Df::Buffer) readFileToBuffer:(NSString*)file
{
    std::string filename([file UTF8String]);
    
    size_t size = _gob->GetFileSize(filename);
    Df::Buffer buffer = Df::Buffer::Create(size);
    size_t written = _gob->ReadFile(filename, buffer.GetW(0), 0, size);
    if (written == size)
        return buffer;
    else
        return Df::Buffer();
}

@end

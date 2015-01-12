#import "Pal.h"

#include <gober/Buffer.h>
#include <gober/GobFile.h>
#include <gober/PalFile.h>

#include <iostream>

DF::GobFile open(const char* file)
{
    std::ifstream fs;
    fs.open(file, std::ifstream::binary | std::ifstream::in);
    if (fs.is_open())
    {
        return DF::GobFile::CreateFromFile(std::move(fs));
    }
    return { };
}

@implementation Pal

+ (Pal*) createFromGob:(NSString*)gobFile named:(NSString*)name;
{

    DF::GobFile gob = open([gobFile UTF8String]);
    
    std::string file([name UTF8String]);
    size_t size = gob.GetFileSize(file);
    DF::Buffer buffer = DF::Buffer::Create(size);
    gob.ReadFile(file, buffer.GetW(0), 0, size);
    DF::PalFile p(std::move(buffer));
    
    DF::PalFileData data;
    p.Read(reinterpret_cast<uint8_t*>(&data), 0, sizeof(DF::PalFileData));
    
    return [Pal createForPal:data];
}

+ (Pal*) createForPal:(DF::PalFileData)p
{
    Pal* pal = [[Pal alloc] init];
    pal->_pal = p;
    return pal;
}

- (DF::PalFileData) getData
{
    return _pal;
}

- (CGImageRef) createImage
{
    const unsigned width = 1;
    const unsigned height = 256;

    CGDataProviderRef imageData = CGDataProviderCreateWithData(
        NULL,
        _pal.colors,
        sizeof(_pal.colors),
        NULL);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imgRef = CGImageCreate(
        width,
        height,
        8,
        8 * 3,
        3,
        colorSpace,
        kCGBitmapByteOrderDefault | kCGImageAlphaNone,
        imageData,
        NULL,
        NO,
        kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(imageData);

    return imgRef;
}

- (NSColor*) getColor:(NSUInteger)index
{
    auto entry = _pal.colors[index];
    return [NSColor
        colorWithRed:entry.r / 255.0f
        green:entry.g / 255.0f
        blue:entry.b / 255.0f
        alpha:1.0f];
}

@end

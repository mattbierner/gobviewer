#import "Cmp.h"

#include "DfColor.h"
#include "Gob.h"
#include "Pal.h"

#include <gob/Buffer.h>
#include <gob/GobFile.h>
#include <gob/CmpFile.h>

void freeRGBData(void *info, const void *data, size_t size)
{
   delete[] ((RGB*)data);
}

@implementation Cmp

+ (Cmp*) createFromGob:(NSString*)gobFile named:(NSString*)name;
{
    Gob* gob = [Gob createFromFile:[NSURL URLWithString:gobFile]];
    auto buffer = [gob readFileToBuffer:name];
    return [Cmp createForCmp:Df::CmpFile(std::move(buffer))];
}

+ (Cmp*) createForCmp:(Df::CmpFile)p
{
    Cmp* cmp = [[Cmp alloc] init];
    cmp->_cmp = Df::Cmp::CreateFromFile(p);
    return cmp;
}

- (const uint8_t*) getData
{
    return _cmp.GetData();
}

- (CGImageRef) createImageForPal:(Pal*)pal
{
    const unsigned width = 8 * 256;
    const unsigned height = 4;
    
    RGB* data = new RGB[256 * 32];
    RGB* write = data;
    for (unsigned colorMap = 0; colorMap < 32; ++colorMap)
    {
        for (unsigned i = 0; i < 256; ++i)
        {
            auto index = _cmp.GetShading(colorMap, i);
            (*(write++)) = [pal getRgb:index];
        }
    }
    
    CGDataProviderRef imageData = CGDataProviderCreateWithData(
        NULL,
        data,
        sizeof(RGB) * 256 * 32,
        freeRGBData);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imgRef = CGImageCreate(
        width,
        height,
        8,
        8 * sizeof(RGB),
        width * sizeof(RGB),
        colorSpace,
        kCGBitmapByteOrderDefault | kCGImageAlphaLast,
        imageData,
        NULL,
        NO,
        kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(imageData);

    return imgRef;
}

- (CGImageRef) createImage
{
    const unsigned width = 8 * 256;
    const unsigned height = 4;

    auto data = _cmp.GetData();
    
    CGDataProviderRef imageData = CGDataProviderCreateWithData(
        NULL,
        data,
        sizeof(Df::CmpFileColorMap) * 32,
        NULL);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGImageRef imgRef = CGImageCreate(
        width,
        height,
        8,
        8 * 1,
        width,
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


@end

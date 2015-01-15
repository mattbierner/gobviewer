#import "Pal.h"

#include "Gob.h"

#include <gob/Buffer.h>
#include <gob/GobFile.h>
#include <gob/PalFile.h>

#include <iostream>

@implementation Pal

+ (Pal*) createFromGob:(NSString*)gobFile named:(NSString*)name;
{
    Gob* gob = [Gob createFromFile:[NSURL URLWithString:gobFile]];
    auto buffer = [gob readFileToBuffer:name];

    Df::PalFile p(std::move(buffer));
    Df::PalFileData data;
    p.Read(reinterpret_cast<uint8_t*>(&data), 0, sizeof(Df::PalFileData));
    
    return [Pal createForPal:data];
}

+ (Pal*) createForPal:(Df::PalFileData)p
{
    Pal* pal = [[Pal alloc] init];
    pal->_pal = p;
    return pal;
}

- (Df::PalFileData) getData
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

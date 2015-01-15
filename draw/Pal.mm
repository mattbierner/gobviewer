#import "Pal.h"

#import "Gob.h"
#import "DfColor.h"

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
    return [Pal createForPal:p];
}

+ (Pal*) createForPal:(Df::PalFile)p
{
    Pal* pal = [[Pal alloc] init];
    pal->_pal = Df::Pal::CreateFromFile(p);
    return pal;
}

- (const Df::PalFileColor*) getData
{
    return _pal.GetColors();
}

- (CGImageRef) createImage
{
    const unsigned width = 1;
    const unsigned height = 256;

    CGDataProviderRef imageData = CGDataProviderCreateWithData(
        NULL,
        _pal.GetColors(),
        sizeof(_pal.GetDataSize()),
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
    auto entry = _pal[index];
    return [NSColor
        colorWithRed:entry.r / 255.0f
        green:entry.g / 255.0f
        blue:entry.b / 255.0f
        alpha:1.0f];
}

- (RGB) getRgb:(NSUInteger)index
{
    auto color = _pal[index];
    return {color.r, color.g, color.b, 255};
}

@end

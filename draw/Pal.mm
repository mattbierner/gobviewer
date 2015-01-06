#import "Pal.h"

@implementation Pal

+ (Pal*) createForPal:(DF::PalFileData)p
{
    Pal* pal = [[Pal alloc] initWithPal:p];
    return pal;
}

- (id) initWithPal:(DF::PalFileData)pal
{
   _pal = pal;
   return self;
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

@end

#import "Pal.h"

@implementation Pal

+ (Pal*) createForPal:(DF::PalFileData)p
{
    Pal* pal = [[Pal alloc] initWithPal:p];
    return pal;
}

- (id) initWithPal:(DF::PalFileData)p
{
   pal = p;
   return self;
}

- (CGImageRef) createImage
{
    CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, pal.colors, sizeof(pal.colors), NULL);
    
    CGImageRef imgRef = CGImageCreate(
        1,
        256,
        8,
        8 * 3,
        3,
        CGColorSpaceCreateDeviceRGB(),
        kCGBitmapByteOrderDefault | kCGImageAlphaNone,
        imageData,
        NULL,
        NO,
        kCGRenderingIntentDefault);
    CGDataProviderRelease(imageData);
    return imgRef;
}

@end

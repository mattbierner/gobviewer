#import "Bitmap.h"

#import "ColorMap.h"
#import "Cmp.h"
#import "Gob.h"
#import "Pal.h"

#include <gob/Bm.h>
#include <gob/BmFile.h>

RGB* BmDataToRgb(const Df::IReadableBuffer& buffer, ColorMap* colorMap, bool trans)
{
    size_t size = buffer.GetDataSize();
    if (size == 0)
        return nullptr;
    
    RGB* imgData = new RGB[size];
    RGB* dataWriter = imgData;
    for (auto entry : buffer)
    {
        if (trans && entry == 0)
        {
            (*(dataWriter++)).a = 0;
        }
        else
        {
            (*(dataWriter++)) = [colorMap getRgb:entry];
        }
    }
    return imgData;
}

RGB* BmToRgb(const Df::Bitmap& bm, ColorMap* colorMap)
{
    return BmDataToRgb(
        bm,
        colorMap,
        (bm.GetTransparency() != Df::BmFileTransparency::Normal));
}

void freeRGB(void *info, const void *data, size_t size)
{
   delete[] ((RGB*)data);
}


@interface Bitmap()

/**
    Create an CGImage from a RGB array.
*/
+ (CGImageRef) createImage:(RGB*)imgData
    size:(size_t)dataSize
    width:(unsigned)width
    height:(unsigned)height;

/**
    Create a new NSImage from the bitmap data.
*/
- (NSImage*) createImage;

@end


@implementation Bitmap

+ (Bitmap*) createFromGob:(Gob*)gob name:(NSString*)filename colorMap:(ColorMap*)colorMap
{
    auto buffer = [gob readFileToBuffer:filename];
    auto bm = Df::Bm::CreateFromFile(Df::BmFile(std::move(buffer)));
    return [Bitmap createForBitmap:bm.GetBitmap(0) colorMap:colorMap];
}

+ (Bitmap*) createForBitmap:(std::shared_ptr<Df::Bitmap>)bitmap colorMap:(ColorMap*)colorMap
{
    Bitmap* t = [[Bitmap alloc] init];
    t->_bitmap = bitmap;
    t.colorMap = colorMap;
    return t;
}

+ (CGImageRef) createImage:(RGB*)imgData
    size:(size_t) dataSize
    width:(unsigned) width
    height:(unsigned) height
{
    CGDataProviderRef imageData = CGDataProviderCreateWithData(NULL, imgData, dataSize, freeRGB);
    CGImageRef img = CGImageCreate(
        width,
        height,
        8,
        8 * 4,
        4 * width,
        CGColorSpaceCreateDeviceRGB(),
        kCGBitmapByteOrderDefault | kCGImageAlphaLast,
        imageData,
        NULL,
        NO,
        kCGRenderingIntentDefault);
    
    CGDataProviderRelease(imageData);
    return img;
}

- (NSImage*) createImage
{
    RGB* imgData = BmToRgb(*_bitmap, self.colorMap);
    if (!imgData)
        return nullptr;
    
    unsigned width = _bitmap->GetWidth();
    unsigned height = _bitmap->GetHeight();
    size_t imgDataSize = _bitmap->GetDataSize() * 32;
    
    CGImageRef imageRef = [Bitmap createImage:imgData size: imgDataSize width:height height:width];
    NSImage* img = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeZero];
    CGImageRelease(imageRef);
    return img;
}

- (NSImage*) getImage
{
    if (!_image)
        _image = [self createImage];
    return _image;
}


@end

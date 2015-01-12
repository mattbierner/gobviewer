#import "Bitmap.h"

#import "Pal.h"

RGB* BmDataToRgb(const DF::IReadableBuffer& buffer, Pal* pal, bool trans)
{
    size_t size = buffer.GetDataSize();
    RGB* imgData = new RGB[size];
    RGB* dataWriter = imgData;
    
    auto palData = [pal getData];
    
    const uint8_t* bmData = buffer.GetR(0);
    const uint8_t* bmDataEnd = bmData + size;
    while (bmData < bmDataEnd)
    {
        uint8_t entry = *(bmData++);
        if (trans && entry == 0)
        {
            (*(dataWriter++)).a = 0;
        }
        else
        {
            auto palColors = palData.colors[entry];
            (*(dataWriter++)) = {palColors.r, palColors.g, palColors.b, 255};
        }
    }
    return imgData;
}

RGB* BmToRgb(const DF::Bitmap& bm, Pal* pal)
{
    return BmDataToRgb(bm, pal, (bm.GetTransparency() != DF::BmFileTransparency::Normal));
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

+ (Bitmap*) createForBitmap:(std::shared_ptr<DF::Bitmap>) bitmap pal:(Pal*)pal
{
    Bitmap* t = [[Bitmap alloc] init];
    t->_bitmap = bitmap;
    t.pal = pal;
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
    unsigned width = _bitmap->GetWidth();
    unsigned height = _bitmap->GetHeight();
    size_t imgDataSize = _bitmap->GetDataSize() * 32;
        
    RGB* imgData = BmToRgb(*_bitmap, self.pal);
    
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

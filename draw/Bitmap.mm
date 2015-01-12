#import "Bitmap.h"


RGB* BmDataToRgb(const DF::IReadableBuffer& buffer, const DF::PalFileData& pal, bool trans)
{
    size_t size = buffer.GetDataSize();
    RGB* imgData = new RGB[size];
    RGB* dataWriter = imgData;
    
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
            auto palColors = pal.colors[entry];
            (*(dataWriter++)) = {palColors.r, palColors.g, palColors.b, 255};
        }
    }
    return imgData;
}

RGB* BmToRgb(const DF::Bitmap& bm, const DF::PalFileData& pal)
{
    return BmDataToRgb(bm, pal, (bm.GetTransparency() != DF::BmFileTransparency::Normal));
}

void freeRGB(void *info, const void *data, size_t size)
{
   delete[] ((RGB*)data);
}


@implementation Bitmap

+ (Bitmap*) createForBitmap:(std::shared_ptr<DF::Bitmap>) bitmap
{
    Bitmap* t = [[Bitmap alloc] init];
    t->_bitmap = bitmap;
    return t;
}

+ (CGImageRef) createImage:(RGB*) imgData
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

- (NSImage*) createImage:(DF::PalFileData*)pal
{
    unsigned width = _bitmap->GetWidth();
    unsigned height = _bitmap->GetHeight();
    size_t imgDataSize = _bitmap->GetDataSize() * 32;
        
    RGB* imgData = BmToRgb(*_bitmap, *pal);
    
    CGImageRef imageRef = [Bitmap createImage:imgData size: imgDataSize width:height height:width];
    NSImage* img = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeZero];
    CGImageRelease(imageRef);
    return img;
}

- (NSImage*) getImage:(DF::PalFileData*)pal
{
    if (_image)
        return _image;
    else
        return [self createImage:pal];
}


@end

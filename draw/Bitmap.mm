#import "Bitmap.h"

#import "Gob.h"
#import "Pal.h"

#include <gob/Bm.h>
#include <gob/BmFile.h>


@implementation NSImage (Rotated)
 
- (NSImage *)imageRotated:(float)degrees {
 
    degrees = fmod(degrees, 360.);
    if (0 == degrees) {
        return self;
    }
    NSSize size = [self size];
    NSSize maxSize;
    if (90. == degrees || 270. == degrees || -90. == degrees || -270. == degrees) {
        maxSize = NSMakeSize(size.height, size.width);
    } else if (180. == degrees || -180. == degrees) {
        maxSize = size;
    } else {
        maxSize = NSMakeSize(20+MAX(size.width, size.height), 20+MAX(size.width, size.height));
    }
    NSAffineTransform *rot = [NSAffineTransform transform];
    [rot rotateByDegrees:degrees];
    NSAffineTransform *center = [NSAffineTransform transform];
    [center translateXBy:maxSize.width / 2. yBy:maxSize.height / 2.];
    [rot appendTransform:center];
    NSImage *image = [[NSImage alloc] initWithSize:maxSize];
    [image lockFocus];
    [rot concat];
    NSRect rect = NSMakeRect(0, 0, size.width, size.height);
    NSPoint corner = NSMakePoint(-size.width / 2., -size.height / 2.);
    [self drawAtPoint:corner fromRect:rect operation:NSCompositeCopy fraction:1.0];
    [image unlockFocus];
    return image;
}
@end

RGB* BmDataToRgb(const Df::IReadableBuffer& buffer, Pal* pal, bool trans)
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

RGB* BmToRgb(const Df::Bitmap& bm, Pal* pal)
{
    return BmDataToRgb(bm, pal, (bm.GetTransparency() != Df::BmFileTransparency::Normal));
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

+ (Bitmap*) createFromGob:(Gob*)gob name:(NSString*)filename pal:(Pal*)pal;
{
    auto buffer = [gob readFileToBuffer:filename];
    auto bm = Df::Bm::CreateFromFile(Df::BmFile(std::move(buffer)));
    return [Bitmap createForBitmap:bm.GetBitmap(0) pal:pal];
}

+ (Bitmap*) createForBitmap:(std::shared_ptr<Df::Bitmap>) bitmap pal:(Pal*)pal
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

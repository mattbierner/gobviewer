#import <Cocoa/Cocoa.h>

#include <gober/Bitmap.h>
#include <gober/PalFile.h>

#import "DfColor.h"


@class Pal;

/**
*/
@interface Bitmap : NSObject
{
    std::shared_ptr<DF::Bitmap> _bitmap;
    
    NSImage* _image;
}

@property (nonatomic, strong) Pal* pal;

/**
    Create a bitmap from DF bitmap object.
*/
+ (Bitmap*) createForBitmap:(std::shared_ptr<DF::Bitmap>) bitmap;

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
- (NSImage*) createImage:(DF::PalFileData*)pal;

/**
    Get the current NSImage associated with the bitmap data.
*/
- (NSImage*) getImage:(DF::PalFileData*)pal;



@end

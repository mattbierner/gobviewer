#import <Cocoa/Cocoa.h>

#include <gober/Bitmap.h>
#include <gober/GobFile.h>
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
+ (Bitmap*) createForBitmap:(std::shared_ptr<DF::Bitmap>) bitmap pal:(Pal*)pal;

+ (Bitmap*) createFormGob:(DF::GobFile*)gob name:(const char*)filename pal:(Pal*)pal;

/**
    Get the current NSImage associated with the bitmap data.
*/
- (NSImage*) getImage;


@end

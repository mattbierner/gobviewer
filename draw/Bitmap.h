#import <Cocoa/Cocoa.h>

#include <gob/Bitmap.h>
#include <gob/GobFile.h>
#include <gob/PalFile.h>

#import "DfColor.h"


@class Pal;

/**
*/
@interface Bitmap : NSObject
{
    std::shared_ptr<Df::Bitmap> _bitmap;
    
    NSImage* _image;
}

@property (nonatomic, strong) Pal* pal;

/**
    Create a bitmap from Df bitmap object.
*/
+ (Bitmap*) createForBitmap:(std::shared_ptr<Df::Bitmap>) bitmap pal:(Pal*)pal;

+ (Bitmap*) createFormGob:(Df::GobFile*)gob name:(const char*)filename pal:(Pal*)pal;

/**
    Get the current NSImage associated with the bitmap data.
*/
- (NSImage*) getImage;


@end

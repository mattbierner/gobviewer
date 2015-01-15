#import <Cocoa/Cocoa.h>

#include <gob/Bitmap.h>

#import "DfColor.h"

@class Cmp;
@class Gob;
@class Pal;

/**
    Generic bitmap object.
*/
@interface Bitmap : NSObject
{
    std::shared_ptr<Df::Bitmap> _bitmap;
    
    NSImage* _image;
}

/**
    Color palette used to render the image.
*/
@property (nonatomic, strong) Pal* pal;

/**
    Color map used to render the image.
*/
@property (nonatomic, strong) Cmp* cmp;

/**
    Create a bitmap from Df bitmap object.
*/
+ (Bitmap*) createForBitmap:(std::shared_ptr<Df::Bitmap>)bitmap
    pal:(Pal*)pal
    cmp:(Cmp*)cmp;

/**
    Create a bitmap from a file stored in a gob.
*/
+ (Bitmap*) createFromGob:(Gob*)gob name:(NSString*)filename
    pal:(Pal*)pal
    cmp:(Cmp*)cmp;

/**
    Get the current NSImage associated with the bitmap data.
*/
- (NSImage*) getImage;

@end

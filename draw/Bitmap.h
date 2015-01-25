#import <Cocoa/Cocoa.h>

#include <gob/Bitmap.h>

#import "DfColor.h"

@class ColorMap;
@class Gob;

/**
    Generic bitmap object.
*/
@interface Bitmap : NSObject
{
    std::shared_ptr<Df::Bitmap> _bitmap;
    
    NSImage* _image;
}

/**
    Color map used to render the image.
*/
@property (nonatomic, strong) ColorMap* colorMap;

/**
    Create a bitmap from Df bitmap object.
*/
+ (Bitmap*) createForBitmap:(std::shared_ptr<Df::Bitmap>)bitmap
    colorMap:(ColorMap*)colorMap;

/**
    Create a bitmap from a file stored in a gob.
*/
+ (Bitmap*) createFromGob:(Gob*)gob name:(NSString*)filename
    colorMap:(ColorMap*)colorMap;

/**
    Get the current NSImage associated with the bitmap data.
*/
- (NSImage*) getImage;

@end

#import <Cocoa/Cocoa.h>

#include <gob/Cmp.h>
#include <gob/CmpFile.h>

@class Pal;

/**
    Objective-C PAL file wrapper.
*/
@interface Cmp : NSObject
{
    Df::Cmp _cmp;
}

/**
    Create a Cmp from a gob.
*/
+ (Cmp*) createFromGob:(NSString*)gob named:(NSString*)name;

/**
    Create a Cmp from some data.
*/
+ (Cmp*) createForCmp:(Df::CmpFile)Cmp;

- (const uint8_t*) getData;

/**
    Create an image that shows the contents of the CMP applied to a given palette.
*/
- (CGImageRef) createImageForPal:(Pal*)pal;

/**
    Create an image that shows the contents of the CMP.
*/
- (CGImageRef) createImage;

@end

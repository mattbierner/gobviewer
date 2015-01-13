#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#include <gob/PalFileData.h>

/**
    Objective-C PAL file wrapper.
*/
@interface Pal : NSObject
{
    Df::PalFileData _pal;
}

/**
    Create a pal from a gob.
*/
+ (Pal*) createFromGob:(NSString*)gob named:(NSString*)name;

/**
*/
+ (Pal*) createForPal:(Df::PalFileData)pal;

/**
    Create a 1d image from the PAL.
*/
- (CGImageRef) createImage;

/**
*/
- (NSColor*) getColor:(NSUInteger)index;


- (Df::PalFileData) getData;

@end

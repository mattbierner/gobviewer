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
    Create a PAL from some data.
*/
+ (Pal*) createForPal:(Df::PalFileData)pal;

/**
    Create a 1d image from the PAL.
*/
- (CGImageRef) createImage;

/**
    Lookup a color in the palette by index.
*/
- (NSColor*) getColor:(NSUInteger)index;

/**
    @TODO: remove
*/
- (Df::PalFileData) getData;

@end

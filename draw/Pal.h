#import <Cocoa/Cocoa.h>

#import "DfColor.h"

#include <gob/Pal.h>
#include <gob/PalFile.h>

/**
    Objective-C PAL file wrapper.
*/
@interface Pal : NSObject
{
    Df::Pal _pal;
}

/**
    Create a pal from a gob.
*/
+ (Pal*) createFromGob:(NSString*)gob named:(NSString*)name;

/**
    Create a PAL from some data.
*/
+ (Pal*) createForPal:(Df::PalFile)pal;

/**
    Create a 1d image from the PAL.
*/
- (CGImageRef) createImage;

/**
    Lookup a color in the palette by index.
*/
- (NSColor*) getColor:(NSUInteger)index;

- (RGB) getRgb:(NSUInteger)index;

/**
*/
- (const Df::PalFileColor*) getData;

@end

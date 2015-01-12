#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#include <gober/PalFileData.h>

/**
    Objective-C PAL file wrapper.
*/
@interface Pal : NSObject
{
    DF::PalFileData _pal;
}

/**
    Create a pal from a gob.
*/
+ (Pal*) createFromGob:(NSString*)gob named:(NSString*)name;

/**
*/
+ (Pal*) createForPal:(DF::PalFileData)pal;

/**
    Create a 1d image from the PAL.
*/
- (CGImageRef) createImage;

/**
*/
- (NSColor*) getColor:(NSUInteger)index;


- (DF::PalFileData) getData;

@end

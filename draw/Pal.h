#import <Foundation/Foundation.h>

#include <gober/PalFileData.h>

/**
    Objective-C PAL file wrapper.
*/
@interface Pal : NSObject
{
    DF::PalFileData pal;
}

+ (Pal*) createForPal:(DF::PalFileData)pal;

- (id) initWithPal:(DF::PalFileData)pal;

/**
    Create a 1d image from the pal.
*/
- (CGImageRef) createImage;

@end

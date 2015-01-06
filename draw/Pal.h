#import <Foundation/Foundation.h>

#include <gober/PalFileData.h>

/**
    Objective-C PAL file wrapper.
*/
@interface Pal : NSObject
{
    DF::PalFileData _pal;
}

+ (Pal*) createForPal:(DF::PalFileData)pal;

- (id) initWithPal:(DF::PalFileData)pal;

/**
    Create a 1d image from the PAL.
*/
- (CGImageRef) createImage;

@end

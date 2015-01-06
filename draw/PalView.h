#import <Cocoa/Cocoa.h>

#include <gober/PalFileData.h>


@interface PalView : NSView
{
    CGGradientRef gradient;
}

- (void) upateForPal:(DF::PalFileData)data;


@end

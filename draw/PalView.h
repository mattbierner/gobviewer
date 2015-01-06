#import <Cocoa/Cocoa.h>

#include "Pal.h"

/**
    View that displays a PAL file as a vertical gradient of values.
*/
@interface PalView : NSView
{
    CGImageRef colorData;
}

@property (nonatomic, strong) Pal* pal;

@end

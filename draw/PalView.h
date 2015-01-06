#import <Cocoa/Cocoa.h>

#include "Pal.h"

/**
    Displays a PAL file as a vertical gradient of values.
*/
@interface PalView : NSView
{
    CGImageRef colorData;
}

/**
    The PAL to display.
*/
@property (nonatomic, strong) Pal* pal;

@end

#import "PalView.h"

@interface PalView()
- (void) updateGradient;
@end


@implementation PalView

- (void) dealloc
{
    if (colorData)
        CGImageRelease(colorData);
}

- (void) setPal:(Pal*)pal
{
    _pal = pal;
    [self updateGradient];
}

- (void) updateGradient
{
    if (colorData)
    {
        CGImageRelease(colorData);
        colorData = {};
    }
    
    if (self.pal)
        colorData = [self.pal createImage];
    
    [self setNeedsDisplay:YES];
}

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSGraphicsContext* context = [NSGraphicsContext currentContext];
    CGContextDrawImage(context.CGContext, dirtyRect, colorData);
}

@end
